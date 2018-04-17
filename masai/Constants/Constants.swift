//
//  Segues.swift
//  masai
//
//  Created by Bartomiej Burzec on 19.01.2017.
//  Copyright © 2017 Embiq sp. z o.o. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Auth0 {
       static var clientId: String {
            get {
                if let path = Bundle.main.path(forResource: "Auth0", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject], let value = dict["ClientId"] as? String {
                    return value
                }
                return ""
            }
        }
        
       static var domain: String {
            get {
                if let path = Bundle.main.path(forResource: "Auth0", ofType: "plist"), let dict = NSDictionary(contentsOfFile: path) as? [String: AnyObject], let value = dict["Domain"] as? String {
                    return value
                }
                return ""
            }
        }
        
       static var resetPassEndpoint: String {
            return "https://" + domain + "/dbconnections/change_password"
        }
        
        static let resetPassConnection = "Username-Password-Authentication"
        
    }
    
    struct Notification {
        static let reconnect = "Masai.Notification.BackFromBackground"
        
        // History loading
        static let historyLoadedNotificationString = "Masai.Notification.HistoryLoaded"
        static let historyLoaded: Foundation.Notification = {
            let notificationName = Foundation.Notification.Name(rawValue: Constants.Notification.historyLoadedNotificationString)
            let note = Foundation.Notification(name: notificationName, object: nil, userInfo: nil)
            return note
        }()
        static func historyLoaded(for channel: Channel) -> Foundation.Notification {
            var note = Notification.historyLoaded
            let userInfo: [AnyHashable: Any] = [
                "channel": channel
            ]
            note.userInfo = userInfo
            return note
        }
        
        // Channel Closing
        static let closeChannel: Foundation.Notification = {
            let notificationName = Foundation.Notification.Name(rawValue: "Masai.Notification.CloseChannel")
            let note = Foundation.Notification(name: notificationName, object: nil, userInfo: nil)
            return note
        }()
        static func close(channel: Channel, message: ChatMessage) -> Foundation.Notification {
            var note = Notification.closeChannel
            let userInfo: [AnyHashable: Any] = [
                "channel": channel,
                "message": message
            ]
            note.userInfo = userInfo
            return note
        }
        
        // Connecting
        static let socketConnected: Foundation.Notification = {
            let notificationName = Foundation.Notification.Name(rawValue: "Masai.Notification.SocketConnected")
            let note = Foundation.Notification(name: notificationName, object: nil, userInfo: nil)
            return note
        }()
        static func socketConnected(host: Host) -> Foundation.Notification {
            var note = Notification.socketConnected
            let userInfo: [AnyHashable: Any] = [
                "host": host
            ]
            note.userInfo = userInfo
            return note
        }
        
        // New channel found
        static let newChannelFound: Foundation.Notification = {
            let notificationName = Foundation.Notification.Name(rawValue: "Masai.Notification.NewChannelFound")
            let note = Foundation.Notification(name: notificationName, object: nil, userInfo: nil)
            return note
        }()
        
        // Open chat push request
        static let openChatPushRequest: Foundation.Notification = {
            let notificationName = Foundation.Notification.Name(rawValue: "Masai.Notification.OpenChatPushRequest")
            let note = Foundation.Notification(name: notificationName, object: nil, userInfo: nil)
            return note
        }()
        static func openChatPushRequest(request: PushOpenChatRequest) -> Foundation.Notification {
            var note = Notification.openChatPushRequest
            let userInfo: [AnyHashable: Any] = [
                "request": request
            ]
            note.userInfo = userInfo
            return note
        }
    }
    
    struct  Map {
        static let defaultLatitudeDelta = 0.005
        static let defaultLongitudeDelta = 0.005
    }
    
    struct Google {
        static let apiKey = "AIzaSyBlLXsEscJsJg2CrV8JGeiRFG7D9FaympE"
        static let photoEndpoint = "https://maps.googleapis.com/maps/api/place/photo?key=\(apiKey)"
        static let locationDetailsEndpoint = "http://maps.googleapis.com/maps/api/geocode/json?latlng="
    }
    
    struct Images {
        static let messageStatusFailed = "ic_message_failed"
        static let messageStatusSending = "ic_message_sending"
        static let messageStatusSent = "ic_message_sent"
    }
    
    struct Segue {
        static let splashToLogin = "splashToLoginSegue"
        static let loginToMain  = "loginToMainSegue"
        static let loginToRegister = "loginToRegister"
        static let registerToMain = "registerToMain"
        static let splashToMain = "splashToMain"
        static let loginToResetPass = "loginToResetPass"
        static let conversationToChat = "conversationToChat"
        static let reservationToHotelDetails = "reservationToHotelDetails"
        static let reservationToFlightDetails = "reservationToFlightDetails"
        static let reservationToPublicTransportDetails = "reservationToPublicTransportDetails"
    }
    
    struct Reservations {
        
        struct Json {
            static let flight = "flight"
            static let notes = "notes"
            static let recordLocator = "record-locator"
            static let bookingDetails = "booking-details"
            static let name = "name"
            static let phone = "phone"
            static let confirmationNumber = "confirmation-number"
            static let providerDetails = "provider-details"
            static let totalPrice = "total-price"
            static let totalCost = "total-cost"
            static let currencyCode = "currency-code"
            static let details = "details"
            static let number = "number"
            static let airlineCode = "airline-code"
            static let departure = "departure"
            static let lattitude = "latitude"
            static let longitude = "longitude"
            static let airportCode = "airport-code"
            static let terminal = "terminal"
            static let gate = "gate"
            static let localDate = "local-date-time"
            static let utcDate = "utc-date-time"
            static let arrival = "arrival"
            static let duration = "duration"
            static let distanceInMiles = "distance-in-miles"
            static let classType = "class-type"
            static let traveller = "traveler"
            static let firstName = "first-name"
            static let lastName = "last-name"
            static let eTicketNumber = "e-ticket"
            static let price = "price"
            static let metadata = "metadata"
            static let ref = "ref"
            static let journey = "journey"
            static let from = "from"
            static let to = "to"
            static let segment = "segment"
            static let hotelReservation = "hotel-reservation"
            static let hotelName = "hotel-name"
            static let street = "street"
            static let city = "city"
            static let stateCode = "state-code"
            static let countryCode = "country-code"
            static let countryName = "country-name"
            static let postalCode = "postal-code"
            static let checkIn = "check-in"
            static let checkOut = "check-out"
            static let room = "room"
            static let fax = "fax"
            static let guest = "guest"
            static let publicTransport = "public-transportation"
            static let stationName = "station-name"
            static let platform = "platform"
            static let stationCode = "station-code"
            static let trainNumber = "train-number"
            static let seat = "seat"
            static let cabin = "cabin"
            static let address = "address"
            static let url = "url"
            static let oauth = "oauth"
            static let clientId = "client_id"
        }
        
    }
    
    struct Network {
        
        static let conversationSuffix = "130"
        
        struct Error {
            static let usernameAlreadyInUse = "error-field-unavailable"
            static let emailAlreadyExist = "Email already exists."
        }
        
        struct Json {
            static let id = "id"
            static let message = "msg"
            static let messages = "messages"
            static let pong = "pong"
            static let error = "error"
            static let method = "method"
            static let name = "name"
            static let email = "email"
            static let emails = "emails"
            static let pass = "pass"
            static let confirmPass = "confirm-pass"
            static let user = "user"
            static let username = "username"
            static let password = "password"
            static let digest = "digest"
            static let algorithm = "algorithm"
            static let sha256 = "sha-256"
            static let params = "params"
            static let date = "$date"
            static let identifier = "_id"
            static let rid = "rid"
            static let updated = "_updatedAt"
            static let update = "update"
            static let result = "result"
            static let results = "results"
            static let subscribe = "sub"
            static let roomStream = "stream-room-messages"
            static let eventName = "eventName"
            static let fields = "fields"
            static let timestamp = "ts"
            static let userInfo = "u"
            static let args = "args"
            static let collection = "collection"
            static let status = "status"
            static let address = "address"
            static let sender = "sender"
            static let body = "body"
            static let subject = "subject"
            static let attachments = "attachments"
            static let imageURL = "image_url"
            static let value = "value"
            static let rocketUpload = "rocketchat-uploads"
            static let type = "type"
            static let size = "size"
            static let upload = "upload"
            static let download = "download"
            static let postData = "postData"
            static let s3 = "s3"
            static let url = "url"
            static let file = "file"
            static let token = "token"
            static let userId = "userId"
            static let geometry = "geometry"
            static let location = "location"
            static let lat = "lat"
            static let lng = "lng"
            static let rating = "rating"
            static let icon = "icon"
            static let photos = "photos"
            static let photoReference = "photo_reference"
            static let placeId = "place_id"
            static let types = "types"
            static let width = "width"
            static let coordinates = "coordinates"
            static let point = "Point"
            static let formattedAddress = "formatted_address"
            static let urls = "urls"
            static let meta = "meta"
            static let pageTitle = "pageTitle"
            static let description = "description"
            static let pageImage = "ogImage"
            static let parsedUrl = "parsedUrl"
            static let host = "host"
            static let titleLink = "title_link"
            static let title = "title"
            static let resume = "resume"
            static let payload = "payload"
            static let granted = "granted_for"
            static let clientId = "client_id"
            static let connection = "connection"
            static let visitor = "v"
            static let open = "open"
            static let appName = "appName"
            static let metadata = "metadata"
            static let apn = "apn"
            
        }
        
        struct PermissionsTypes {
            static let granted = "permission granted"
            static let denied = "permission denied"
        }
        
        struct Methods {
            static let login = "login"
            static let register = "registerUser"
            static let setUsername = "setUsername"
            static let subscriptions = "subscriptions/get"
            static let createChannel = "createChannel"
            static let loadHistory = "loadHistory"
            static let sendMessage = "sendMessage"
            static let resetPass = "sendForgotPasswordEmail"
            static let userDetails = "me"
            static let sendFileMessage = "sendFileMessage"
            static let upload = "slingshot/uploadRequest"
            static let getInitialData = "livechat:getInitialData"
            static let registerGuest = "livechat:registerGuest"
            static let sendLiveChatMessage = "sendMessageLivechat"
            static let getRooms = "masai:getRooms"
            static let registerPushToken = "raix:push-update"
            
            struct Rest {
                static let lotusMessage = "/reisebuddy-api/incoming/lotusMail"
                static let userDetails = "/api/v1/me"
                static let userProfile = "/api/v1/users/me/profile"
                static let tokenHeader = "X-Auth-Token"
                static let userIdHeader = "X-User-Id"
                static let contentTypeJsonHeader = "Content-Type"
                static let contentTypeJson = "application/json"
                static let authorizationHeader = "Authorization"
            }
        }
        
        struct AwsBackend {
            
            static let baseUrl: String = {
//                let dev = "https://rynm6azkoh.execute-api.eu-central-1.amazonaws.com/"
//                let live = "https://qjchuhm517.execute-api.eu-central-1.amazonaws.com/"
                
                let live = "https://qsu2vaqmg2.execute-api.eu-central-1.amazonaws.com/"
//                let staging = "https://vez1vt5dh1.execute-api.eu-central-1.amazonaws.com/"
                return live
            }()
            static let apiVersion = "latest"
            
            struct Endpoints {
                static let userProfile: String = { return Constants.Network.AwsBackend.baseUrl + Constants.Network.AwsBackend.apiVersion + "/users/me/profile" }()
                static let choices: String = { return Constants.Network.AwsBackend.baseUrl + Constants.Network.AwsBackend.apiVersion + "/choices" }()
                static let transactions: String = { return Constants.Network.AwsBackend.baseUrl + Constants.Network.AwsBackend.apiVersion + "/users/me/transactions" }()
                static let accessGrants: String = { return Constants.Network.AwsBackend.baseUrl + Constants.Network.AwsBackend.apiVersion + "/users/me/access/grants" }()
                static func deleteAccessGrant(for userId: String) -> String {
                    return Constants.Network.AwsBackend.baseUrl + Constants.Network.AwsBackend.apiVersion + "/users/me/access/grants/\(userId)"
                }
                static let journeys: String = { return Constants.Network.AwsBackend.baseUrl + Constants.Network.AwsBackend.apiVersion + "/users/me/journey-list" }()
                static let hosts: String = { return Constants.Network.AwsBackend.baseUrl + Constants.Network.AwsBackend.apiVersion + "/users/me/hosts" }()
                
                static let privacyPolicy: String = {
                    return "http://rocketchat-staging-alb-1883915518.eu-central-1.elb.amazonaws.com/privacy-policy"
                }()
                static let termsOfService: String = {
                    return "http://rocketchat-staging-alb-1883915518.eu-central-1.elb.amazonaws.com/terms-of-service"
                }()
            }
            
            struct Authorization {
                static let authorizationHeader = "Authorization"
            }
            
        }
        
        struct RocketChatApi {
            
            static func getAvatarEndpoint(on baseUrl: String, for username: String) -> String {
                let sanitizedBaseUrl = baseUrl.hasSuffix("/") ? baseUrl : baseUrl + "/"
//                return "\(sanitizedBaseUrl)api/v1/users.getAvatar?userId=\(userId)"
                return "\(sanitizedBaseUrl)avatar/\(username)"
            }
            
        }
    }
    
    struct Cache {
        static let conversationList = "cache.conversationList"
        static let user = "cache.user"
        static let userProfile = "cache.userProfile"
        static let hosts = "cache.hosts"
        static let archivedChannels = "cache.archivedChannels"
    }
    
}
