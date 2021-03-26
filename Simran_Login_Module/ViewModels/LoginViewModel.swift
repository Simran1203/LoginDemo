//
//  LoginViewModel.swift
//  Simran_Login_Module
//
//  Created by Simran Kaur on 26/03/21.
//

import RxSwift
import RxCocoa
import RxSwiftUtilities

struct LoginViewModel {
    
    let activityIndicator = ActivityIndicator()
    
    let credentialsValid: Driver<Bool>
    
    init(emailText: Driver<String>, passwordText: Driver<String>) {
       
        let emailValidator = EmailValidator()
        let passwordValidator = PasswordValidator()
        
        
        let emailValid = emailText
            .distinctUntilChanged()
            .throttle(0.3)
            .map(emailValidator.validate(_:))
        
        
        let passwordValid = passwordText
            .distinctUntilChanged()
            .throttle(0.3)
            .map(passwordValidator.validate(_:))
 
        credentialsValid = Driver.combineLatest(emailValid, passwordValid) { $0 && $1 }
        
    }
    
    func login(_ username: String, password: String) -> Observable<AutenticationStatus> {
        return AuthManager.sharedManager.login(username, password: password)
    }
    
}


// Validators

final class EmailValidator {

    func validate(_ input: String) -> Bool {
        guard
            let regex = try? NSRegularExpression(
                pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
                options: [.caseInsensitive]
            )
        else {
            assertionFailure("Regex not valid")
            return false
        }

        let regexFirstMatch = regex
            .firstMatch(
                in: input,
                options: [],
                range: NSRange(location: 0, length: input.count)
            )

        return regexFirstMatch != nil
    }
}

final class PasswordValidator {

    func validate(_ input: String) -> Bool {
        
        // Upper Letter Regex
        guard
            let regexUpperLetter = try? NSRegularExpression(
                pattern:  ".*[A-Z]+.*"
            )
        else {
            assertionFailure("Regex not valid")
            return false
        }
        
        let regexUpperLetterMatch = regexUpperLetter
            .firstMatch(
                in: input,
                options: [],
                range: NSRange(location: 0, length: input.count)
            )
        
        // Lower Letter Regex
        guard
            let regexLowerLetter = try? NSRegularExpression(
                pattern:  ".*[a-z]+.*"
            )
        else {
            assertionFailure("Regex not valid")
            return false
        }
        
        let regexLowerLetterMatch = regexLowerLetter
            .firstMatch(
                in: input,
                options: [],
                range: NSRange(location: 0, length: input.count)
            )
        
        // Number Regex
        guard
            let regexNumber = try? NSRegularExpression(
                pattern:  ".*[0-9]+.*"
            )
        else {
            assertionFailure("Regex not valid")
            return false
        }
        
        let regexNumberMatch = regexNumber
            .firstMatch(
                in: input,
                options: [],
                range: NSRange(location: 0, length: input.count)
            )
        
        return regexUpperLetterMatch != nil  && regexLowerLetterMatch != nil && regexNumberMatch != nil && input.count <= 16
    }
}
