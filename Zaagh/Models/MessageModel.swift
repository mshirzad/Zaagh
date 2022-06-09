//
//  MessageModel.swift
//  Zaagh
//
//  Created by Mati Shirzad on 12/27/21.
//
import MessageKit

struct Message: MessageType{
    
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind

}

struct Sender: SenderType{
     
    var photoURL: String
    var senderId: String
    var displayName: String
    
}

extension MessageKind {
    var MessageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attr_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "vidoe"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_prev"
        case .custom(_):
            return "custom"
        }
    }
}
