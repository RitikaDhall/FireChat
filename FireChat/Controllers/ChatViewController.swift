//
//  ChatViewController.swift
//  FireChat
//
//  Created by Ritika Dhall on 04/11/20.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date    
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}

private var messages = [Message]()
private let selfSender = Sender(senderId: "1",
                                displayName: "Joe Smith",
                                photoURL: "")

class ChatViewController: MessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello World message")))
        
        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello World message. Hello World message. Hello World message. Hello World message. Hello World message.")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}
