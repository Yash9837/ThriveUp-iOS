import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {
    let tableView = UITableView()
    let chatManager = FirestoreChatManager()
    let searchBar = UISearchBar()
    let titleLabel = UILabel()
    let friendsButton = UIButton(type: .system)
    let titleStackView = UIStackView()
    let friendRequestsButton = UIButton(type: .system)

    var friends: [User] = [] // Friends fetched from Firestore
    var filteredFriends: [User] = [] // Friends filtered by search
    var currentUser: User? // Current logged-in user
    var lastMessages: [String: ChatMessage] = [:] // Last messages for each friend
    var messageListeners: [String: ListenerRegistration] = [:] // Listeners for each chat thread
    private var db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTitleStackView()
        setupSearchBar()
        setupTableView()
        fetchCurrentUser()
    }

    deinit {
        // Remove all listeners
        messageListeners.values.forEach { $0.remove() }
    }

    private func setupTitleStackView() {
        // Configure titleLabel
        titleLabel.text = "Chat"
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        titleLabel.textAlignment = .left

        // Configure friendsButton
        friendsButton.setTitle("Friends", for: .normal)
        friendsButton.addTarget(self, action: #selector(openFriendsViewController), for: .touchUpInside)

        // Configure friendRequestsButton
        friendRequestsButton.setTitle("Requests", for: .normal)
        friendRequestsButton.addTarget(self, action: #selector(openFriendRequestsViewController), for: .touchUpInside)

        // Configure titleStackView
        titleStackView.axis = .horizontal
        titleStackView.alignment = .center
        titleStackView.distribution = .equalSpacing
        titleStackView.spacing = 8

        // Add titleLabel and buttons to titleStackView
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(friendsButton)
        titleStackView.addArrangedSubview(friendRequestsButton)

        // Add titleStackView to the view
        view.addSubview(titleStackView)
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search friends"
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatCell.self, forCellReuseIdentifier: ChatCell.identifier)
        tableView.rowHeight = 80
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func openFriendsViewController() {
        let friendsVC = FriendsViewController()
        friendsVC.currentUser = currentUser
        navigationController?.pushViewController(friendsVC, animated: true)
    }

    @objc private func openFriendRequestsViewController() {
        let friendRequestsVC = FriendRequestsViewController()
        friendRequestsVC.currentUser = currentUser
        let navController = UINavigationController(rootViewController: friendRequestsVC)
        navController.modalPresentationStyle = .pageSheet
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
        }
        present(navController, animated: true, completion: nil)
    }

    private func fetchCurrentUser() {
        guard let firebaseUser = Auth.auth().currentUser else {
            print("No user is logged in")
            return
        }

        let currentUserID = firebaseUser.uid
        chatManager.fetchUsers { [weak self] users in
            guard let self = self else { return }

            if let currentUser = users.first(where: { $0.id == currentUserID }) {
                self.currentUser = currentUser
                self.fetchFriends(for: currentUser)
            } else {
                print("Current user not found in users collection.")
            }
        }
    }

    private func fetchFriends(for user: User) {
        FriendsService.shared.fetchFriends(forUserID: user.id) { [weak self] friends, error in
            if let error = error {
                print("Error fetching friends: \(error)")
                return
            }
            let friendIDs = friends?.map { $0.friendID } ?? []
            self?.fetchFriendDetails(for: friendIDs)
        }
    }

    private func fetchFriendDetails(for friendIDs: [String]) {
        let dispatchGroup = DispatchGroup()
        var fetchedFriends: [User] = []

        for friendID in friendIDs {
            dispatchGroup.enter()
            FriendsService.shared.fetchUserDetails(uid: friendID) { user, error in
                if let user = user {
                    fetchedFriends.append(user)
                }
                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.friends = fetchedFriends
            self?.filteredFriends = fetchedFriends
            self?.fetchLastMessages()
            self?.addMessageListeners()
        }
    }

    private func fetchLastMessages() {
        let dispatchGroup = DispatchGroup()
        guard let currentUser = currentUser else { return }

        for friend in friends {
            dispatchGroup.enter()
            chatManager.fetchOrCreateChatThread(for: currentUser.id, with: friend.id) { [weak self] thread in
                guard let self = self, let thread = thread else {
                    dispatchGroup.leave()
                    return
                }
                self.chatManager.fetchLastMessage(for: thread, currentUserID: currentUser.id) { message in
                    if let message = message {
                        self.lastMessages[friend.id] = message
                    }
                    dispatchGroup.leave()
                }
            }
        }

        dispatchGroup.notify(queue: .main) { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func addMessageListeners() {
        guard let currentUser = currentUser else { return }

        for friend in friends {
            chatManager.fetchOrCreateChatThread(for: currentUser.id, with: friend.id) { [weak self] thread in
                guard let self = self, let thread = thread else { return }
                let listener = self.db.collection("chats")
                    .document(thread.id)
                    .collection("messages")
                    .order(by: "timestamp", descending: true)
                    .limit(to: 1)
                    .addSnapshotListener { [weak self] (snapshot: QuerySnapshot?, error: Error?) in
                        guard let self = self else { return }
                        if let error = error {
                            print("Error listening for messages: \(error)")
                            return
                        }
                        guard let document = snapshot?.documents.first else { return }
                        let data = document.data()
                        let messageContent = data["messageContent"] as? String ?? ""
                        let senderId = data["senderId"] as? String ?? ""
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()

                        let sender = thread.participants.first { $0.id == senderId } ?? User(id: senderId, name: "Unknown")
                        let message = ChatMessage(id: document.documentID, sender: sender, messageContent: messageContent, timestamp: timestamp, isSender: senderId == currentUser.id)

                        self.lastMessages[friend.id] = message
                        self.tableView.reloadData()
                    }
                self.messageListeners[thread.id] = listener
            }
        }
    }

    private func startChat(with friend: User) {
        guard let currentUser = currentUser else {
            print("Current user is nil. Cannot start chat.")
            return
        }

        chatManager.fetchOrCreateChatThread(for: currentUser.id, with: friend.id) { [weak self] thread in
            guard let self = self, let thread = thread else {
                print("Error creating or fetching chat thread.")
                return
            }

            DispatchQueue.main.async {
                let chatDetailVC = ChatDetailViewController()
                chatDetailVC.chatThread = thread
                chatDetailVC.delegate = self
                self.navigationController?.pushViewController(chatDetailVC, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredFriends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }

        let friend = filteredFriends[indexPath.row]
        let lastMessage = lastMessages[friend.id]
        let messageText = lastMessage?.messageContent ?? "Tap to start a chat"
        let messageTime = lastMessage?.formattedTime() ?? ""

        cell.configure(
            with: friend.name,
            message: messageText,
            time: messageTime,
            profileImageURL: friend.profileImageURL
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFriend = filteredFriends[indexPath.row]
        startChat(with: selectedFriend)
    }
}

// MARK: - UISearchBarDelegate

extension ChatViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredFriends = friends
        } else {
            filteredFriends = friends.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - ChatDetailViewControllerDelegate

extension ChatViewController: ChatDetailViewControllerDelegate {
    func didSendMessage(_ message: ChatMessage, to friend: User) {
        lastMessages[friend.id] = message
        tableView.reloadData()
    }
}
