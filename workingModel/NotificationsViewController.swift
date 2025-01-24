import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class NotificationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ChatDetailViewControllerDelegate {
    private let tableView = UITableView()
    private var notifications: [NotificationItem] = []
    private var db = Firestore.firestore()
    private var chatsListener: ListenerRegistration?
    private let currentUserID = Auth.auth().currentUser?.uid ?? ""

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
                
                self.fetchUserDetails(senderID: senderID, timestamp: timestamp)
            }
    }

    private func fetchUserDetails(senderID: String, timestamp: Date) {
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
            
            let notification = NotificationItem(senderId: senderID, name: name, profileImageURL: profileImageURL, timestamp: timestamp)
            self.notifications.append(notification)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
        let chatDetailVC = ChatDetailViewController()
        // Ensure chatThread is properly initialized and passed
        chatDetailVC.chatThread = getChatThread(for: notification.senderId)
        chatDetailVC.delegate = self
        navigationController?.pushViewController(chatDetailVC, animated: true)
    }

    // MARK: - ChatDetailViewControllerDelegate
    
    func chatDetailViewControllerDidOpenChat(chatThread: ChatThread) {
        // Remove notifications related to this chat thread
        notifications.removeAll { $0.senderId == chatThread.participants.first(where: { $0.id != currentUserID })?.id }
        tableView.reloadData()
    }
    
    private func getChatThread(for senderId: String) -> ChatThread? {
        // Implement logic to retrieve or create a ChatThread object based on senderId
        // This is a placeholder implementation and should be replaced with actual logic
        return nil
    }
}
