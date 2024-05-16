//
//  EasemobReuest.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import Foundation
import EaseChatUIKit

public struct EasemobRequestHTTPMethod: RawRepresentable, Equatable, Hashable {
    /// `CONNECT` method.
    public static let connect = EasemobRequestHTTPMethod(rawValue: "CONNECT")
    /// `DELETE` method.
    public static let delete = EasemobRequestHTTPMethod(rawValue: "DELETE")
    /// `GET` method.
    public static let get = EasemobRequestHTTPMethod(rawValue: "GET")
    /// `HEAD` method.
    public static let head = EasemobRequestHTTPMethod(rawValue: "HEAD")
    /// `OPTIONS` method.
    public static let options = EasemobRequestHTTPMethod(rawValue: "OPTIONS")
    /// `PATCH` method.
    public static let patch = EasemobRequestHTTPMethod(rawValue: "PATCH")
    /// `POST` method.
    public static let post = EasemobRequestHTTPMethod(rawValue: "POST")
    /// `PUT` method.
    public static let put = EasemobRequestHTTPMethod(rawValue: "PUT")
    /// `TRACE` method.
    public static let trace = EasemobRequestHTTPMethod(rawValue: "TRACE")
    
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

@objcMembers public class EasemobRequest: NSObject, URLSessionDelegate,URLSessionDataDelegate {
    
    @objc public static var shared = EasemobRequest()
    
    @UserDefault("EaseChatDemoServerConfig", defaultValue: Dictionary<String,String>()) private var serverConfig
    
    var host: String {
        if let restAddress = self.serverConfig["rest_server_address"],let enableDnsConfig = EaseChatUIKitClient.shared.option.option_chat.value(forKey:  "enableDnsConfig") as? Bool,!enableDnsConfig {
            return restAddress
        } else {
            return ServerHost
        }
    }
    
    private lazy var config: URLSessionConfiguration = {
        //MARK: - session config
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Content-Type":"application/json"]
        config.timeoutIntervalForRequest = 10
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return config
    }()
    
    private var session: URLSession?
    
    override init() {
        super.init()
        self.session = URLSession(configuration: self.config, delegate: self, delegateQueue: .main)
    }
    
    public func constructRequest(method: EasemobRequestHTTPMethod,
                                 uri: String,
                                 params: Dictionary<String,Any>,
                                 headers:[String : String],
                                 callBack:@escaping ((Data?,HTTPURLResponse?,Error?) -> Void)) -> URLSessionTask? {
        guard let url = URL(string: self.host+uri) else { return nil }
        //MARK: - request
        var urlRequest = URLRequest(url: url)
        if method == .put || method == .post {
            do {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
            } catch {
                assert(false, "\(error.localizedDescription)")
            }
        }
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        let task = self.session?.dataTask(with: urlRequest){
            if $2 == nil {
                let response = ($1 as? HTTPURLResponse)
                callBack($0,response,$2)
                if response?.statusCode ?? 200 != 200 {
                    consoleLogInfo("request failed: log curl:\(urlRequest.cURL)", type: .error)
                }
            } else {
                callBack(nil,nil,$2)
                consoleLogInfo("request failed: log curl:\(urlRequest.cURL)", type: .error)
            }
        }
        task?.resume()
        return task
    }
    
    @objc public func sendRequest(method: String,
                                  uri: String,
                                  params: Dictionary<String,Any>,
                                  headers:[String : String],
                                  callBack:@escaping ((Data?,HTTPURLResponse?,Error?) -> Void)) -> URLSessionTask? {
        guard let url = URL(string: self.host+uri) else { return nil }
        //MARK: - request
        var urlRequest = URLRequest(url: url)
        do {
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            assert(false, "\(error.localizedDescription)")
        }
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method
        let task = self.session?.dataTask(with: urlRequest){
            if $2 == nil {
                let response = ($1 as? HTTPURLResponse)
                callBack($0,response,$2)
                if response?.statusCode ?? 200 != 200 {
                    consoleLogInfo("request failed: log curl:\(urlRequest.cURL)", type: .error)
                }
            } else {
                callBack(nil,nil,$2)
                consoleLogInfo("request failed: log curl:\(urlRequest.cURL)", type: .error)
            }
        }
        task?.resume()
        return task
    }
    
    @objc public func uploadImage(image: UIImage, callBack: @escaping ((Error?,Dictionary<String,Any>?) -> Void)) {

        guard let imageData = image.jpegData(compressionQuality: 0.1) else { return }
        // 创建上传的 URLRequest
        guard let userId = EaseChatUIKitContext.shared?.currentUserId  else { return }
        var request = URLRequest(url: URL(string: ServerHost+"/inside/app/user/\(userId)/avatar/upload")!)
        request.httpMethod = "POST"
        let boundary = Date().timeIntervalSince1970*1000
        request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(boundary).jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                consoleLogInfo("Upload Image Error: \(error.localizedDescription) : \(request.cURL)", type: .error)
            } else {
                if let data = data,let response = response as? HTTPURLResponse,response.statusCode == 200 {
                    callBack(nil,data.chat.toDictionary())
                } else {
                    let otherError = EasemobError()
                    otherError.code = "\((response as? HTTPURLResponse)?.statusCode ?? 0)"
                    otherError.message = response.debugDescription
                    callBack(otherError,nil)
                    consoleLogInfo("Upload Image Error: \(response.debugDescription) : \(request.cURL)", type: .error)
                }
            }
        }
        task.resume()
    }
    
    //MARK: - URLSessionDelegate
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential,credential)
        }
    }
    
    
    
}

extension URLRequest {

    var cURL: String {
        guard
            let url = url,
            let httpMethod = httpMethod,
            url.absoluteString.utf8.count > 0,
            httpMethod.utf8.count > 0
        else {
            return ""
        }

        var curlCommand = "curl"

        // URL
        curlCommand = curlCommand.appendingFormat(" '%@'", url.absoluteString)

        // Method if different from GET
        if "GET" != httpMethod {
            curlCommand = curlCommand.appendingFormat(" -X %@", httpMethod)
        }

        // Headers
        let allHTTPHeaderFields = self.allHTTPHeaderFields
        allHTTPHeaderFields?.keys.forEach({ key in
            if let value = allHTTPHeaderFields![key] {
                curlCommand = curlCommand.appendingFormat(" -H '%@: %@'", key, value)
            }
        })

        // HTTP body
        if
            let httpBodyData = httpBody,
            let httpBody = String(data: httpBodyData, encoding: .utf8),
            httpBody.utf8.count > 0
        {
            var escapedHttpBody = httpBody.replacingOccurrences(of: "\\\"", with: "\\\\\\\"")
            escapedHttpBody = escapedHttpBody.replacingOccurrences(of: "\"", with: "\\\"")
            curlCommand = curlCommand.appendingFormat(" -d \"%@\"", escapedHttpBody)
        }
        return curlCommand
    }
}
