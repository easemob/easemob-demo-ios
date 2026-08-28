//
//  EasemobTokenRequest.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import Foundation
import EaseChatUIKit

/// SDK 5.0删除了`fetchToken(withUsername:password:)`,调试模式下的用户名密码登录改为向业务服务器换取token。
/// 该请求发生在登录之前,不能复用`EasemobBusinessRequest`,后者会带上旧token且401时会发出回到登录页的通知。
@objcMembers public class EasemobTokenRequest: NSObject {

    @objc public static let shared = EasemobTokenRequest()

    @UserDefault("EaseChatDemoServerConfig", defaultValue: Dictionary<String,String>()) private var serverConfig

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: config)
    }()

    /// 取token的完整地址,形如`{host}/{org}/{app}/token`,org与app由当前AppKey拆分而来。
    private var tokenURL: URL? {
        var host = (self.serverConfig[TokenServerHostKey] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        while host.hasSuffix("/") {
            host.removeLast()
        }
        guard !host.isEmpty else { return nil }
        var appkey = (self.serverConfig["application"] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if appkey.isEmpty {
            appkey = AppKey
        }
        let parts = appkey.components(separatedBy: "#")
        guard parts.count == 2,!parts[0].isEmpty,!parts[1].isEmpty else { return nil }
        return URL(string: host+"/\(parts[0])/\(parts[1])/token")
    }

    /// Description 用用户名密码向业务服务器换取IM登录token。
    /// - Parameters:
    ///   - userId: 环信用户名
    ///   - password: 密码
    ///   - callBack: 主线程回调,成功时返回token,失败时返回`EasemobError`或网络错误。
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    public func fetchToken(userId: String,
                           password: String,
                           callBack:@escaping ((String?,Error?) -> Void)) -> URLSessionTask? {
        guard let url = self.tokenURL else {
            let configError = EasemobError()
            configError.code = "0"
            configError.message = "请先在服务器配置中填写获取token的host与正确的App Key"
            callBack(nil,configError)
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = EasemobRequestHTTPMethod.post.rawValue
        urlRequest.allHTTPHeaderFields = ["Content-Type":"application/json","Accept":"application/json"]
        let params: Dictionary<String,Any> = ["grant_type":"password","username":userId,"password":password,"ttl":36000000]
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            consoleLogInfo("fetch token failed: \(error.localizedDescription)", type: .error)
            callBack(nil,error)
            return nil
        }
        let task = self.session.dataTask(with: urlRequest) { data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let responseMap = data?.chat.toDictionary() ?? [:]
            DispatchQueue.main.async {
                if error == nil,statusCode == 200 {
                    if let token = (responseMap["access_token"] as? String) ?? (responseMap["token"] as? String),!token.isEmpty {
                        callBack(token,nil)
                    } else {
                        let emptyError = EasemobError()
                        emptyError.code = "\(statusCode)"
                        emptyError.message = "获取token失败,响应中未包含access_token"
                        callBack(nil,emptyError)
                        consoleLogInfo("fetch token failed: no access_token. log curl:\(urlRequest.cURL())", type: .error)
                    }
                } else if let error = error {
                    callBack(nil,error)
                    consoleLogInfo("fetch token failed: \(error.localizedDescription) log curl:\(urlRequest.cURL())", type: .error)
                } else {
                    let someError = EasemobError()
                    someError.code = "\(statusCode)"
                    someError.message = (responseMap["error_description"] as? String) ?? (responseMap["errorInfo"] as? String) ?? (responseMap["error"] as? String) ?? HTTPURLResponse.localizedString(forStatusCode: statusCode)
                    callBack(nil,someError)
                    consoleLogInfo("fetch token failed: \(someError.message ?? "") log curl:\(urlRequest.cURL())", type: .error)
                }
            }
        } 
        task.resume()
        return task
    }

}
