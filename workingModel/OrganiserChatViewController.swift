// Yash's Mackbook

import UIKit
import FirebaseAuth

class OrganiserChatViewController: UIViewController {
    let tableView = UITableView()
    let chatManager = FirestoreChatManager()

    var users: [User] = [] // Users who sent messages
    var currentUser: User? // Current logged-in organiser

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Chats"
        setupTableView()
        fetchCurrentUser()
        fetchUsersWhoSentMessages()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ChatCell.self, forCellReuseIdentifier: "ChatCell")
        tableView.rowHeight = 80
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
                self.fetchUsersWhoSentMessages()
            } else {
                print("Current user not found in users collection.")
            }
        }
    }

    private func fetchUsersWhoSentMessages() {
        guard let currentUser = currentUser else { return }

        chatManager.fetchUsersWhoMessaged(to: currentUser.id) { [weak self] users in
            guard let self = self else { return }
            self.users = users
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    private func startChat(with otherUser: User) {
        guard let currentUser = currentUser else {
            print("Current user is nil. Cannot start chat.")
            return
        }

        chatManager.fetchOrCreateChatThread(for: currentUser, with: otherUser) { [weak self] thread in
            guard let self = self, let thread = thread else {
                print("Error creating or fetching chat thread.")
                return
            }

            DispatchQueue.main.async {
                let chatDetailVC = ChatDetailViewController()
                chatDetailVC.chatThread = thread
                self.navigationController?.pushViewController(chatDetailVC, animated: true)
            }
        }
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate

extension OrganiserChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath) as? ChatCell else {
            return UITableViewCell()
        }

        let user = users[indexPath.row]

        // Configure the cell with user details
        cell.configure(
            with: user.name,
            message: "Last message will appear here", // You can modify this to fetch the last message
            time: "", // You can also add timestamp here
            user: user
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = users[indexPath.row]
        startChat(with: selectedUser)
    }
}
