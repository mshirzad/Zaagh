//
//  ChatViewController.swift
//  Zaagh
//
//  Created by Mati Shirzad on 12/8/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {

    public let targetUserEmail: String
    public let targetName: String
    public var isnewConversation = false
    
    private let conversationID: String?
    private var messages = [Message]()
    private var me: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let name = UserDefaults.standard.value(forKey: "fullname") as? String else {
            print("can not get email or name form userdefaults inside sender creation")
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: name)
    }
    
    init(with targetUserEmail: String, targetName: String, id: String?){
        self.targetUserEmail = targetUserEmail
        self.targetName = targetName
        self.conversationID = id
        super.init(nibName: nil, bundle: nil)
        
        if let conversationID = conversationID {
            fetchMessages(for: conversationID, shouldScrolltoBottm: true)
            print("fetchmessagaes called form init on CHatviewContr")
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
    private func createMsgID() -> String? {
        guard let me = self.me else { return nil }
        
        let targetUser = self.targetUserEmail
        let senderEmail = DatabaseManager.safeEmail(emailAddress: me.senderId)
        let dateString = DateFormatter.customFormatter.string(from: Date())
        
        return "\(targetUser)_\(senderEmail)_\(dateString)"
    }
    
    private func fetchMessages(for convID: String, shouldScrolltoBottm: Bool){
        DatabaseManager.shared.getAllMessagesForConv(with: convID, completion: {[weak self] result in
            switch result{
            case .success(let msg):
                guard !msg.isEmpty else { return }
                self?.messages = msg
                print("inside the fetchmasg success case")
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrolltoBottm{
                        self?.messagesCollectionView.scrollToBottom(animated: true)
                    }
                    
                }
                
            case .failure(let error):
                print("failed to get msgs \(error)")
            }
        })
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let me = self.me,
              let msgID = createMsgID() else { return }
        
        let message = Message(sender: me,
                              messageId: msgID,
                              sentDate: Date(),
                              kind: .text(text))
        // send the message
        if isnewConversation {
            //create conv in db
            print("sending...:  \(text)")
            DatabaseManager.shared.createNewConversation(with: targetUserEmail,targetName: targetName, firstMessage: message, completion: {[weak self] success in
                if success {
                    self?.isnewConversation = false
                    print("msg sent SUCCESS")
                } else {
                    print("error sending msg")
                }
            })
        } else {
            // append to existing conv
//            DatabaseManager.shared.sendMessage(to: targetUserEmail, message: message, completion: {success in 
//                if success {
//                    print("messeges loaded")
//                } else {
//                    print("not loaded")
//                }
//            })
        }
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate{
    
    func currentSender() -> SenderType {
        if let sender = me {
            return sender
        }
        fatalError("Cannot Get the Sender Email from UserDefaults")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
