//
//  RegisterViewController.swift
//  ToDo
//
//  Created by Quan on 11/07/2021.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var registerEmail: UITextField!
    
    @IBOutlet weak var registerPassword: UITextField!
    
    
    
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
    
    @IBAction func RegisterPressed(_ sender: UIButton) {
        if let email = registerEmail.text, let password = registerPassword.text{
            Auth.auth().createUser(withEmail:email , password: password) {authResult, error in
                if error != nil {
                    if let err = error as NSError?, let code = AuthErrorCode(rawValue: err.code) {
                       switch code {
                       case .emailAlreadyInUse:
                        self.showAlert(title:"Đã tồn tại email", message: "Vui lòng chọn email khác")
                       case .weakPassword:
                        self.showAlert(title: "Mật khẩu yếu", message: "Vui lòng nhập lại")
                       case .invalidEmail:
                        self.showAlert(title: "Sai định dạng Email", message: "Vui lòng nhập lại")
                        
                       default:print(err)
                                   break
                       }
                    }
                }else{
                    self.performSegue(withIdentifier: "RegisterToDo", sender: self)
                }
            }
        }
    }
    func showAlert(title:String,message:String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
        self.registerEmail.text = ""
        self.registerPassword.text = ""
    }
   
    
}
