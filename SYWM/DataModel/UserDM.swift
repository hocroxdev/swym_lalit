//
//  UserDM.swift
//  Dailyuse
//
//  Created by Maninder Singh on 14/02/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import Foundation

struct AppVersionResponse {
    var latestIOSVersion = ""
    var criticalIOSVersion = ""
}

struct DeliveryRegion {
    var _id = ""
    var name = ""
}

struct Chats {
    var blockChat = false
    var id = 0
    var lastMessage = ""
    var lastMessageTime = ""
    var other = UserDataChat()
}

struct ChatMessage {
    var chatId = 0
    var id = 0
    var message = ""
    var mine = false
    var receiver = UserDataChat()
    var sender = UserDataChat()
    var sentOn = ""
    
}

extension UserVM{
    
    
    
    func parseLoginResponse(response : JSONDictionary){
        if let data = response[APIKeys.kData] as? NSDictionary{
            DataManager.accessToken = data["accessToken"] as? String ?? ""
        }
    }
    
    
    func parseChatList(response : JSONArray) -> [Chats]{
        var mapData = [Chats]()
        for data in response{
            let id = data["id"] as? Int ?? 0
            let blockChat = data["blockChat"] as? Bool ?? false
            let lastMessage = data["lastMessage"] as? String ?? ""
            let lastMessageTime = data["lastMessageTime"] as? String ?? ""
            var userData = UserDataChat()
            if let other = data["other"] as? NSDictionary{
                let id = other["id"] as? Int ?? 0
                let login = other["login"] as? String ?? ""
                let email = other["email"] as? String ?? ""
                let imageUrl = other["imageUrl"] as? String ?? ""
                let image = other["image"] as? String ?? ""
                let firstName = other["firstName"] as? String ?? ""
                let lastName = other["lastName"] as? String ?? ""
                userData = UserDataChat(id: id, login: login, langKey: "", email: email, imageUrl: imageUrl,image : image, firstName: firstName, lastName: lastName,dateOfBirth : "")
            }
            mapData.append(Chats(blockChat: blockChat, id: id, lastMessage: lastMessage, lastMessageTime: lastMessageTime, other: userData))
        }
        return mapData
    }

    
    func parseChatList1(data : JSONDictionary) -> Chats{
        let id = data["id"] as? Int ?? 0
        let blockChat = data["blockChat"] as? Bool ?? false
        let lastMessage = data["lastMessage"] as? String ?? ""
        let lastMessageTime = data["lastMessageTime"] as? String ?? ""
        var userData = UserDataChat()
        if let other = data["other"] as? NSDictionary{
            let id = other["id"] as? Int ?? 0
            let login = other["login"] as? String ?? ""
            let email = other["email"] as? String ?? ""
            let imageUrl = other["imageUrl"] as? String ?? ""
            let image = other["image"] as? String ?? ""
            let firstName = other["firstName"] as? String ?? ""
            let lastName = other["lastName"] as? String ?? ""
            userData = UserDataChat(id: id, login: login, langKey: "", email: email, imageUrl: imageUrl,image : image, firstName: firstName, lastName: lastName,dateOfBirth : "")
        }
        return Chats(blockChat: blockChat, id: id, lastMessage: lastMessage, lastMessageTime: lastMessageTime, other: userData)
    }
    

    
    func parseChatMessage(response : JSONArray) -> [ChatMessage]{
        var mapData = [ChatMessage]()
        for data in response{
            let id = data["id"] as? Int ?? 0
            let chatId = data["chatId"] as? Int ?? 0
            let mine = data["mine"] as? Bool ?? false
            let message = data["message"] as? String ?? ""
            let sentOn = data["sentOn"] as? String ?? ""
            var receiver = UserDataChat()
            if let other = data["receiver"] as? NSDictionary{
                let login = other["login"] as? String ?? ""
                let email = other["email"] as? String ?? ""
                let imageUrl = other["imageUrl"] as? String ?? ""
                let firstName = other["firstName"] as? String ?? ""
                let lastName = other["lastName"] as? String ?? ""
                receiver = UserDataChat(id: 0, login: login, langKey: "", email: email, imageUrl: imageUrl,image : "", firstName: firstName, lastName: lastName,dateOfBirth : "")
            }
            var sender = UserDataChat()
            if let other = data["sender"] as? NSDictionary{
                let login = other["login"] as? String ?? ""
                let email = other["email"] as? String ?? ""
                let imageUrl = other["imageUrl"] as? String ?? ""
                let firstName = other["firstName"] as? String ?? ""
                let lastName = other["lastName"] as? String ?? ""
                sender = UserDataChat(id: 0, login: login, langKey: "", email: email, imageUrl: imageUrl,image : "", firstName: firstName, lastName: lastName,dateOfBirth : "")
            }
            mapData.append(ChatMessage(chatId: chatId, id: id, message: message, mine: mine, receiver: receiver, sender: sender, sentOn: sentOn))
        }
        return mapData
    }
    
    func parseChatSingleMessage(data : JSONDictionary) -> ChatMessage{
        let id = data["id"] as? Int ?? 0
        let chatId = data["chatId"] as? Int ?? 0
        let mine = data["mine"] as? Bool ?? false
        let message = data["message"] as? String ?? ""
        let sentOn = data["sentOn"] as? String ?? ""
        var receiver = UserDataChat()
        if let other = data["receiver"] as? NSDictionary{
            let login = other["login"] as? String ?? ""
            let email = other["email"] as? String ?? ""
            let imageUrl = other["imageUrl"] as? String ?? ""
            let firstName = other["firstName"] as? String ?? ""
            let lastName = other["lastName"] as? String ?? ""
            receiver = UserDataChat(id: 0, login: login, langKey: "", email: email, imageUrl: imageUrl,image : "", firstName: firstName, lastName: lastName,dateOfBirth : "")
        }
        var sender = UserDataChat()
        if let other = data["sender"] as? NSDictionary{
            let login = other["login"] as? String ?? ""
            let email = other["email"] as? String ?? ""
            let imageUrl = other["imageUrl"] as? String ?? ""
            let firstName = other["firstName"] as? String ?? ""
            let lastName = other["lastName"] as? String ?? ""
            sender = UserDataChat(id: 0, login: login, langKey: "", email: email, imageUrl: imageUrl,image : "", firstName: firstName, lastName: lastName,dateOfBirth : "")
        }
        return ChatMessage(chatId: chatId, id: id, message: message, mine: mine, receiver: receiver, sender: sender, sentOn: sentOn)
    }
    
    func parseMessageToOpenChatSCreen(data : JSONDictionary) -> Chats{
        let chatId = data["chatId"] as? Int ?? 0
        let lastMessage = data["message"] as? String ?? ""
        let sentOn = data["sentOn"] as? String ?? ""
        var userData = UserDataChat()
        if let other = data["sender"] as? NSDictionary{
            let id = other["id"] as? Int ?? 0
            let login = other["login"] as? String ?? ""
            let email = other["email"] as? String ?? ""
            let imageUrl = other["imageUrl"] as? String ?? ""
            let image = other["image"] as? String ?? ""
            let firstName = other["firstName"] as? String ?? ""
            let lastName = other["lastName"] as? String ?? ""
            userData = UserDataChat(id: id, login: login, langKey: "", email: email, imageUrl: imageUrl,image : image, firstName: firstName, lastName: lastName,dateOfBirth : "")
        }
        
        return Chats(blockChat: false, id: chatId, lastMessage: lastMessage, lastMessageTime: sentOn, other: userData)
    }
    
    
}


struct GenderData {
    var id = 0
    var name = ""
    
    init(raw : NSDictionary) {
        self.id = raw["id"] as? Int ?? 0
        self.name = raw["name"] as? String ?? ""
    }
}

struct FAQData {
    var question = ""
    var answer = ""
    
    init(raw : NSDictionary) {
        self.question = raw["question"] as? String ?? ""
        self.answer = raw["answer"] as? String ?? ""
    }
}


struct BreakIceData {
    var id = 0
    var answer = ""
    var questionId = 0
    var question = ""
    
    init(raw : NSDictionary) {
        self.id = raw["id"] as? Int ?? 0
        self.answer = raw["answer"] as? String ?? ""
        if let question = raw["question"] as? NSDictionary{
            self.questionId = question["id"] as? Int ?? 0
            self.question = question["name"] as? String ?? ""
        }
    }
}


struct UserData {
    var id = 0
    var activityStatus = ""
    var aboutMe = ""
    var jobTitle = ""
    var phoneNumber = ""
    var employer = ""
    var height = 0
    var age = 0
    var genderName = ""
    var genderId = 0
    var educationId = 0
    var educationName = ""
    var email = ""
    var firstName = ""
    var lastName = ""
    var imageUrl = ""
    var login = ""
    var photosArray = [NSDictionary]()
    var questions = [NSDictionary]()
    
    
    init(response : NSDictionary) {
        self.id = response["id"] as? Int  ?? 0
        self.activityStatus = response["activityStatus"] as? String ?? ""
        self.aboutMe = response["aboutMe"] as? String ?? ""
        self.jobTitle = response["jobTitle"] as? String ?? ""
        self.phoneNumber = response["phoneNumber"] as? String ?? ""
        self.employer = response["employer"] as? String ?? ""
        self.height = response["height"] as? Int ?? 0
        self.age = response["age"] as? Int ?? 0
        if let gender = response["gender"] as? NSDictionary {
            self.genderId = gender["id"] as? Int ?? 0
            self.genderName = gender["name"] as? String ?? ""
        }
        if let education = response["education"] as? NSDictionary{
            self.educationId = education["id"] as? Int ?? 0
            self.educationName = education["name"] as? String ?? ""
        }
        if let user = response["user"] as? NSDictionary{
            self.email = user["email"] as? String ?? ""
            self.firstName = user["firstName"] as? String ?? ""
            self.imageUrl = user["imageUrl"] as? String ?? ""
            self.lastName = user["lastName"] as? String ?? ""
            self.login = user["login"] as? String ?? ""
        }
        self.photosArray = response["photos"] as? [NSDictionary] ?? [NSDictionary]()
        self.photosArray = self.photosArray.sorted(by: {($0["id"] as! Int) > ($1["id"] as! Int)})
//        self.questions = response["questions"] as? [NSDictionary] ?? [NSDictionary]()
        let unsorted = response["questions"] as? [NSDictionary] ?? [NSDictionary]()
        self.questions = unsorted.sorted(by: {(($0["question"] as? NSDictionary ?? [:]) ["id"] as? Int ?? 0) < (($1["question"] as? NSDictionary ?? [:]) ["id"] as? Int ?? 0)})
    }
}


struct UserDataChat {
    var id  = 0
    var login = ""
    var langKey = ""
    var email = ""
    var imageUrl = ""
    var image = ""
    var firstName = ""
    var lastName = ""
    var dateOfBirth = ""
}


