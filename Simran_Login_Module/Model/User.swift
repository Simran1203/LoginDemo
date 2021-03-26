//
//  User.swift
//  Simran_Login_Module
//
//  Created by Simran Kaur on 26/03/21.
//

import UIKit

class User: Codable {
    
    var created_at: Date
    var user_id: Int
    var user_name: String
    
    init(created_at: Date,user_id: Int, user_name: String) {
        self.created_at = created_at
        self.user_id = user_id
        self.user_name = user_name
     }
}
