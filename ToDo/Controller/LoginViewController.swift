//
//  LoginViewController.swift
//  ToDo
//
//  Created by Quan on 11/07/2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var loginEmail: UITextField!
    
    @IBOutlet weak var loginPassword: UITextField!
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func loginPressed(_ sender: UIButton) {
        if let email = loginEmail.text, let password = loginPassword.text{
            Auth.auth().signIn(withEmail:email , password: password) {authResult, error in
                if error != nil {
                    if let err = error as NSError?, let code = AuthErrorCode(rawValue: err.code) {
                       switch code {
                       case .wrongPassword:
                        self.showAlert(title: "Sai mật khẩu!", message: "Vui lòng nhập lại")
                       case .userNotFound:
                        self.showAlert(title: "Không tìm thấy tài khoản", message: "Vui lòng đăng kí")
                       case .invalidEmail:
                        self.showAlert(title: "Sai định dạng Email", message: "Vui lòng nhập lại")
                       default:print(err)
                                   break
                       }
                    }
                      
                }else{
                    self.performSegue(withIdentifier: "LoginToDo", sender: self)
                }
            }
        }
        
        
    }
    func showAlert(title:String,message:String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        self.loginEmail.text = ""
        self.loginPassword.text = ""
    }
   
   

}
