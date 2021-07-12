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
                if let e = error{
                    print(e)
                }else{
                    self.performSegue(withIdentifier: "RegisterToDo", sender: self)
                }
            }
        }
    }
    
    
}
