//
//  StorageManager.swift
//  Zaagh
//
//  Created by Mati Shirzad on 12/15/21.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    ///Upload Profile Picture
    
    public typealias uploadProfilePictureCompletion = (Result<String, Error>) -> Void
    public typealias downloadURLCompletion = (Result<URL, Error>) -> Void
    
    public func uploadProfilePicture(fileName: String, data: Data, completion: @escaping uploadProfilePictureCompletion) {
        
        storage.child("profile_images/\(fileName)").putData(data, metadata: nil, completion: {
            metadata, error in
            guard error == nil else {
                print("failed to upload profile picture")
                completion(.failure(StorageErrors.failedToUploadPicture))
                return
            }
            
            self.storage.child("profile_images/\(fileName)").downloadURL(completion: {
                url, error in
                guard let url = url else {
                    print("failed to download the profile picture url")
                    completion(.failure(StorageErrors.failedToDownloadURL))
                    return
                }
                let urlString = url.absoluteString
                completion(.success(urlString))
            })
            
        })
        
    }
    
    public func downloadURL(for path: String, complition: @escaping downloadURLCompletion) {
        let reference = storage.child(path)
        
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                complition(.failure(StorageErrors.failedToDownloadURL))
                return
            }
            complition(.success(url))
        })
    }
    
    public enum StorageErrors: Error {
        case failedToUploadPicture
        case failedToDownloadURL
    }
    
}
