//
//  ChatAppUserModel.swift
//  Zaagh
//
//  Created by Mati Shirzad on 12/27/21.
//

import Foundation

struct ChatAppUser {
    let firstname : String
    let lastname : String
    let emailAddress : String
    let phonenumber : String
    
    var safeEmail : String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-dot-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-at-")
        return safeEmail
    }
    
    var profilePictureFileName : String {
        return "\(safeEmail)_profile_picture.png"
    }
    
}
