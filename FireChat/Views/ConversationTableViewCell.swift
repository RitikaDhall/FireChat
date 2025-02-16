//
//  ConversationTableViewCell.swift
//  FireChat
//
//  Created by Ritika Dhall on 02/12/20.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 45
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    
    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 90,
                                     height: 90)
        
        userNameLabel.frame = CGRect(x: userImageView.right + 10,
                                     y: 10,
                                     width: contentView.width - userImageView.width - 30,
                                     height: (contentView.height - 20) / 2)
        
        userMessageLabel.frame = CGRect(x: userImageView.right + 10,
                                        y: userNameLabel.bottom,
                                        width: contentView.width - userImageView.width - 30,
                                        height: (contentView.height - 20) / 2)
    }
    
    public func configure(with model: Conversation) {
        
        userNameLabel.text = model.name
        userMessageLabel.text = model.latestMessage.text
        
        if !model.latestMessage.isRead {
            userMessageLabel.font = .systemFont(ofSize: 18, weight: .bold)
        }
        else {
            userMessageLabel.font = .systemFont(ofSize: 18, weight: .regular)
        }
        
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
                
            case .failure(let error):
                print("Failed to get image URL: \(error)")
            }
        })
    }
    
}
