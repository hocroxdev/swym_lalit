//
//  EventsDM.swift
//  SYWM
//
//  Created by Maninder Singh on 08/03/20.
//  Copyright © 2020 Maninder Singh. All rights reserved.
//

import Foundation

struct Event {
    var id = 0
    var name = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var city = ""
    var state = ""
    var country = ""
    var location = ""
    var descrip = ""
    var startDate : Double = 0
    var endDate : Double = 0
    var sponsored = false
    var sponsorName = ""
    var sponsorCode = ""
    var levelOfSponsor = ""
    var creator = Createor()
}

struct Createor {
    var login = ""
    var firstName = ""
    var lastName = ""
    var email = ""
    var imaheUrl = ""
}

struct ConnectionsReceived {
    var id = 0
    var fromUser : UserData?
    var toUser : UserData?
    var requestStatus = ""
    var toUsr = 0
}

extension EventVM{
    
    
    func parseGetEventsResponse(response : JSONArray){
        for data in response{
            let id = data["id"] as? Int ?? 0
            let city = data["city"] as? String ?? ""
            let state = data["state"] as? String ?? ""
            let country = data["country"] as? String ?? ""
            let location = data["location"] as? String ?? ""
            let latitude = data["latitude"] as? Double ?? 0.0
            let longitude = data["longitude"] as? Double ?? 0.0
            let name = data["name"] as? String ?? ""
            let descrip = data["descrip"] as? String ?? ""
            let startDate = data["startDate"] as? Double ?? 0
            let endDate = data["endDate"] as? Double ?? 0
            let sponsored = data["sponsored"] as? Bool ?? false
            let sponsorName = data["sponsorName"] as? String ?? ""
            let sponsorCode = data["sponsorCode"] as? String ?? ""
            let levelOfSponsor = data["levelOfSponsor"] as? String ?? ""
            var creatorData = Createor()
            if let creator = data["creator"] as? NSDictionary{
                let login = creator["login"] as? String ?? ""
                let firstName = creator["firstName"] as? String ?? ""
                let email = creator["email"] as? String ?? ""
                let lastName = creator["lastName"] as? String ?? ""
                let imageUrl = creator["imageUrl"] as? String ?? ""
                creatorData = Createor(login: login, firstName: firstName, lastName: lastName, email: email, imaheUrl: imageUrl)
            }
            self.evetns.append(Event(id: id, name: name, latitude: latitude, longitude: longitude, city: city, state: state,country : country, location: location, descrip: descrip, startDate: startDate, endDate: endDate, sponsored: sponsored, sponsorName: sponsorName, sponsorCode: sponsorCode, levelOfSponsor: levelOfSponsor, creator: creatorData))
        }
    }
    
    func parseSingleEventsResponse(data : JSONDictionary) -> Event{
            let id = data["id"] as? Int ?? 0
            let city = data["city"] as? String ?? ""
            let state = data["state"] as? String ?? ""
            let country = data["country"] as? String ?? ""
            let location = data["location"] as? String ?? ""
            let latitude = data["latitude"] as? Double ?? 0.0
            let longitude = data["longitude"] as? Double ?? 0.0
            let name = data["name"] as? String ?? ""
            let descrip = data["descrip"] as? String ?? ""
            let startDate = data["startDate"] as? Double ?? 0
            let endDate = data["endDate"] as? Double ?? 0
            let sponsored = data["sponsored"] as? Bool ?? false
            let sponsorName = data["sponsorName"] as? String ?? ""
            let sponsorCode = data["sponsorCode"] as? String ?? ""
            let levelOfSponsor = data["levelOfSponsor"] as? String ?? ""
            var creatorData = Createor()
            if let creator = data["creator"] as? NSDictionary{
                let login = creator["login"] as? String ?? ""
                let firstName = creator["firstName"] as? String ?? ""
                let email = creator["email"] as? String ?? ""
                let lastName = creator["lastName"] as? String ?? ""
                let imageUrl = creator["imageUrl"] as? String ?? ""
                creatorData = Createor(login: login, firstName: firstName, lastName: lastName, email: email, imaheUrl: imageUrl)
            }
            return Event(id: id, name: name, latitude: latitude, longitude: longitude, city: city, state: state,country : country, location: location, descrip: descrip, startDate: startDate, endDate: endDate, sponsored: sponsored, sponsorName: sponsorName, sponsorCode: sponsorCode, levelOfSponsor: levelOfSponsor, creator: creatorData)
    }
    
    
    
    func parseConnectionsReceive(data: JSONArray) -> [ConnectionsReceived]{
        var conn = [ConnectionsReceived]()
        for dataDict in data{
            let id = dataDict["id"] as? Int ?? 0
            var from : UserData?
            var to : UserData?
            if let fromUser = dataDict["fromUser"] as? NSDictionary{
                from = UserData(response: fromUser)
            }
            if let toUser = dataDict["toUser"] as? NSDictionary{
                to = UserData(response: toUser)
            }
            let status = dataDict["requestStatus"] as? String ?? ""
            let con = ConnectionsReceived(id: id, fromUser: from, toUser: to, requestStatus: status, toUsr: 0)
            conn.append(con)
        }
        return conn
    }
    
    func parseConnectionsReceive1(dataDict: JSONDictionary) -> ConnectionsReceived{
        let id = dataDict["id"] as? Int ?? 0
        var from : UserData?
        var to : UserData?
        if let fromUser = dataDict["fromUser"] as? NSDictionary{
            from = UserData(response: fromUser)
        }
        if let toUser = dataDict["toUser"] as? NSDictionary{
            to = UserData(response: toUser)
        }
        let status = dataDict["requestStatus"] as? String ?? ""
        let con = ConnectionsReceived(id: id, fromUser: from, toUser: to, requestStatus: status, toUsr: 0)
        return con
    }
    
}
