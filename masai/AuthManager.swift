//
//  AuthManager.swift
//  masai
//
//  Created by Bartomiej Burzec on 27.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//
import Auth0


struct AuthManager {
    
    // MARK: Types
    
    typealias LoginResponseCompletion  = (SocketResponseMessage?, User?) -> Void
    typealias LoginAuth0ResponseCompletion = (Credentials?, Error?) -> Void
    typealias LoginAuth0ValidateSessionCompletion = (Bool, Error?) -> Void
    typealias UpdateAuth0UserDataCompletion = (User?, Error?, Profile?) -> Void
    typealias RegisterAuth0Completion = (Credentials?, Error?) -> Void
    typealias RefreshAuthTokenCompletion = (Bool, Error?) -> Void
    typealias LoginFacebookResponseCompletion = (Credentials?, Error?) -> Void
    typealias LoginGoogleResponseCompletion = (Credentials?, Error?) -> Void
    typealias LoginTwitterResponseCompletion = (Credentials?, Error?) -> Void
    typealias LoginLinkedInResponseCompletion = (Credentials?, Error?) -> Void
    typealias LoginToLiveChatResponseCompletion = (SocketResponseMessage?) -> Void
    
    
    // MARK: Public
    
    static func logout() {
        CacheManager.retrieveLoggedUser()?.clearCredentials()
        CacheManager.removeLoggedUser()
        AuthManager.clearAuthCookies()
        
        for hostPair in HostConnectionManager.shared.existingConnections {
            hostPair.value.clear()
        }
    }
    
    static func clearAuthCookies() {
        if let cookies = HTTPCookieStorage.shared.cookies {
            for cookie in cookies {
                if cookie.name == "id_token" {
                   HTTPCookieStorage.shared.deleteCookie(cookie)
                    print("deleted cookie")
                }
            }
        }
    }
    
    static func setAuthCookie() {
        if let authToken = CacheManager.retrieveLoggedUser()?.auth0IdToken {
            
        var cookieProperties = [HTTPCookiePropertyKey: Any]()
        cookieProperties[HTTPCookiePropertyKey.domain] = "travelfolder.masai.solutions"
        cookieProperties[HTTPCookiePropertyKey.originURL] = "travelfolder.masai.solutions"
        cookieProperties[HTTPCookiePropertyKey.name] = "id_token"
        cookieProperties[HTTPCookiePropertyKey.value] = authToken
        cookieProperties[HTTPCookiePropertyKey.path] = "/"
        cookieProperties[HTTPCookiePropertyKey.version] = "0"
        
        cookieProperties[HTTPCookiePropertyKey.expires] = NSDate().addingTimeInterval(2629743)
        
        let cookie = HTTPCookie.init(properties: cookieProperties)
        
        HTTPCookieStorage.shared.setCookie(cookie!)
            
        }
    }
    
    static func resetAuth0Pass(_ email: String, completion: @escaping ResetAuth0UserPass) {
        RestManager.resetAuth0UserPass(email, completion: completion)
    }
    
    static func validateAuth0Session(completion: @escaping LoginAuth0ValidateSessionCompletion, didRenewToken: Bool = false) {
        guard let loginCachedUser = CacheManager.retrieveLoggedUser(),
            let token = loginCachedUser.auth0AccessToken else {
                DispatchQueue.main.async {
                    completion(false, nil)
                }
                return
        }
        
        Auth0
            .authentication()
            .userInfo(token: token)
            .start { result in
                switch(result) {
                case .success(let profile):
                    var user = loginCachedUser
                    user.update(with: profile)
                    CacheManager.saveLoggedUser(user)
                    
                    DispatchQueue.main.async {
                        completion(true, nil)
                    }
                    
                case .failure(let error):
                    
                    if !didRenewToken {
                        // Try to refresh the token
                        refreshAuthToken(completion: { (didSucceed: Bool, refreshError: Error?) in
                            if didSucceed {
                                validateAuth0Session(completion: completion, didRenewToken: true)
                            } else {
                                DispatchQueue.main.async {
                                    completion(false, error)
                                }
                            }
                        })
                    } else {
                        // We already renewed our token successfully but still cannot log in, so we'll log the user out
                        DispatchQueue.main.async {
                            completion(false, error)
                        }
                    }
                    return
                }
        }
    }
    
    static func loginAuth0(email: String, pass: String, completion: @escaping LoginAuth0ResponseCompletion) {
        
        Auth0.authentication().login(
            usernameOrEmail: email,
            password: pass,
            realm: "Username-Password-Authentication",
            scope: "openid profile offline_access")
            .start { result in
                switch result {
                case .success(let credentials):
                    
                    var newUser = User()
                    newUser.email = email
                    newUser.update(with: credentials)
                    newUser.authType = .standard
                    CacheManager.saveLoggedUser(newUser)
                    
                    updateUserProfile(completion: { (user: User?, error: Error?, profile: Profile?) in
                        
                        AwsBackendManager.getUserProfile({ (didSucceed) in
                            print("did succeed: \(didSucceed)")
                            
                            let userProfile = CacheManager.retrieveUserProfile()
                            update(profile: userProfile, with: profile)
                            userProfile?.postToBackendIfNeeded(andSaveLocally: true)
                            
                            if didSucceed {
                                DispatchQueue.main.async {
                                    completion(credentials, nil)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(nil, nil)
                                }
                            }
                        })
                        
                        
                    })
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                       completion(nil, error)
                    }
                }
        }
        
    }
    
    static func loginFacebook(completion: @escaping LoginFacebookResponseCompletion) {
        Auth0
            .webAuth()
            .connection("facebook")
            .connectionScope("public_profile,email,user_friends")
            .scope("openid profile offline_access")
            .start { result in
                switch result {
                case .success(let credentials):
                    
                    var newUser = User()
                    newUser.update(with: credentials)
                    newUser.authType = .fb
                    CacheManager.saveLoggedUser(newUser)
                    
                    updateUserProfile(completion: { (user: User?, error: Error?, profile: Profile?) in
                        
                        AwsBackendManager.getUserProfile({ (didSucceed) in
                            print("did succeed: \(didSucceed)")
                            
                            let userProfile = CacheManager.retrieveUserProfile()
                            update(profile: userProfile, with: profile)
                            userProfile?.postToBackendIfNeeded(andSaveLocally: true)
                            
                            if didSucceed {
                                DispatchQueue.main.async {
                                    completion(credentials, nil)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(nil, nil)
                                }
                            }
                        })
                        
                    })
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
        }
    }
    
    static func loginGoogle(completion: @escaping LoginGoogleResponseCompletion) {
        Auth0
            .webAuth()
            .connection("google-oauth2")
            .scope("openid")
            .start { result in
                switch result {
                case .success(let credentials):
                    
                    var newUser = User()
                    newUser.update(with: credentials)
                    newUser.authType = .google
                    CacheManager.saveLoggedUser(newUser)
                    
                    updateUserProfile(completion: { (user: User?, error: Error?, profile: Profile?) in
                        
                        AwsBackendManager.getUserProfile({ (didSucceed) in
                            print("did succeed: \(didSucceed)")
                            
                            let userProfile = CacheManager.retrieveUserProfile()
                            update(profile: userProfile, with: profile)
                            userProfile?.postToBackendIfNeeded(andSaveLocally: true)
                            
                            if didSucceed {
                                DispatchQueue.main.async {
                                    completion(credentials, nil)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(nil, nil)
                                }
                            }
                        })
                        
                    })
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                       completion(nil, error)
                    }
                }
        }
        
    }
    
    static func loginLinkedIn(completion: @escaping LoginLinkedInResponseCompletion) {
        Auth0
            .webAuth()
            .connection("linkedin")
            .scope("openid")
            .start { result in
                switch result {
                case .success(let credentials):
                    
                    var newUser = User()
                    newUser.update(with: credentials)
                    newUser.authType = .twitter
                    CacheManager.saveLoggedUser(newUser)
                    
                    updateUserProfile(completion: { (user: User?, error: Error?, profile: Profile?) in
                        
                        AwsBackendManager.getUserProfile({ (didSucceed) in
                            print("did succeed: \(didSucceed)")
                            
                            let userProfile = CacheManager.retrieveUserProfile()
                            update(profile: userProfile, with: profile)
                            userProfile?.postToBackendIfNeeded(andSaveLocally: true)
                            
                            if didSucceed {
                                DispatchQueue.main.async {
                                    completion(credentials, nil)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(nil, nil)
                                }
                            }
                        })
                        
                    })
            
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
        }
        
    }
    
    static func loginTwitter(completion: @escaping LoginTwitterResponseCompletion) {
        Auth0
            .webAuth()
            .connection("twitter")
            .scope("openid")
            .start { result in
                switch result {
                case .success(let credentials):
                    
                    var newUser = User()
                    newUser.update(with: credentials)
                    newUser.authType = .twitter
                    CacheManager.saveLoggedUser(newUser)
                    
                    updateUserProfile(completion: { (user: User?, error: Error?, profile: Profile?) in
                        
                        AwsBackendManager.getUserProfile({ (didSucceed) in
                            print("did succeed: \(didSucceed)")
                            
                            let userProfile = CacheManager.retrieveUserProfile()
                            update(profile: userProfile, with: profile)
                            userProfile?.postToBackendIfNeeded(andSaveLocally: true)
                            
                            if didSucceed {
                                DispatchQueue.main.async {
                                    completion(credentials, nil)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion(nil, nil)
                                }
                            }
                        })
                        
                    })
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
        }
        
    }
    
    static func updateUserProfile(completion: UpdateAuth0UserDataCompletion? = nil) {
        guard let cachedUser = CacheManager.retrieveLoggedUser(),
            let token = cachedUser.auth0AccessToken else {
                DispatchQueue.main.async {
                    completion?(nil, nil, nil)
                }
                return
        }
        
        Auth0
            .authentication()
            .userInfo(token: token)
            .start { result in
                switch(result) {
                case .success(let profile):
                    var user = cachedUser
                    
                    user.update(with: profile)
                    CacheManager.saveLoggedUser(user)
                    AuthManager.setAuthCookie()
                    DispatchQueue.main.async {
                        completion?(user, nil, profile)
                    }
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion?(nil, error, nil)
                    }
                }
        }
    }
    
    static func registerAuth0(email: String, pass: String, firstName: String, lastName: String, completion: @escaping RegisterAuth0Completion) {
        
        Auth0.authentication()
            .createUser(email: email,
                        username: nil,
                        password: pass,
                        connection: "Username-Password-Authentication",
                        userMetadata: nil)
            .start { (result: Result<DatabaseUser>) in
                switch result {
                case .success(_):
                    
                    self.loginAuth0(email: email,
                                    pass: pass,
                                    completion: { (credentials: Credentials?, error: Error?) in
                                        guard let c = credentials,
                                            error == nil else {
                                                completion(nil, error)
                                                return
                                        }
                                        
                                        var newUser = User()
                                        newUser.email = email
                                        newUser.authType = .standard
                                        newUser.update(with: c)
                                        CacheManager.saveLoggedUser(newUser)
                                        
                                        updateUserProfile(completion: { _ in
                                            
                                            let userProfile = CacheManager.retrieveUserProfile() ?? UserProfile()
                                            userProfile.firstName = firstName
                                            userProfile.lastName = lastName
                                            userProfile.primaryEmailAddress = email
                                            userProfile.postToBackendIfNeeded(andSaveLocally: true)
                                            
                                            DispatchQueue.main.async {
                                                completion(c, nil)
                                            }
                                        })
                    })
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
        }
    }
    
    static func refreshAuthToken(completion: RefreshAuthTokenCompletion?) {
        guard let cachedUser = CacheManager.retrieveLoggedUser(),
            let refreshToken = cachedUser.auth0refreshToken else {
                DispatchQueue.main.async {
                    completion?(false, nil)
                }
                return
        }
        
        Auth0
            .authentication()
            .renew(withRefreshToken: refreshToken, scope: nil)
            .start { result in
                switch(result) {
                case .success(let credentials):
                    var user = cachedUser
                    user.update(with: credentials)
                    CacheManager.saveLoggedUser(user)
                    updateUserProfile(completion: { (user: User?, error: Error?, profile: Profile?) in
                        let didSuccceed = (user != nil && error == nil)
                        DispatchQueue.main.async {
                            completion?(didSuccceed, nil)
                        }
                    })
                    
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion?(false, error)
                    }
                }
        }
    }
    
    static func loginCachedUser(to host: Host, completion: @escaping LoginResponseCompletion) {
        if let cachedUser = CacheManager.retrieveLoggedUser(),
            let email = cachedUser.email,
            let pass = cachedUser.pass {
            login(email: email, pass: pass, host: host, completion: completion)
        } else {
            completion(nil, nil)
        }
    }
        
    static func login(email: String, pass: String, host: Host, completion: @escaping LoginResponseCompletion) {
        
        //FIXME: hotfix
        var user = CacheManager.retrieveLoggedUser()
        if user == nil {
            user = User()
        }
        
        let loginType = Constants.Network.Json.email
        user?.email = email
        user?.pass = pass
        
        let requestObject = [
            Constants.Network.Json.message: Constants.Network.Json.method,
            Constants.Network.Json.method: Constants.Network.Methods.login,
            Constants.Network.Json.params: [[
                Constants.Network.Json.user: [
                    loginType: email //TODO: is this the display name?
                ],
                Constants.Network.Json.password: [
                    Constants.Network.Json.digest: pass.sha256(),
                    Constants.Network.Json.algorithm: Constants.Network.Json.sha256
                ]
                ]]
            ] as [String : Any]
        
        guard let socketManager = HostConnectionManager.shared.existingConnections[host] else {
            completion(nil, nil)
            return
        }
        
        socketManager.send(requestObject) { (response) in
            guard response.errorOccured() == false else {
                completion(response, nil)
                return
            }
            
            user?.update(with: response.responseData)
            CacheManager.saveLoggedUser(user!)
            completion(response, user)
        }
    }
    
    static private func update(profile: UserProfile?, with auth0Profile: Profile?) {
        guard let userProfile = profile,
            let profile = auth0Profile else {
                return
        }
        
        if userProfile.firstName == nil && profile.givenName != nil {
            userProfile.firstName = profile.givenName
        }
        if userProfile.lastName == nil && profile.familyName != nil {
            userProfile.lastName = profile.familyName
        }
        if userProfile.primaryEmailAddress == nil && profile.email != nil {
            userProfile.primaryEmailAddress = profile.email
        }
        userProfile.postToBackendIfNeeded(andSaveLocally: true)
    }
    
//    static func setUsername(_ username: String, host: Host, completion: SocketManagerMessageCompletion? = nil) {
//        let requestObject = [
//            Constants.Network.Json.message: Constants.Network.Json.method,
//            Constants.Network.Json.method: Constants.Network.Methods.setUsername,
//            Constants.Network.Json.params: [
//                username]
//            ] as [String: Any]
//
//        SocketManager.send(requestObject, host: host) { (response) in
//            if let completion = completion {
//                var user = CacheManager.retrieveLoggedUser()
//                if user != nil && response.errorOccured() == false {
//                    user?.username = username
//                    CacheManager.saveLoggedUser(user!)
//                }
//                completion(response)
//            }
//        }
//    }
    
//    static func loginToRocketChat(token: String, secret: String) {
//        
//        let requestObject = [
//            Constants.Network.Json.message: Constants.Network.Json.method,
//            Constants.Network.Json.method: Constants.Network.Methods.login,
//            Constants.Network.Json.params: [["oauth":[
//                "credentialToken":token,
//                "credentialSecret":"QzSu-LOP0ETyTIAto7Sz8L5WAU2vpMxzIqDAQ9Trcr3KXz3zxIaViq34bV8pnGsd"
//                ] ]]
//            ] as [String : Any]
//        
//        
//        SocketManager.send(requestObject, host: Host.main()) { (response) in
//            print("ROCKET CHAT OAUTH login response \(response)")
//        }
//        
//    }
//    
//    
//    static func register(_ username: String, email: String, pass: String, host: Host, completion: @escaping SocketManagerMessageCompletion) {
//        
//        let requestObject = [Constants.Network.Json.message: Constants.Network.Json.method,
//                             Constants.Network.Json.method: Constants.Network.Methods.register,
//                             Constants.Network.Json.params: [[
//                                Constants.Network.Json.name: username,
//                                Constants.Network.Json.email: email,
//                                Constants.Network.Json.pass: pass,
//                                Constants.Network.Json.confirmPass: pass]
//            ]] as [String: Any]
//        
//        SocketManager.send(requestObject, host: host) { (response) in
//            if response.errorOccured() == false {
//                login(email, pass: pass, host: host, completion: { (loginResponse, user) in
//                    if let response = loginResponse {
//                        completion(response)
//                    }
//                    //TODO: to handle
//                })
//            } else {
//                completion(response)
//            }
//        }
//    }
    
    
}
