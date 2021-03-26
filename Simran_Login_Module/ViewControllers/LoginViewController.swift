//
//  LoginViewController.swift
//  Simran_Login_Module
//
//  Created by Simran Kaur on 26/03/21.
//

import UIKit
import RxSwift
import RxCocoa


class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        let gr = UITapGestureRecognizer()
        gr.numberOfTapsRequired = 1
        tableView.addGestureRecognizer(gr)
        gr.rx.event.asObservable()
            .subscribe(onNext: { [unowned self] _ in
                self.hideKeyboard()
            })
            .addDisposableTo(disposeBag)
        
        let viewModel = LoginViewModel(emailText: emailTextField.rx.text.orEmpty.asDriver(),
                                       passwordText: passwordTextField.rx.text.orEmpty.asDriver())
        
        viewModel.credentialsValid
            .drive(onNext: { [unowned self] valid in
                if(valid){
                    self.loginButton.backgroundColor = .blue
                }
                else{
                    self.loginButton.backgroundColor = .gray
                }
                self.loginButton.isEnabled = valid
            })
            .addDisposableTo(disposeBag)
        
        loginButton.rx.tap
            .withLatestFrom(viewModel.credentialsValid)
            .filter { $0 }
            .flatMapLatest { [unowned self] valid -> Observable<AutenticationStatus> in
                viewModel.login(self.emailTextField.text!, password: self.passwordTextField.text!)
                    //  .trackActivity(activityIndicator)
                    .observeOn(SerialDispatchQueueScheduler(qos: .userInteractive))
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] autenticationStatus in
                switch autenticationStatus {
                case .none:
                    break
                case .user:
                    self.showMessage()
                    break
                case .error(let error):
                    self.showError(error)
                }
                AuthManager.sharedManager.status.value = autenticationStatus
            })
            .addDisposableTo(disposeBag)
        
    }
    
    fileprivate func hideKeyboard() {
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    fileprivate func showMessage() {
        let alert = UIAlertController(title: "Success", message: "User logged in successfully", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        self.navigationController?.present(alert, animated: true, completion: nil)
    }
    
    
    fileprivate func showError(_ error: AutenticationError) {
        let title: String
        let message: String
        
        switch error {
        case .server, .badReponse:
            title = "An error occuried"
            message = "Server error"
        case .badCredentials:
            title = "Bad credentials"
            message = "This user don't exist"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === emailTextField {
            passwordTextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return false
    }
    
}
