import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol ChatDetailViewControllerDelegate: AnyObject {
    func didSendMessage(_ message: ChatMessage, to friend: User)
}

class ChatDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var chatThread: ChatThread? // Thread containing messages and participants
    private var db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    private let currentUserID = Auth.auth().currentUser?.uid ?? ""
    weak var delegate: ChatDetailViewControllerDelegate?
    private let chatManager = FirestoreChatManager()
    
    private let tableView = UITableView()
    private let messageInputBar = UIView()
    private let inputTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupCustomTitleView()
        setupMessageInputComponents()
        setupTableView()
        fetchMessages() // Start listening for new messages
        
        if let chatThread = chatThread {
            removeNotificationForChatThread(chatThread)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let chatThread = chatThread,
           let lastMessage = chatThread.messages.last,
           let participant = chatThread.participants.first(where: { $0.id != currentUserID }) {
            delegate?.didSendMessage(lastMessage, to: participant)
        }
    }
    
    deinit {
        // Remove Firestore listener when the view controller is deallocated
        messagesListener?.remove()
    }
    
    private func setupCustomTitleView() {
        // Ensure participant exists
        guard let participant = chatThread?.participants.first(where: { $0.id != currentUserID }) else {
            print("No participant found other than the current user.")
            return
        }
        
        // Custom title view with profile image and name
        let titleView = UIStackView()
        titleView.axis = .horizontal
        titleView.alignment = .center
        titleView.spacing = 8
        
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 20
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.image = participant.profileImage ?? UIImage(named: "placeholder")
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let nameLabel = UILabel()
        nameLabel.text = participant.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .black
        
        titleView.addArrangedSubview(profileImageView)
        titleView.addArrangedSubview(nameLabel)
        navigationItem.titleView = titleView
    }
    
    private func setupMessageInputComponents() {
        messageInputBar.backgroundColor = .systemGray6
        view.addSubview(messageInputBar)
        
        messageInputBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageInputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        inputTextField.placeholder = "Message"
        inputTextField.borderStyle = .roundedRect
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.addSubview(inputTextField)
        
        sendButton.setTitle("Send", for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        messageInputBar.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            inputTextField.leadingAnchor.constraint(equalTo: messageInputBar.leadingAnchor, constant: 16),
            inputTextField.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor),
            inputTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            sendButton.trailingAnchor.constraint(equalTo: messageInputBar.trailingAnchor, constant: -16),
            sendButton.centerYAnchor.constraint(equalTo: messageInputBar.centerYAnchor)
        ])
        
        // Add an accessory toolbar with a Save button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let saveButton = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(handleSend))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleSpace, saveButton]
        
        inputTextField.inputAccessoryView = toolbar
    }
    
    private func setupTableView() {
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.backgroundColor = .white
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageInputBar.topAnchor)
        ])
    }
    
    @objc private func handleSend() {
        guard let text = inputTextField.text, !text.isEmpty, let chatThread = chatThread else { return }
        
        chatManager.sendMessage(chatThread: chatThread, messageContent: text, senderID: currentUserID) { [weak self] success in
            if success {
                DispatchQueue.main.async {
                    self?.inputTextField.text = nil
                    self?.fetchMessages()
                    if let friend = chatThread.participants.first(where: { $0.id != self?.currentUserID }), let message = chatThread.messages.last {
                        self?.delegate?.didSendMessage(message, to: friend)
                    }
                }
            } else {
                print("Failed to send message")
            }
        }
    }
    
    private func fetchMessages() {
        guard let chatThread = chatThread else { return }
        
        messagesListener = db.collection("chats")
            .document(chatThread.id)
            .collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let newMessages = documents.compactMap { doc -> ChatMessage? in
                    let data = doc.data()
                    let id = doc.documentID
                    let senderID = data["senderId"] as? String ?? ""
                    let messageContent = data["messageContent"] as? String ?? ""
                    let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                    
                    // Find sender details
                    let sender = chatThread.participants.first { $0.id == senderID } ?? User(id: senderID, name: "Unknown")
                    
                    return ChatMessage(id: id, sender: sender, messageContent: messageContent, timestamp: timestamp, isSender: senderID == self.currentUserID)
                }
                
                self.chatThread?.messages = newMessages
                self.tableView.reloadData()
                self.scrollToBottom()
            }
    }
    
    private func scrollToBottom() {
        DispatchQueue.main.async {
            let rowCount = self.chatThread?.messages.count ?? 0
            if rowCount > 0 {
                let indexPath = IndexPath(row: rowCount - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatThread?.messages.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatMessageCell", for: indexPath) as! ChatMessageCell
        if let message = chatThread?.messages[indexPath.row] {
            cell.configure(with: message)
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    private func removeNotificationForChatThread(_ chatThread: ChatThread) {
        db.collection("notifications")
            .whereField("senderId", in: chatThread.participants.map { $0.id })
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching notifications: \(error)")
                    return
                }
                
                snapshot?.documents.forEach { document in
                    document.reference.delete { error in
                        if let error = error {
                            print("Error deleting notification: \(error)")
                        }
                    }
                }
            }
    }
}
