//
//  DatabaseManager.swift
//  Zaagh
//
//  Created by Mati Shirzad on 12/1/21.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    static let shared = DatabaseManager()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-dot-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-at-")
        return safeEmail
    }
    
    private let database = Database.database().reference()
    
    typealias fetchUsersComplition = (Result<[[String: String]], Error>) -> Void
    typealias getAllConvsComplition = (Result<[Conversations], Error>) -> Void
    typealias getAllMsgForConvsComplition = (Result<[Message], Error>) -> Void
    
}

// -MARK: Conversation / Chat Managment

extension DatabaseManager{
    public func createNewConversation(with targetUserEmail: String, targetName: String, firstMessage: Message, completion: @escaping (Bool) -> Void){
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let senderName = UserDefaults.standard.value(forKey: "fullname") as? String else {
            print("can not get email or sendername from user defaults")
            completion(false)
            return
        }
        
        let senderEmail = DatabaseManager.safeEmail(emailAddress: email)
        let targetusersafeEmail = DatabaseManager.safeEmail(emailAddress: targetUserEmail)
        
        let ref = database.child("\(senderEmail)")
        let targetRef = database.child("\(targetusersafeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {return}
            guard var userNode = snapshot.value as? [String: Any] else {
                print("user does not exist")
                completion(false)
                return
            }
            
            let convID = "conversation_\(firstMessage.messageId)"
            let dateString = DateFormatter.customFormatter.string(from: firstMessage.sentDate)
            var messageBody = ""
            
            switch firstMessage.kind {
            
            case .text(let body):
                messageBody = body
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let newConversationElement: [String: Any] = [
                "id": convID,
                "targetUser": targetUserEmail,
                "targetName": targetName,
//                "senderName": senderName,
                "first_message": [
                    "date": dateString,
                    "msg_body": messageBody,
                    "is_read": false
                ]
            ]
            
            let recipientNewConversationElement: [String: Any] = [
                "id": convID,
                "targetUser": senderEmail,
                "targetName": senderName,
//                "senderName": senderName,
                "first_message": [
                    "date": dateString,
                    "msg_body": messageBody,
                    "is_read": false
                ]
            ]
            
            //update recipeint user entry
            
            targetRef.observeSingleEvent(of: .value, with: {snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //append
                    conversations.append(recipientNewConversationElement)
                    targetRef.setValue([conversations])
                    
                } else {
                    //create
                    targetRef.setValue([recipientNewConversationElement])
                }
            })
            
            //update current user entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //append to conversation Node
                conversations.append(newConversationElement)
                userNode["conversations"] = conversations
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        print("can not set the value in DB\(String(describing: error))")
                        completion(false)
                        return
                    }
//                    completion(true)
                    self?.createConvNodeInRootDB(with: convID,
                                                 targetUserEmail: targetUserEmail,
                                                 targetName: targetName,
                                                 firstMessage: firstMessage,
                                                 completion: completion)
                })
                
//                targetRef.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
//                    guard error == nil else {
//                        print("can not set the value in DB")
//                        completion(false)
//                        return
//                    }
////                    completion(true)
//                    self?.createConvNodeInRootDB(with: convID,
//                                                 targetUserEmail: targetUserEmail,
//                                                 targetName: targetName,
//                                                 firstMessage: firstMessage,
//                                                 completion: completion)
//                })
                
            } else {
                //create new conv Node
                userNode["conversations"] = [
                    newConversationElement
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        print("can not set the value in DB\(String(describing: error))")
                        completion(false)
                        return
                    }
//                    completion(true)
                    self?.createConvNodeInRootDB(with: convID,
                                                 targetUserEmail: targetUserEmail,
                                                 targetName: targetName,
                                                 firstMessage: firstMessage,
                                                 completion: completion)
                })
                
//                targetRef.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
//                    guard error == nil else {
//                        completion(false)
//                        print("can not set the value in DB")
//                        return
//                    }
////                    completion(true)
//                    self?.createConvNodeInRootDB(with: convID,
//                                                 targetUserEmail: targetUserEmail,
//                                                 targetName: targetName,
//                                                 firstMessage: firstMessage,
//                                                 completion: completion)
//                })
            }
            
        })
    }
    
    private func createConvNodeInRootDB(with convID: String, targetUserEmail: String, targetName: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String,
              let senderName = UserDefaults.standard.value(forKey: "fullname") as? String else {
            print("can not get email or sendername from user defaults")
            completion(false)
            return
        }
        
        let senderEmail = DatabaseManager.safeEmail(emailAddress: email)
        let dateString = DateFormatter.customFormatter.string(from: firstMessage.sentDate)
        var messageBody = ""
        
        switch firstMessage.kind {
        case .text(let body):
            messageBody = body
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let message: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.MessageKindString,
            "content": messageBody,
            "date": dateString,
            "senderEmail": senderEmail,
            "senderName": senderName,
//            "targetEmail": targetUserEmail,
//            "targetName": targetName,
            "is_read": false
        ]
        
        let value: [String: Any] = [
            "messagesCollection": [
                message
            ]
        ]
        
        database.child("\(convID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                print("can not update the value of conv in DB")
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    public func getAllConversations(for email: String, completion: @escaping getAllConvsComplition){
        
        //let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                print("can not observe the conv root in db")
                completion(.failure(DatabaseErrors.failedToFetchConvsDBError))
                return
            }
            print("before compactmap in getconvos")
            let conversations: [Conversations] = value.compactMap({dictionary in
                guard let conversationID = dictionary["id"] as? String,
                      let targetName = dictionary["targetName"] as? String,
                      let targetUser = dictionary["targetUser"] as? String,
                      let firstMessage = dictionary["first_message"] as? [String: Any],
                      let date = firstMessage["date"] as? String,
                      let msgBody = firstMessage["msg_body"] as? String,
                      let isRead = firstMessage["is_read"] as? Bool else {
                    return nil
                }
            print("after compact map in getconvos")
            let latestMessage = LatestMessage(isRead: isRead, date: date, body: msgBody)
            
            return Conversations(id: conversationID, targetName: targetName, targetUserEmail: targetUser, latestMessage: latestMessage)
            })
            
            completion(.success(conversations))
        })
        
    }
    
    public func getAllMessagesForConv(with convID: String, completion: @escaping getAllMsgForConvsComplition){
        database.child("\(convID)/messagesCollection").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                print("can not observe msg root in db")
                completion(.failure(DatabaseErrors.failedToFetchMessagesDBError))
                return
            }
            
            let messages: [Message] = value.compactMap({dictionary in
                guard let msgID = dictionary["id"] as? String,
//                      let targetName = dictionary["targetName"] as? String,
//                      let targetUser = dictionary["targetEmail"] as? String,
                      let senderEmail = dictionary["senderEmail"] as? String,
                      let senderName = dictionary["senderName"] as? String,
                      let type = dictionary["type"] as? String,
                      let stringDate = dictionary["date"] as? String,
                      let date = DateFormatter.customFormatter.date(from: stringDate),
                      let msgBody = dictionary["content"] as? String,
                        let isRead = dictionary["is_read"] as? Bool
                else {
                    return nil
                }
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: senderName)
                
                return Message(sender: sender, messageId: msgID, sentDate: date, kind: .text(msgBody))
            })
            
            completion(.success(messages))
        })
    }
    
    public func sendMessage(to convID: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void){
        database.child("\(convID)/messagesCollection").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var currentMessages = snapshot.value as? [[String:Any]] else {
                completion(false)
                return
            }
            
            guard let email = UserDefaults.standard.value(forKey: "email") as? String,
                  let senderName = UserDefaults.standard.value(forKey: "fullname") as? String else {
                print("can not get email or sendername from user defaults")
                completion(false)
                return
            }
            
            let senderEmail = DatabaseManager.safeEmail(emailAddress: email)
            let dateString = DateFormatter.customFormatter.string(from: newMessage.sentDate)
            var messageBody = ""
            
            switch newMessage.kind {
            case .text(let body):
                messageBody = body
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let message: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.MessageKindString,
                "content": messageBody,
                "date": dateString,
                "senderEmail": senderEmail,
                "senderName": senderName,
//                "targetEmail": targetUserEmail,
//                "targetName": targetName,
                "is_read": false
            ]
            
        }) // observe single event
    }
}

// -MARK: User Management

extension DatabaseManager {
    
    public func userExists(with email: String, compilation: @escaping ((Bool) -> Void)){
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-dot-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-at-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                compilation(false)
                return
            }
            compilation(true)
        })
    }
    
    public func inserNewUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safeEmail).setValue([
            "firstname": user.firstname,
            "lastname": user.lastname,
            "phonenumber": user.phonenumber
        ], withCompletionBlock: {
            error, _ in
            guard error == nil else {
                print("failed to write to DB")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: {snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    //append user to it
                    let newItem = [
                        "name": user.firstname + " " + user.lastname,
                        "email": user.safeEmail,
                        "phone": user.phonenumber
                    ]
                    usersCollection.append(newItem)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                } else {
                    //create collection
                    let newCollection : [[String: String]] = [
                        [
                            "name": user.firstname + " " + user.lastname,
                            "email": user.safeEmail,
                            "phone": user.phonenumber
                        ]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                }
            })
            
            
        })
    }
    
    public func fetchAllUsers(completion: @escaping fetchUsersComplition){
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.failedToFetchUsersDBError))
                return
            }
            completion(.success(value))
        })
    }
}

enum DatabaseErrors: Error {
    case failedToFetchUsersDBError
    case failedToFetchConvsDBError
    case failedToFetchMessagesDBError
}
