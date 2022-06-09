//
//  ConversationTableViewCell.swift
//  Zaagh
//
//  Created by Mati Shirzad on 1/1/22.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {

    public static let identifier = "ConversationCellID"
    
    private let userAvetarView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        
        return label
    }()
    
    private let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.numberOfLines = 0
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userAvetarView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(lastMessageLabel)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            
        userAvetarView.frame = CGRect(x: 10, y: 10, width: 75, height: 75)
        
        userNameLabel.frame = CGRect(x: userAvetarView.right+10,
                                     y: 10,
                                     width: contentView.width - userAvetarView.width - 20,
                                     height: (contentView.height-20)/2)
        
        lastMessageLabel.frame = CGRect(x: userAvetarView.right+10,
                                        y: userNameLabel.bottom+5,
                                        width: contentView.width - userAvetarView.width - 20,
                                        height: (contentView.height-20)/2)
    }
    
    public func configure(with model: Conversations){
        self.userNameLabel.text = model.targetName
        self.lastMessageLabel.text = model.latestMessage.body
        
        let path = "profile_images/\(model.targetUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, complition: {[weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userAvetarView.sd_setImage(with: url, completed: nil)
                    self?.userAvetarView.makeRounded()
                }
            case .failure(let error):
                print(path)
                print("failed to down profile Image \(error)")
            }
        })
        
    }
    
}
