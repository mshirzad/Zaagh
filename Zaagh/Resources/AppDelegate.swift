//
//  AppDelegate.swift
//  Zaagh
//
//  Created by Mati Shirzad on 11/21/21.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        FirebaseApp.configure()
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        
        return GIDSignIn.sharedInstance().handle(
            url,
            sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    //Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {
                print("Cannot login with Google \(error)")
            }
            return
        }
        
        guard let firstName = user.profile.givenName,
              let lastName = user.profile.familyName,
              let email = user.profile.email else {
            return
        }
        let fullname = firstName + " " + lastName
        UserDefaults.standard.setValue(email, forKey: "email")
        UserDefaults.standard.setValue(fullname, forKey: "fullname")
        
        let chatUser = ChatAppUser(firstname: firstName,
                                   lastname: lastName,
                                   emailAddress: email,
                                   phonenumber: "")
        
        DatabaseManager.shared.userExists(with: email, compilation: { exist in
            if !exist {
                DatabaseManager.shared.inserNewUser(with: chatUser, completion: {
                    created in
                    if created {
                        // uploade image
                        if user.profile.hasImage{
                            guard let url = user.profile.imageURL(withDimension: 400) else {
                                return
                            }
                            print(url)
                            print("dowloading profile picture form Google")
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _ , _ in
                                print("before guarding the data")
                                guard let data = data else {
                                    print("failed to download profile pic from google")
                                    return
                                }
                                let filename = chatUser.profilePictureFileName
                                print("uplodaing to firebase")
                                StorageManager.shared.uploadProfilePicture(fileName: filename, data: data, completion: { result in
                                    
                                    switch result {
                                    case .success(let downloadURL):
                                        UserDefaults.standard.set(downloadURL, forKey: "profile_picture_url")
                                        print(downloadURL)
                                    case .failure(let error):
                                        print("\(error)")
                                    }
                                })
                            }).resume()
                        }
                    }
                })
            }
        })
        
        guard let auth = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: auth.idToken, accessToken: auth.accessToken)
        
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: {authResult, error in
            guard authResult != nil, error == nil else {
                return
            }
            print("Logged in success with Google")
            NotificationCenter.default.post(name: .didLoginNotification, object: nil)
        })
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("User disconnected")
    }
    
}

