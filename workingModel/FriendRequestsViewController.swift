import UIKit
import FirebaseFirestore

class FriendRequestsViewController: UIViewController {
    var currentUser: User?
    var friendRequests: [FriendRequest] = []
    var users: [User] = []
    var filteredUsers: [User] = []
    var userCache: [String: User] = [:]  // Cache to store fetched user details
    var sentFriendRequests: [User] = []  // Store sent friend requests

    let tableView = UITableView()
    let segmentedControl = UISegmentedControl(items: ["Accept", "Send"])
    let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Friend Requests"
        setupSegmentedControl()
        setupSearchBar()
        setupTableView()
        fetchFriendRequests()
        fetchUsersExcludingFriendsAndRequests()
    }

    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search users"
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RequestCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func segmentChanged() {
        tableView.reloadData()
    }

    private func fetchFriendRequests() {
        guard let currentUser = currentUser else { return }
        FriendsService.shared.fetchFriendRequests(forUserID: currentUser.id) { [weak self] requests, error in
            if let error = error {
                print("Error fetching friend requests: \(error)")
                return
            }
            self?.friendRequests = requests ?? []
            self?.fetchUserDetailsForRequests()
        }
    }

    private func fetchUserDetailsForRequests() {
        let dispatchGroup = DispatchGroup()
        for request in friendRequests {
            if userCache[request.fromUserID] == nil {
                dispatchGroup.enter()
                FriendsService.shared.fetchUserDetails(uid: request.fromUserID) { [weak self] user, error in
                    if let user = user {
                        self?.userCache[request.fromUserID] = user
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }

    private func fetchUsersExcludingFriendsAndRequests() {
        guard let currentUser = currentUser else { return }
        FriendsService.shared.fetchUsersExcludingFriendsAndRequests(currentUserID: currentUser.id) { [weak self] users, error in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            self?.users = users ?? []
            self?.filteredUsers = self?.users ?? []
            self?.tableView.reloadData()
        }
    }

    private func acceptFriendRequest(_ request: FriendRequest) {
        FriendsService.shared.acceptFriendRequest(requestID: request.id) { [weak self] success, error in
            if let error = error {
                print("Error accepting friend request: \(error)")
                return
            }
            self?.friendRequests.removeAll { $0.id == request.id }
            self?.fetchUsersExcludingFriendsAndRequests()
            self?.tableView.reloadData()
        }
    }

    private func rejectFriendRequest(_ request: FriendRequest) {
        FriendsService.shared.removeFriendRequest(requestID: request.id) { [weak self] success, error in
            if let error = error {
                print("Error rejecting friend request: \(error)")
                return
            }
            self?.friendRequests.removeAll { $0.id == request.id }
            self?.fetchUsersExcludingFriendsAndRequests()
            self?.tableView.reloadData()
        }
    }

    private func sendFriendRequest(to user: User) {
        guard let currentUser = currentUser else { return }
        FriendsService.shared.sendFriendRequest(fromUserID: currentUser.id, toUserID: user.id) { [weak self] success, error in
            if let error = error {
                print("Error sending friend request: \(error)")
                return
            }
            self?.sentFriendRequests.append(user)
            self?.tableView.reloadData()
        }
    }

    private func unsendFriendRequest(to user: User) {
        guard let currentUser = currentUser else { return }
        FriendsService.shared.unsendFriendRequest(fromUserID: currentUser.id, toUserID: user.id) { [weak self] success, error in
            if let error = error {
                print("Error unsending friend request: \(error)")
                return
            }
            self?.sentFriendRequests.removeAll { $0.id == user.id }
            self?.tableView.reloadData()
        }
    }
}

extension FriendRequestsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentedControl.selectedSegmentIndex == 0 ? friendRequests.count : (sentFriendRequests.count + filteredUsers.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RequestCell", for: indexPath)
        if segmentedControl.selectedSegmentIndex == 0 {
            let request = friendRequests[indexPath.row]
            if let user = userCache[request.fromUserID] {
                cell.textLabel?.text = user.name
            } else {
                cell.textLabel?.text = "Loading..."
                FriendsService.shared.fetchUserDetails(uid: request.fromUserID) { [weak self] user, error in
                    if let user = user {
                        self?.userCache[request.fromUserID] = user
                        DispatchQueue.main.async {
                            if let visibleIndexPath = tableView.indexPath(for: cell), visibleIndexPath == indexPath {
                                cell.textLabel?.text = user.name
                            }
                        }
                    }
                }
            }
            cell.accessoryType = .none
        } else {
            if indexPath.row < sentFriendRequests.count {
                let user = sentFriendRequests[indexPath.row]
                cell.textLabel?.text = user.name + " (Sent)"
                cell.accessoryType = .disclosureIndicator
            } else {
                let user = filteredUsers[indexPath.row - sentFriendRequests.count]
                cell.textLabel?.text = user.name
                cell.accessoryType = .disclosureIndicator
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if segmentedControl.selectedSegmentIndex == 0 {
            let request = friendRequests[indexPath.row]
            if let user = userCache[request.fromUserID] {
                let alert = UIAlertController(title: "Friend Request", message: "Accept or Reject friend request from \(user.name)?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { _ in
                    self.acceptFriendRequest(request)
                }))
                alert.addAction(UIAlertAction(title: "Reject", style: .destructive, handler: { _ in
                    self.rejectFriendRequest(request)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        } else {
            if indexPath.row < sentFriendRequests.count {
                let user = sentFriendRequests[indexPath.row]
                let alert = UIAlertController(title: "Unsend Friend Request", message: "Unsend friend request to \(user.name)?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Unsend", style: .destructive, handler: { _ in
                    self.unsendFriendRequest(to: user)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            } else {
                let user = filteredUsers[indexPath.row - sentFriendRequests.count]
                let alert = UIAlertController(title: "Send Friend Request", message: "Send friend request to \(user.name)?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Send", style: .default, handler: { _ in
                    self.sendFriendRequest(to: user)
                }))
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension FriendRequestsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        tableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
