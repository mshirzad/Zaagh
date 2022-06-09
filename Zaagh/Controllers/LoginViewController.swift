//
//  LoginViewController.swift
//  Zaagh
//
//  Created by Mati Shirzad on 11/21/21.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FBSDKLoginKit
import GoogleSignIn
import JGProgressHUD

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        
        return scrollView
    }()
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    private let emailField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.borderWidth = 0.5
        field.layer.cornerRadius = 5
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = UIColor.systemGray6
        field.placeholder = "Email or username"
        
        return field
    }()
    
    private let passwordField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.borderWidth = 0.5
        field.layer.cornerRadius = 5
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = UIColor.systemGray6
        field.placeholder = "Password"
        field.isSecureTextEntry = true
        
        return field
    }()

    private let loginButton: UIButton = {
       let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    private let ORTextLable: UITextView = {
       let textLabel = UITextView()
        
        textLabel.text = "or"
        textLabel.textAlignment = .center
        textLabel.font = .systemFont(ofSize: 20)
        textLabel.textColor = .gray
        textLabel.isSelectable = false
        
        return textLabel
    }()
    
    private let fbLoginButton: FacebookButton = {
        let button = FacebookButton()
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.permissions = ["public_profile", "email"]
        
        return button
    }()
    
    private let googleLoginButton : GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = GIDSignInButtonStyle(rawValue: 1)!
        
        return button
    }()
    
    private var loginObserver : NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Login"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLoginNotification, object: nil, queue: .main,
                        using: {[weak self] _ in
                            guard let strongSelf = self else { return }
                            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                        })
        
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        fbLoginButton.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        
        //Sub Views Here
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(ORTextLable)
        scrollView.addSubview(fbLoginButton)
        scrollView.addSubview(googleLoginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x:(scrollView.width-size)/2,
                                 y:20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x:15,
                                  y:imageView.bottom+10,
                                  width: scrollView.width-30,
                                 height: 40)
        passwordField.frame = CGRect(x:15,
                                  y:emailField.bottom+10,
                                  width: scrollView.width-30,
                                 height: 40)
        loginButton.frame = CGRect(x:15,
                                  y:passwordField.bottom+10,
                                  width: scrollView.width-30,
                                 height: 40)
        ORTextLable.frame = CGRect(x:15,
                                  y:loginButton.bottom+40,
                                  width: scrollView.width-30,
                                 height: 40)
        fbLoginButton.frame = CGRect(x:15,
                                  y:ORTextLable.bottom+10,
                                  width: scrollView.width-30,
                                 height: 40)
        googleLoginButton.frame = CGRect(x:12.5,
                                  y:fbLoginButton.bottom+10,
                                  width: scrollView.width-25,
                                 height: 80)
        
        
    }
    
    @objc private func loginTapped(){
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty,
              !password.isEmpty else {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view, animated: true)
        
        // Firebase here
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {
            [weak self] authResult, error in
            
            guard let strongSelf = self else { return }
            
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard authResult != nil, error == nil else {
                print("error signin user")
                return
            }
            print("Logged in Success")
            let fullname = FirebaseAuth.Auth.auth().currentUser?.displayName
            
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue(fullname, forKey: "fullname")
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            
        })
        
    }
    
    @objc private func didTapRegister() {
        emailField.text = ""
        passwordField.text = ""
        let vc = RegisterViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func alertUserLoginError(){
        let alert = UIAlertController(title: "Error",
                                      message: "Please Check Your Credintial",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginTapped()
        }
        
        return true
    }
}

/// Facebook delegate

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        //nothing here for now
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
        let spinner = JGProgressHUD(style: .dark)
        spinner.show(in: view, animated: true)
        
        guard let token = result?.token?.tokenString else {
            return
        }
   
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start(completion: {[weak self] connection, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Fiald FB Graph request")
                return
            }
//            print("\(result)")
            
            let firstName = result["first_name"] as? String ?? ""
            let lastName = result["last_name"] as? String ?? ""
            let email : String = result["email"] as? String ?? result["id"] as! String
            let picture = result["picture"] as? [String: Any]
            let data = picture?["data"] as? [String: Any]
            let picture_url = data?["url"] as? String ?? ""
            
            let fullname = firstName + " " + lastName
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue(fullname, forKey: "fullname")
            
            let chatUser = ChatAppUser(firstname: firstName,
                                       lastname: lastName,
                                       emailAddress: email,
                                       phonenumber: "")
            
            DatabaseManager.shared.userExists(with: email, compilation: { exist in
                if !exist {
                    DatabaseManager.shared.inserNewUser(with: chatUser, completion: {created in
                        if created {
                            //upload image
                            guard let url = URL(string: picture_url) else {
                                return
                            }
                            print("dowloading profile picture form FB")
                            print(url)
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _ , _ in
                                guard let data = data else {
                                    print("failed to download profile pic from FB")
                                    return
                                }
                                let filename = chatUser.profilePictureFileName
                                print("uplodaing to firebase")
                                StorageManager.shared.uploadProfilePicture(fileName: filename, data: data, completion: { result in
                                    
                                    switch result {
                                    case .success(let downloadURL):
                                        print(downloadURL)
                                    case .failure(let error):
                                        print("\(error)")
                                    }
                                })
                            }).resume()
                        }
                    })
                }
            })
            
            
            //Firebase login
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: {[weak self] authResult, error in
                guard let strongSelf = self else { return }
                guard authResult != nil, error == nil else {
                    return
                }
                print("Success Login with FB")
                strongSelf.spinner.dismiss()
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            })
            
        })
        
    }
    
    
}

/// Google Delegate

extension LoginViewController: GIDSignInUIDelegate{
    
}
