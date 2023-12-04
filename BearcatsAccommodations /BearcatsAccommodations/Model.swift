//
//  Model.swift
//  BearcatsAccommodations
//
//  Created by  Bhargav Krishna Moparthy on 10/30/2023
//

import Foundation

struct HouseModel: Codable {
    
    var id: String?
    var user_id: String?
    var user_name: String?
    var city: String?
    var address: String?
    var area: String?
    var bedrooms: String?
    var bathrooms: String?
    var contact: String?
    var images: [String] = []
    
    
    init() {}
}


struct ChatListModel {
    
    var name: String?
    var id: String?
    
    init() {}
}




struct ChatModel {
    
    var date: String?
    var chats: [Chat]?
    
    init() {}
}

struct Chat{
    
    var id: String?
    var message: String?
    var date: String?
    var sender_id: String?
    var sender_name: String?
    var reveiver_id: String?
    var reveiver_name: String?
    var type: Int?
    var duration: Int?
    var url: String?
}
