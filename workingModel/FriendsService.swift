import FirebaseFirestore
import FirebaseAuth

class FriendsService {
    static let shared = FriendsService()
    
    private let db = Firestore.firestore()
    
    // Fetch User Details using uid
    func fetchUserDetails(uid: String, completion: @escaping (User?, Error?) -> Void) {
        print("Fetching user details for UID: \(uid)")
        db.collection("users").whereField("uid", isEqualTo: uid).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching user details: \(error)")
                completion(nil, error)
            } else if let snapshot = snapshot, !snapshot.isEmpty {
                let userDocument = snapshot.documents.first
                if let user = try? userDocument?.data(as: User.self) {
                    print("Fetched user details: \(user)")
                    completion(user, nil)
                } else {
                    print("Failed to decode user details")
                    completion(nil, nil)
                }
            } else {
                print("No user document found for UID: \(uid)")
                completion(nil, nil)
            }
        }
    }

    // Send Friend Request
    func sendFriendRequest(fromUserID: String, toUserID: String, completion: @escaping (Bool, Error?) -> Void) {
        print("Sending friend request from \(fromUserID) to \(toUserID)")
        let request = FriendRequest(id: UUID().uuidString, fromUserID: fromUserID, toUserID: toUserID)
        db.collection("friend_requests").document(request.id).setData([
            "id": request.id,
            "fromUserID": request.fromUserID,
            "toUserID": request.toUserID
        ]) { error in
            if let error = error {
                print("Error sending friend request: \(error)")
                completion(false, error)
            } else {
                print("Friend request sent successfully")
                completion(true, nil)
            }
        }
    }

    // Accept Friend Request
    func acceptFriendRequest(requestID: String, completion: @escaping (Bool, Error?) -> Void) {
        print("Accepting friend request with ID: \(requestID)")
        db.collection("friend_requests").document(requestID).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching friend request: \(error)")
                completion(false, error)
                return
            }
            
            guard let data = document?.data(),
                  let fromUserID = data["fromUserID"] as? String,
                  let toUserID = data["toUserID"] as? String else {
                print("Invalid friend request data")
                completion(false, nil)
                return
            }
            
            let friend = Friend(id: UUID().uuidString, userID: fromUserID, friendID: toUserID)
            self?.db.collection("friends").document(friend.id).setData([
                "id": friend.id,
                "userID": friend.userID,
                "friendID": friend.friendID
            ]) { error in
                if let error = error {
                    print("Error adding friend: \(error)")
                    completion(false, error)
                } else {
                    self?.db.collection("friend_requests").document(requestID).delete { error in
                        if let error = error {
                            print("Error deleting friend request: \(error)")
                            completion(false, error)
                        } else {
                            print("Friend request accepted and deleted successfully")
                            completion(true, nil)
                        }
                    }
                }
            }
        }
    }

    // Remove Friend
    func removeFriend(friendID: String, completion: @escaping (Bool, Error?) -> Void) {
        print("Removing friend with ID: \(friendID)")
        db.collection("friends").document(friendID).delete { error in
            if let error = error {
                print("Error removing friend: \(error)")
                completion(false, error)
            } else {
                print("Friend removed successfully")
                completion(true, nil)
            }
        }
    }

    // Fetch Friends
    func fetchFriends(forUserID userID: String, completion: @escaping ([Friend]?, Error?) -> Void) {
        print("Fetching friends for user with ID: \(userID)")
        db.collection("friends").whereField("userID", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching friends: \(error)")
                completion(nil, error)
                return
            }
            
            let friends = snapshot?.documents.compactMap { document -> Friend? in
                try? document.data(as: Friend.self)
            }
            print("Fetched friends: \(String(describing: friends))")
            completion(friends, nil)
        }
    }

    // Fetch Friend Requests
    func fetchFriendRequests(forUserID userID: String, completion: @escaping ([FriendRequest]?, Error?) -> Void) {
        print("Fetching friend requests for user with ID: \(userID)")
        db.collection("friend_requests").whereField("toUserID", isEqualTo: userID).getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching friend requests: \(error)")
                completion(nil, error)
                return
            }
            
            let requests = snapshot?.documents.compactMap { document -> FriendRequest? in
                try? document.data(as: FriendRequest.self)
            }
            print("Fetched friend requests: \(String(describing: requests))")
            completion(requests, nil)
        }
    }

    // Fetch All Users
    func fetchAllUsers(completion: @escaping ([User]?, Error?) -> Void) {
        print("Fetching all users")
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching all users: \(error)")
                completion(nil, error)
                return
            }
            
            let users = snapshot?.documents.compactMap { document -> User? in
                try? document.data(as: User.self)
            }
            print("Fetched all users: \(String(describing: users))")
            completion(users, nil)
        }
    }

    // Fetch Users Excluding Friends
    func fetchUsersExcludingFriends(currentUserID: String, completion: @escaping ([User]?, Error?) -> Void) {
        print("Fetching users excluding friends of user with ID: \(currentUserID)")
        fetchFriends(forUserID: currentUserID) { [weak self] friends, error in
            if let error = error {
                print("Error fetching friends: \(error)")
                completion(nil, error)
                return
            }
            
            let friendIDs = friends?.map { $0.friendID } ?? []
            print("Fetched friends: \(friendIDs)")
            
            self?.fetchAllUsers { users, error in
                if let error = error {
                    print("Error fetching all users: \(error)")
                    completion(nil, error)
                    return
                }
                
                let filteredUsers = users?.filter { !friendIDs.contains($0.id) && $0.id != currentUserID }
                print("Filtered users excluding friends: \(String(describing: filteredUsers))")
                completion(filteredUsers, nil)
            }
        }
    }
}
