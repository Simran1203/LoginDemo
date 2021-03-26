//
//  AuthManager.swift
//  Simran_Login_Module
//
//  Created by Simran Kaur on 26/03/21.
//

import RxSwift
typealias JSONDictionary = [String: Any]

enum AutenticationError: Error {
    case server
    case badReponse
    case badCredentials
}

enum AutenticationStatus {
    case none
    case error(AutenticationError)
    case user
}

class AuthManager {
    
    let status = Variable(AutenticationStatus.none)
    
    static var sharedManager = AuthManager()
    
    fileprivate init() {}
    
    func login(_ email: String, password: String) -> Observable<AutenticationStatus> {
        
        var dict = [String:String]()
        dict["email"] = email;
        dict["password"] = password;
        
        let url = URL(string: "http://imaginato.mocklab.io/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: dict)
        
        return URLSession.shared.rx.json(request: request)
            .map {
                guard let root = $0 as? JSONDictionary else {
                    return .error(.badCredentials)
                }
                
                if(root["result"] as! Int == 1){
                    let data = root["data"] as! [String:Any]
                    let userDict = data["user"] as! [String:Any]
                    
                    let creationDate = userDict["created_at"] as! String
                    
                    let user = User(created_at: creationDate.getFormattedDate() ,user_id: userDict["userId"] as! Int, user_name: userDict["userName"] as! String)
              
                    // Save Data to User Defaults
                    let encoder = JSONEncoder()
                    let userData = try encoder.encode(user)
                    UserDefaults.standard.setValue(userData, forKey: "user_details")
                    UserDefaults.standard.synchronize()
                    
                    return .user
                }
                else{
                    return .error(.badCredentials)
                }
            }
            .catchErrorJustReturn(.error(.badCredentials))
    }
    
}


extension String{
    
    func getFormattedDate() -> Date{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: self)!
    }
}
