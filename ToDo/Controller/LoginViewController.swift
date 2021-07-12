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
                if let e = error{
                    print(e)
                }else{
                    self.performSegue(withIdentifier: "LoginToDo", sender: self)
                }
            }
        }
        
        
    }
    

   

}
