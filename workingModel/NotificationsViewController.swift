import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatDetailViewControllerDelegate {
    private let tableView = UITableView()
    private var notifications: [NotificationItem] = []
    private var handledNotificationIDs: Set<String> = Set(UserDefaults.standard.array(forKey: "handledNotificationIDs") as? [String] ?? []) // Load handled notifications from UserDefaults
    private var db = Firestore.firestore()
    private var chatsListener: ListenerRegistration?
    private let currentUserID = Auth.auth().currentUser?.uid ?? ""
    private let chatManager = FirestoreChatManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        title = "Notifications"

        setupTableView()
        listenForNewMessages()
    }
    
    deinit {
        // Remove Firestore listener when the view controller is deallocated
        chatsListener?.remove()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(NotificationCell.self, forCellReuseIdentifier: NotificationCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
        tableView.separatorStyle = .singleLine

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func listenForNewMessages() {
        chatsListener = db.collection("chats")
            .whereField("participants", arrayContains: currentUserID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching chat threads: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                for doc in documents {
                    self.listenForMessages(in: doc.documentID)
                }
            }
    }

    private func listenForMessages(in chatID: String) {
        db.collection("chats").document(chatID).collection("messages")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                
                guard let document = snapshot?.documents.first else { return }
                
                let data = document.data()
                let senderID = data["senderId"] as? String ?? ""
                let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                let messageID = document.documentID

                // Check if the notification has already been handled
                if !self.handledNotificationIDs.contains(messageID) {
                    self.fetchUserDetails(senderID: senderID, timestamp: timestamp, messageID: messageID)
                }
            }
    }

    private func fetchUserDetails(senderID: String, timestamp: Date, messageID: String) {
        db.collection("users").document(senderID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching user details: \(error)")
                return
            }
            
            guard let document = document, document.exists else { return }
            
            let data = document.data()
            let name = data?["name"] as? String ?? "Unknown"
            let profileImageURL = data?["profileImageURL"] as? String ?? ""
            
            // Validate the URL scheme
            if let url = URL(string: profileImageURL), ["gs", "http", "https"].contains(url.scheme) {
                let notification = NotificationItem(
                    id: messageID, // Use message ID as the notification ID
                    senderId: senderID,
                    name: name,
                    profileImageURL: profileImageURL,
                    timestamp: timestamp
                )
                self.notifications.append(notification)
                self.handledNotificationIDs.insert(messageID) // Add to handled notifications
                
                // Store notification in Firestore
                self.db.collection("notifications").document(notification.id).setData([
                    "id": notification.id,
                    "senderId": notification.senderId,
                    "name": notification.name,
                    "profileImageURL": notification.profileImageURL,
                    "timestamp": Timestamp(date: notification.timestamp)
                ])
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                print("Invalid URL scheme for profileImageURL: \(profileImageURL)")
            }
        }
    }

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationCell.identifier, for: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]
        cell.configure(with: notification)
        return cell
    }

    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Open chat detail view controller
        let notification = notifications[indexPath.row]
        fetchChatThread(for: notification.senderId) { chatThread in
            guard let chatThread = chatThread else { return }
            let chatDetailVC = ChatDetailViewController()
            chatDetailVC.chatThread = chatThread
            chatDetailVC.delegate = self
            self.navigationController?.pushViewController(chatDetailVC, animated: true)
            
            // Remove notification from Firestore
            self.removeNotificationFromFirestore(notification: notification)
        }
    }

    // MARK: - ChatDetailViewControllerDelegate
    
    func chatDetailViewControllerDidOpenChat(chatThread: ChatThread) {
        // Remove notifications related to this chat thread
        notifications.removeAll { $0.senderId == chatThread.participants.first(where: { $0.id != currentUserID })?.id }
        tableView.reloadData()
    }
    
    private func fetchChatThread(for senderId: String, completion: @escaping (ChatThread?) -> Void) {
        chatManager.fetchOrCreateChatThread(for: currentUserID, with: senderId) { chatThread in
            completion(chatThread)
        }
    }
    
    private func removeNotificationFromFirestore(notification: NotificationItem) {
        db.collection("notifications").document(notification.id).delete { error in
            if let error = error {
                print("Error removing notification: \(error)")
            } else {
                // Ensure the notification is not added again
                self.handledNotificationIDs.insert(notification.id)
                // Save handled notifications to UserDefaults
                UserDefaults.standard.set(Array(self.handledNotificationIDs), forKey: "handledNotificationIDs")
            }
        }
    }
}
