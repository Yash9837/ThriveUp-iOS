//
//  DataModel.swift
//  workingModel
//
//  Created by Yash's Mackbook on 12/11/24.
//

import Foundation
import UIKit
import FirebaseFirestore




struct Speaker: Codable {
    let name: String
    let imageURL: String
}

struct EventModel: Codable {
    let eventId : String
    let title: String
    let category: String
    let attendanceCount: Int
    let organizerName: String
    let date: String
    let time: String
    let location: String
    let locationDetails: String
    var imageName: String
    let speakers: [Speaker]
    let description: String?
    var latitude: Double? // New property
        var longitude: Double? // New property
}
extension EventModel {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        eventId = try container.decode(String.self, forKey: .eventId)
        title = try container.decode(String.self, forKey: .title)
        category = try container.decode(String.self, forKey: .category)
        attendanceCount = try container.decodeIfPresent(Int.self, forKey: .attendanceCount) ?? 0
        organizerName = try container.decode(String.self, forKey: .organizerName)
        date = try container.decode(String.self, forKey: .date)
        time = try container.decode(String.self, forKey: .time)
        location = try container.decode(String.self, forKey: .location)
        locationDetails = try container.decodeIfPresent(String.self, forKey: .locationDetails)!
        imageName = try container.decodeIfPresent(String.self, forKey: .imageName)!
        speakers = try container.decodeIfPresent([Speaker].self, forKey: .speakers) ?? []
        description = try container.decodeIfPresent(String.self, forKey: .description)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
    }
}

func fetchEvents(completion: @escaping ([EventModel]?, Error?) -> Void) {
    let db = Firestore.firestore()
    
    db.collection("events").getDocuments { snapshot, error in
        if let error = error {
            completion(nil, error)
            return
        }

        guard let documents = snapshot?.documents else {
            completion([], nil)
            return
        }

        let events = documents.compactMap { doc -> EventModel? in
            let data = doc.data()
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: data)
                let event = try JSONDecoder().decode(EventModel.self, from: jsonData)
                return event
            } catch {
                print("Error decoding event: \(error.localizedDescription)")
                return nil
            }
        }

        completion(events, nil)
    }
}
struct CategoryModel {
    let name: String?
    var events: [EventModel]
}
struct FormField {
    let placeholder: String
    var value: String
}

let formFields = [
    FormField(placeholder: "Name", value: ""),
    FormField(placeholder: "Last Name", value: ""),
    FormField(placeholder: "Phone Number", value: ""),
    FormField(placeholder: "Year of Study", value: ""),
    FormField(placeholder: "E-mail ID", value: ""),
    FormField(placeholder: "Course", value: ""),
    FormField(placeholder: "Department", value: ""),
    FormField(placeholder: "Specialization", value: "")
]
// User model
struct User {
    let id: String
    let name: String
    let profileImage: UIImage?
    
    init(id: String, name: String, profileImage: UIImage? = nil) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
    }
}

// ChatMessage model for individual messages
struct ChatMessage {
    let id: String
    let sender: User
    let messageContent: String
    let timestamp: Date
    let isSender: Bool // true if the current user sent this message

    init(id: String, sender: User, messageContent: String, timestamp: Date, isSender: Bool) {
        self.id = id
        self.sender = sender
        self.messageContent = messageContent
        self.timestamp = timestamp
        self.isSender = isSender
    }
}

// ChatThread model to store a conversation
struct ChatThread {
    let id: String
    let participants: [User]
    var messages: [ChatMessage] // Messages for the thread
    
    init(id: String, participants: [User], messages: [ChatMessage] = []) {
        self.id = id
        self.participants = participants
        self.messages = messages
    }
}

// FriendRequest model with sample data for Quick Add and Added Me sections
struct FriendRequest {
    let name: String
    let username: String
    let profileImage: UIImage?
    let actionTitle: String
    let isQuickAdd: Bool // differentiate between "Added Me" and "Quick Add"
    
    static let sampleData: [FriendRequest] = [
        // Added Me section
        FriendRequest(name: "Riya Rao", username: "riya_rao08", profileImage: UIImage(named: "riya_profile"), actionTitle: "Accept", isQuickAdd: false),
        FriendRequest(name: "Sanidhya Singh", username: "san_0987_singh", profileImage: UIImage(named: "sanidhya_profile"), actionTitle: "Accept", isQuickAdd: false),
        FriendRequest(name: "Yash Gupta", username: "moody_yash08", profileImage: UIImage(named: "yash_profile"), actionTitle: "Accept", isQuickAdd: false),
        FriendRequest(name: "Abhivesh Shukla", username: "abhi_sheesh08", profileImage: UIImage(named: "abhivesh_profile"), actionTitle: "Accept", isQuickAdd: false),
        FriendRequest(name: "Tanisha Jain", username: "tanvi0936_jain", profileImage: UIImage(named: "tanisha_profile"), actionTitle: "Accept", isQuickAdd: false),
        
        // Quick Add section
        FriendRequest(name: "Nakul", username: "nakul_lim09", profileImage: UIImage(named: "nakul_profile"), actionTitle: "Add", isQuickAdd: true),
        FriendRequest(name: "Saurav", username: "saurav_network", profileImage: UIImage(named: "saurav_profile"), actionTitle: "Add", isQuickAdd: true),
        FriendRequest(name: "Akshay", username: "akshay_network", profileImage: UIImage(named: "akshay_profile"), actionTitle: "Add", isQuickAdd: true),
        FriendRequest(name: "Palak", username: "palak_net", profileImage: UIImage(named: "palak_profile"), actionTitle: "Add", isQuickAdd: true),
        FriendRequest(name: "Rachita", username: "rachita_intern", profileImage: UIImage(named: "rachita_profile"), actionTitle: "Add", isQuickAdd: true),
    ]
}

// ChatDataSource class to manage chat threads and messages
class ChatDataSource {
    var threads: [ChatThread] = []
    
    init() {
        loadSampleData()
    }

    private func loadSampleData() {
        // Main user
        let currentUser = User(id: "currentUser", name: "Current User", profileImage: UIImage(named: "current_user_profile"))

        // Other users
        let user1 = User(id: "1", name: "Palak", profileImage: UIImage(named: "palak_profile"))
        let user2 = User(id: "2", name: "Yash", profileImage: UIImage(named: "yash_profile"))
        let user3 = User(id: "3", name: "Sanidhya", profileImage: UIImage(named: "sanidhya_profile"))
        let user4 = User(id: "4", name: "Varun", profileImage: UIImage(named: "varun_profile"))
        let user5 = User(id: "5", name: "Nakul", profileImage: UIImage(named: "nakul_profile"))
        let user6 = User(id: "6", name: "Shiv", profileImage: UIImage(named: "shiv_profile"))
        let user7 = User(id: "7", name: "Akshay", profileImage: UIImage(named: "akshay_profile"))

        // Creating chat threads with each user
        threads = [
            ChatThread(id: "thread1", participants: [currentUser, user1], messages: [
                ChatMessage(id: "m1", sender: user1, messageContent: "Hey Palak! How are you?", timestamp: Date(), isSender: false),
                ChatMessage(id: "m2", sender: currentUser, messageContent: "I'm good, thanks!", timestamp: Date(), isSender: true)
            ]),
            ChatThread(id: "thread2", participants: [currentUser, user2], messages: [
                ChatMessage(id: "m1", sender: user2, messageContent: "Hey Yash! What's up?", timestamp: Date(), isSender: false),
                ChatMessage(id: "m2", sender: currentUser, messageContent: "Not much, you?", timestamp: Date(), isSender: true)
            ]),
            ChatThread(id: "thread3", participants: [currentUser, user3], messages: [
                ChatMessage(id: "m1", sender: user3, messageContent: "Are you attending the event tomorrow?", timestamp: Date(), isSender: false),
                ChatMessage(id: "m2", sender: currentUser, messageContent: "Yes, I’ll be there!", timestamp: Date(), isSender: true)
            ]),
            ChatThread(id: "thread4", participants: [currentUser, user4], messages: [
                ChatMessage(id: "m1", sender: user4, messageContent: "Good morning!", timestamp: Date(), isSender: false),
                ChatMessage(id: "m2", sender: currentUser, messageContent: "Good morning! How's it going?", timestamp: Date(), isSender: true)
            ]),
            ChatThread(id: "thread5", participants: [currentUser, user5], messages: [
                ChatMessage(id: "m1", sender: user5, messageContent: "Can we discuss the project?", timestamp: Date(), isSender: false),
                ChatMessage(id: "m2", sender: currentUser, messageContent: "Sure, let me know when you're ready.", timestamp: Date(), isSender: true)
            ]),
            ChatThread(id: "thread6", participants: [currentUser, user6], messages: [
                ChatMessage(id: "m1", sender: user6, messageContent: "Hey Shiv! Long time no see.", timestamp: Date(), isSender: false),
                ChatMessage(id: "m2", sender: currentUser, messageContent: "Indeed! How have you been?", timestamp: Date(), isSender: true)
            ]),
            ChatThread(id: "thread7", participants: [currentUser, user7], messages: [
                ChatMessage(id: "m1", sender: user7, messageContent: "Let's catch up soon!", timestamp: Date(), isSender: false),
                ChatMessage(id: "m2", sender: currentUser, messageContent: "Absolutely, let’s plan something!", timestamp: Date(), isSender: true)
            ])
        ]
    }
    
    // Fetch a thread for a specific user, useful for navigating to a chat detail screen
    func thread(for user: User) -> ChatThread? {
        return threads.first(where: { $0.participants.contains(where: { $0.id == user.id }) })
    }
}

struct NotificationItem {
    let id: String
    let userImage: UIImage?
    let message: String
    let timestamp: String // e.g., "30m"
}

struct NotificationDataSource {
    static let sampleNotifications: [NotificationItem] = [
        NotificationItem(id: "1", userImage: UIImage(named: "palak_profile"), message: "Your connection, Palak Seth, recently registered for CAD2.0", timestamp: "30m"),
        NotificationItem(id: "2", userImage: UIImage(named: "meghna_profile"), message: "Your connection, Mehgana, just joined the photography club!", timestamp: "30m"),
        NotificationItem(id: "3", userImage: UIImage(named: "SRM_Kzilla"), message: "Recruitments are now open for SRM Zilla!", timestamp: "30m"),
        NotificationItem(id: "4", userImage: UIImage(named: "nakul_profile"), message: "Your connection, Roushan, signed up for the coding bootcamp", timestamp: "30m"),
        NotificationItem(id: "5", userImage: UIImage(named: "Dbug_profile"), message: "Dbug Labs presents a 'No Way Web' workshop!", timestamp: "30m"),
        NotificationItem(id: "6", userImage: UIImage(named: "yash_profile"), message: "Your connection, Yash, is a part of Game Developers Hackathon", timestamp: "30m"),
        NotificationItem(id: "7", userImage: UIImage(named: "akshay_profile"), message: "Your connection, Akshay, signed up for the 'Tech Talk Series'", timestamp: "30m"),
        NotificationItem(id: "8", userImage: UIImage(named: "shiv_profile"), message: "Shiv is hosting a dance workshop!", timestamp: "30m")
    ]
}
struct LoginCredentials {
    var userID: String
    var password: String
    var isUser: Bool // True if "User" is selected, false for "Host"
}
// Sample Data Source for Registrations
struct Registration {
    let serialNumber: Int
    let name: String
    let year: String
    let profileImage: UIImage
}

// Sample registrations with safe image loading
struct RegistrationDataSource {
    static let sampleRegistrations: [Registration] = [
        Registration(serialNumber: 1, name: "Yash Gupta", year: "III", profileImage: UIImage(named: "yash_profile") ?? UIImage(systemName: "person.circle")!),
        Registration(serialNumber: 2, name: "Palak Seth", year: "II", profileImage: UIImage(named: "palak_profile") ?? UIImage(systemName: "person.circle")!),
        Registration(serialNumber: 3, name: "Meghana Rao", year: "III", profileImage: UIImage(named: "meghna_profile") ?? UIImage(systemName: "person.circle")!),
        Registration(serialNumber: 4, name: "Nakul R.", year: "I", profileImage: UIImage(named: "nakul_profile") ?? UIImage(systemName: "person.circle")!),
        Registration(serialNumber: 5, name: "Akshay M.", year: "IV", profileImage: UIImage(named: "akshay_profile") ?? UIImage(systemName: "person.circle")!),
        Registration(serialNumber: 6, name: "Shiv S.", year: "III", profileImage: UIImage(named: "shiv_profile") ?? UIImage(systemName: "person.circle")!),
        Registration(serialNumber: 7, name: "Roushan P.", year: "II", profileImage: UIImage(named: "roushan_profile") ?? UIImage(systemName: "person.circle")!)
        // Add more registrations as needed
    ]
}
struct Event: Codable {
    let id: String
    let title: String
    let description: String
    let imageName: String // Store image name for easy loading
    var category: String? // Optional for grouping events like "Favourites" or "Tech Favs"
    
    var image: UIImage? {
        return UIImage(named: imageName)
    }
}
struct EventDataSource {
    static let sampleEvents: [Event] = [
        Event(id: "1", title: "Samay Raina Comedy Show", description: "Laugh out loud with Samay Raina's witty comedy.", imageName: "SamayRaina", category: "Favourites"),
        Event(id: "2", title: "SRM Run", description: "Join the SRM Run and promote fitness and unity.", imageName: "SRMRUN", category: "Favourites"),
        Event(id: "3", title: "Sahil Shah Comedy Show", description: "Enjoy a hilarious evening with Sahil Shah.", imageName: "Sahilshah", category: "Favourites"),
        Event(id: "4", title: "SRM NCC", description: "Join the SRM NCC and experience adventure and discipline.", imageName: "SRMNCC", category: "Tech Favs"),
        Event(id: "5", title: "Musication The Band", description: "Experience live music with Musication.", imageName: "Musication", category: "Favourites")
    ]
}

