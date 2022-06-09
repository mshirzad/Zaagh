//
//  RegisterViewController.swift
//  Zaagh
//
//  Created by Mati Shirzad on 11/21/21.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        
        return scrollView
    }()
    
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
//        imageView.layer.borderWidth = 1
//        imageView.layer.borderColor = UIColor.lightGray.cgColor
        
        return imageView
    }()
    
    private let firstNameField: UITextField = {
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
        field.placeholder = "First Name"
        
        return field
    }()
    
    private let lastNameField: UITextField = {
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
        field.placeholder = "Last Name"
        
        return field
    }()
    
    private let phoneNumberField: UITextField = {
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
        field.placeholder = "Phone Number (Optional)"
        
        return field
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
    
    private let repeatPasswordField: UITextField = {
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
        field.placeholder = "Confirm Password"
        field.isSecureTextEntry = true
        
        return field
    }()
    
    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Register", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .white
        
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
        firstNameField.delegate = self
        lastNameField.delegate = self
        phoneNumberField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        repeatPasswordField.delegate = self
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicTapped))
        gesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(gesture)
        
        scrollView.isUserInteractionEnabled = true
        imageView.isUserInteractionEnabled = true
        
        //Sub Views Here
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(phoneNumberField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(repeatPasswordField)
        scrollView.addSubview(registerButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        
        imageView.frame = CGRect(x:(scrollView.width-size)/2,
                                 y:20,
                                 width: size,
                                 height: size)
        imageView.layer.cornerRadius = imageView.width/2
        firstNameField.frame = CGRect(x:15,
                                      y:imageView.bottom+10,
                                      width: scrollView.width-30,
                                      height: 40)
        lastNameField.frame = CGRect(x:15,
                                     y:firstNameField.bottom+10,
                                     width: scrollView.width-30,
                                     height: 40)
        phoneNumberField.frame = CGRect(x:15,
                                        y:lastNameField.bottom+10,
                                        width: scrollView.width-30,
                                        height: 40)
        emailField.frame = CGRect(x:15,
                                  y:phoneNumberField.bottom+10,
                                  width: scrollView.width-30,
                                  height: 40)
        passwordField.frame = CGRect(x:15,
                                     y:emailField.bottom+10,
                                     width: scrollView.width-30,
                                     height: 40)
        repeatPasswordField.frame = CGRect(x:15,
                                           y:passwordField.bottom+10,
                                           width: scrollView.width-30,
                                           height: 40)
        registerButton.frame = CGRect(x:15,
                                      y:repeatPasswordField.bottom+10,
                                      width: scrollView.width-30,
                                      height: 40)
        
    }
    
    @objc private func changeProfilePicTapped(){
        presentPhotoActionSheet()
    }
    
    @objc private func registerTapped(){
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        phoneNumberField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        repeatPasswordField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let phoneNumber = phoneNumberField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {
            alertUserLoginError(msg: "Please Enter All the information")
            return
        }
        
        guard let password = passwordField.text,
              let r_password = repeatPasswordField.text,
              password == r_password else {
            alertUserLoginError(msg: "Password didn't match")
            return
        }
        
        spinner.show(in: view, animated: true)
        
        // Firebase here
        
        DatabaseManager.shared.userExists(with: email, compilation: { [weak self] exists in
            
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            
            guard !exists else {
                strongSelf.alertUserLoginError(msg: "Email already used")
                return
            }
            
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {
                authResult, error in
    
                guard authResult != nil, error == nil else {
                    print("error creating user")
                    return
                }
                
                let chatUser = ChatAppUser(firstname: firstName, lastname: lastName, emailAddress: email, phonenumber: phoneNumber)
                
                DatabaseManager.shared.inserNewUser(with: chatUser, completion: {created in
                    if created{
                        //upload image
                        guard let image = strongSelf.imageView.image,
                              let data = image.pngData() else {
                            return
                        }
                        let filename = chatUser.profilePictureFileName
                        
                        StorageManager.shared.uploadProfilePicture(fileName: filename, data: data, completion: { result in
                            
                            switch result {
                            case .success(let downloadURL):
                                UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                print(downloadURL)
                            case .failure(let error):
                                print("\(error)")
                            }
                        })
                    }
                })
                
                let fullname = firstName + " " + lastName
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue(fullname, forKey: "fullname")

                print("creating user Success")
                
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                
            })
            
        })
        
    }
    
    func alertUserLoginError(msg:String){
        let alert = UIAlertController(title: "Error",
                                      message: msg,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}


extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameField {
            lastNameField.becomeFirstResponder()
        } else if textField == lastNameField {
            phoneNumberField.becomeFirstResponder()
        } else if textField == phoneNumberField {
            emailField.becomeFirstResponder()
        } else if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            repeatPasswordField.becomeFirstResponder()
        } else if textField == repeatPasswordField {
            registerTapped()
        }
        
        return true
    }
}


extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func presentPhotoActionSheet(){
        let actionSheet = UIAlertController(title: "Choose Profile Photo", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentCamera()
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.presentImagePicker()
                                            }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    func presentImagePicker(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        self.imageView.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
