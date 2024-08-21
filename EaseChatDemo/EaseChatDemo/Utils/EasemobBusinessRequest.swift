//
//  EasemobBusinessRequest.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import Foundation
import EaseChatUIKit
import KakaJSON


public class EasemobError: Error,Convertible {
    
    var code: String?
    var message: String?
    
    required public init() {
        
    }
    
    public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        property.name
    }
}

@objc public class EasemobBusinessRequest: NSObject {
        
    @objc public static let shared = EasemobBusinessRequest()
    
    @UserDefault("EaseChatDemoUserToken", defaultValue: ChatClient.shared().accessUserToken ?? "") private var token
    
    @UserDefault("EaseChatDemoServerConfig", defaultValue: Dictionary<String,String>()) private var serverConfig
    
    /// Description send a request contain generic
    /// - Parameters:
    ///   - method: EasemobRequestHTTPMethod
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    public func sendRequest<T:Convertible>(
        method: EasemobRequestHTTPMethod,
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((T?,Error?) -> Void)) -> URLSessionTask? {
        print(params)

        let headers = ["Accept":"application/json","Authorization":self.token,"Content-Type":"application/json"]
            
        let task = EasemobRequest.shared.constructRequest(method: method, uri: uri, params: params, headers: headers) { data, response, error in
            DispatchQueue.main.async {
                if error == nil,response?.statusCode ?? 0 == 200 {
                    callBack(model(from: data?.chat.toDictionary() ?? [:], type: T.self) as? T,error)
                } else {
                    if error == nil {
                        let errorMap = data?.chat.toDictionary() ?? [:]
                        let someError = EasemobError()
                        someError.message = errorMap["errorInfo"] as? String
                        someError.code = "\((errorMap["code"] as? Int) ?? response!.statusCode)"
                        if let code = errorMap["code"] as? String,code == "401" {
                            NotificationCenter.default.post(name: Notification.Name("BackLogin"), object: nil)
                        }
                        callBack(nil,error)
                    } else {
                        let someError = EasemobError()
                        someError.message = error?.localizedDescription
                        someError.code = "\((error as? NSError)?.code ?? response!.statusCode)"
                        callBack(nil,error)
                    }
                }
            }
        }
        return task
    }
    /// Description send a request
    /// - Parameters:
    ///   - method: EasemobRequestHTTPMethod
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    public func sendRequest(
        method: EasemobRequestHTTPMethod,
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String,Any>?,Error?) -> Void)) -> URLSessionTask? {
        let headers = ["Accept":"application/json","Authorization":"Bearer "+self.token,"Content-Type":"application/json"]
        let task = EasemobRequest.shared.constructRequest(method: method, uri: uri, params: params, headers: headers) { data, response, error in
            if error == nil,response?.statusCode ?? 0 == 200 {
                callBack(data?.chat.toDictionary(),nil)
            } else {
                if error == nil {
                    let errorMap = data?.chat.toDictionary() ?? [:]
                    let someError = EasemobError()
                    someError.message = errorMap["errorInfo"] as? String
                    someError.code = "\((errorMap["code"] as? Int) ?? response!.statusCode)"
                    if let code = errorMap["code"] as? String,code == "401" {
                        NotificationCenter.default.post(name: Notification.Name("BackLogin"), object: nil)
                    }
                    callBack(nil,error)
                } else {
                    let someError = EasemobError()
                    someError.message = error?.localizedDescription
                    someError.code = "\((error as? NSError)?.code ?? response!.statusCode)"
                    callBack(nil,error)
                }
            }
        }
        return task
    }

}

//MARK: - rest request
public extension EasemobBusinessRequest {
    
    //MARK: - generic uri request
    
    /// Description send a get request contain generic
    /// - Parameters:
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendGETRequest<U:Convertible>(
        uri: String,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .get, uri: uri, params: params, callBack: callBack)
    }
    
    /// Description send a post request contain generic
    /// - Parameters:
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPOSTRequest<U:Convertible>(
        uri: String,params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: uri, params: params, callBack: callBack)
    }
    
    /// Description send a put request contain generic
    /// - Parameters:
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPUTRequest<U:Convertible>(
        uri: String,params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .put, uri: uri, params: params, callBack: callBack)
    }
    
    /// Description send a delete request contain generic
    /// - Parameters:
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendDELETERequest<U:Convertible>(
        uri: String,params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .delete, uri: uri, params: params, callBack: callBack)
    }
    
    //MARK: - generic api request
    /// Description send a get request contain generic
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with EasemobBusinessApi.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendGETRequest<U:Convertible>(
        api: EasemobBusinessApi,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .get, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a post request contain generic
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with EasemobBusinessApi.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPOSTRequest<U:Convertible>(
        api: EasemobBusinessApi,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a put request contain generic
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with EasemobBusinessApi.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPUTRequest<U:Convertible>(
        api: EasemobBusinessApi,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .put, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a delete request contain generic
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with EasemobBusinessApi.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendDELETERequest<U:Convertible>(
        api: EasemobBusinessApi,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .delete, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    //MARK: - no generic uri request
    /// Description send a get request
    /// - Parameters:
    ///   - method: EasemobRequestHTTPMethod
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    @objc
    func sendGETRequest(
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .get, uri: uri, params: params, callBack: callBack)
    }
    /// Description send a post request
    /// - Parameters:
    ///   - method: EasemobRequestHTTPMethod
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    @objc
    func sendPOSTRequest(
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: uri, params: params, callBack: callBack)
    }
    /// Description send a put request
    /// - Parameters:
    ///   - method: EasemobRequestHTTPMethod
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    @objc
    func sendPUTRequest(
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .put, uri: uri, params: params, callBack: callBack)
    }
    /// Description send a delete request
    /// - Parameters:
    ///   - method: EasemobRequestHTTPMethod
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    @objc
    func sendDELETERequest(
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .delete, uri: uri, params: params, callBack: callBack)
    }
    
    //MARK: - no generic api request
    /// Description send a get request
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with EasemobBusinessApi.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendGETRequest(
        api: EasemobBusinessApi,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .get, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a post request
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with EasemobBusinessApi.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPOSTRequest(
        api: EasemobBusinessApi,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a put request
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with EasemobBusinessApi.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPUTRequest(
        api: EasemobBusinessApi,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .put, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a delete request
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with EasemobBusinessApi.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendDELETERequest(
        api: EasemobBusinessApi,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .delete, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description convert api to uri
    /// - Parameter api: EasemobBusinessApi
    /// - Returns: uri string
    func convertApi(api: EasemobBusinessApi) -> String {
        var uri = "/inside/app"
        switch api {
        case .login(_):
            uri += "/user/login/V2"
        case .refreshIMToken(_):
            uri += "/user/token/refresh"
        case .deregister(let phoneNum):
            uri += "/user/\(phoneNum)"
        case .verificationCode(let phoneNum):
            uri += "/sms/send/"+phoneNum
        case .autoDestroyGroup(let groupId):
            var appKey = AppKey
            if let key = self.serverConfig["application"] {
                appKey = key
            }
            uri += "/group/\(groupId)?appkey=\(appKey.chat.urlEncoded)"
        case .fetchGroupAvatar(let groupId):
            uri += "/group/\(groupId)/avatarurl"
        case .fetchRTCToken(let channelId,let userId):
            uri = "/inside/token/rtc/channel/\(channelId)/user/\(userId)"
        case .addFriendByPhoneNumber(let phone, let userId):
            uri += "/user/\(phone)?operator=\(userId)"
        case .mirrorCallUserIdToChatUserId(let callUserId):
            uri = "/inside/agora/channel/mapper?channelName=\(callUserId)"
        }
        return uri
    }
}


