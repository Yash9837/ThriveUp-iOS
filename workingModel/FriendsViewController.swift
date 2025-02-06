import UIKit
import FirebaseFirestore

class FriendsViewController: UIViewController {
    var currentUser: User?
    var friends: [Friend] = []
    var userCache: [String: User] = [:]  // Cache to store fetched user details

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        fetchFriends()
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FriendCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func fetchFriends() {
        guard let currentUser = currentUser else { return }
        FriendsService.shared.fetchFriends(forUserID: currentUser.id) { [weak self] friends, error in
            if let error = error {
                print("Error fetching friends: \(error)")
                return
            }
            self?.friends = friends ?? []
            self?.fetchUserDetailsForFriends()
        }
    }

    private func fetchUserDetailsForFriends() {
        let dispatchGroup = DispatchGroup()
        for friend in friends {
            if userCache[friend.friendID] == nil {
                dispatchGroup.enter()
                FriendsService.shared.fetchUserDetails(uid: friend.friendID) { [weak self] user, error in
                    if let user = user {
                        self?.userCache[friend.friendID] = user
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }

    private func removeFriend(_ friend: Friend?) {
        guard let friend = friend else { return }
        FriendsService.shared.removeFriend(friendID: friend.id) { [weak self] success, error in
            if let error = error {
                print("Error removing friend: \(error)")
                return
            }
            self?.friends.removeAll { $0.id == friend.id }
            self?.userCache.removeValue(forKey: friend.friendID)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension FriendsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath)
        let friend = friends[indexPath.row]
        
        if let user = userCache[friend.friendID] {
            cell.textLabel?.text = user.name
        } else {
            cell.textLabel?.text = "Loading..."
            FriendsService.shared.fetchUserDetails(uid: friend.friendID) { [weak self] user, error in
                if let user = user {
                    self?.userCache[friend.friendID] = user
                    DispatchQueue.main.async {
                        if let visibleIndexPath = tableView.indexPath(for: cell), visibleIndexPath == indexPath {
                            cell.textLabel?.text = user.name
                        }
                    }
                }
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let friend = friends[indexPath.row]
        // Handle friend selection
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] (_, _, completionHandler) in
            let friend = self?.friends[indexPath.row]
            self?.removeFriend(friend)
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}
