//
//  ConversationModel.swift
//  Zaagh
//
//  Created by Mati Shirzad on 1/1/22.
//

import Foundation

struct Conversations {
    let id: String
    let targetName: String
    let targetUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let isRead: Bool
    let date: String
    let body: String
}
