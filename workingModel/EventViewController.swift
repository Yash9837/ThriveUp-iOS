//
//  ViewController.swift
//  workingModel
//
//  Created by Yash's Mackbook on 12/11/24.
//
import UIKit

class EventsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    private var categories: [CategoryModel] = []
    private var collectionView: UICollectionView!
    private var categoryCollectionView: UICollectionView!
    private let searchBar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupSearchBar()
            setupCategoryCollectionView()  // Ensure this is called before collectionView
            setupCollectionView()  // Called after categoryCollectionView is set up
            setupNavigationBar()
            setupTabBar()
            populateData()
                
                // Load dummy data
    }
    private func setupNavigationBar() {
        // Create the logo image view
        let logoImageView = UIImageView(image: UIImage(named: "thriveUpLogo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // Wrap the image view in a UIView to use it as a custom bar button item
        let logoContainerView = UIView()
        logoContainerView.addSubview(logoImageView)
        
        // Set constraints for the logo image view within its container
        NSLayoutConstraint.activate([
            logoImageView.leadingAnchor.constraint(equalTo: logoContainerView.leadingAnchor),
            logoImageView.topAnchor.constraint(equalTo: logoContainerView.topAnchor),
            logoImageView.bottomAnchor.constraint(equalTo: logoContainerView.bottomAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: logoContainerView.trailingAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60), // Adjust width to desired size
            logoImageView.heightAnchor.constraint(equalToConstant: 60) // Adjust height to desired size
        ])
        
        // Create a UIBarButtonItem with the container view as its custom view
        let logoBarButtonItem = UIBarButtonItem(customView: logoContainerView)
        
        
        // Set the left bar button item to the logo
        navigationItem.leftBarButtonItem = logoBarButtonItem
        
        
        // Add the right "Login" button
        // Create a custom UIButton for the "Login" bar button item
            let loginButton = UIButton(type: .system)
            loginButton.setTitle("Login", for: .normal)
            loginButton.setTitleColor(.white, for: .normal) // Text color
            loginButton.backgroundColor = .orange // Background color
            loginButton.layer.cornerRadius = 8     // Rounded corners
            loginButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10) // Padding
        NSLayoutConstraint.activate([loginButton.heightAnchor.constraint(equalToConstant: 40), loginButton.widthAnchor.constraint(equalToConstant:80 ),])
            // Set the button as the custom view of the right bar button item
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loginButton)
    }

    private func setupSearchBar() {
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.backgroundImage = UIImage() // Remove border line
        searchBar.searchBarStyle = .minimal
        
        
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    private func setupCategoryCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.minimumInteritemSpacing = 8

        categoryCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        categoryCollectionView.register(CategoryButtonCell.self, forCellWithReuseIdentifier: CategoryButtonCell.identifier)
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        categoryCollectionView.backgroundColor = .clear
        categoryCollectionView.showsHorizontalScrollIndicator = false
        categoryCollectionView.isPagingEnabled = false // Set to true if you want paging

        view.addSubview(categoryCollectionView)
        categoryCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            categoryCollectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            categoryCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            categoryCollectionView.heightAnchor.constraint(equalToConstant: 50),
            categoryCollectionView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 16) // Adjusted width for scrolling
        ])
    }



    private func setupCollectionView() {
        // Configure the collection view with a compositional layout
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(EventCell.self, forCellWithReuseIdentifier: EventCell.identifier)
        collectionView.register(CategoryHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeader.identifier)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: categoryCollectionView.bottomAnchor, constant: 8), // Adjusted constraint
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // Create compositional layout for the collection view
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            // Determine layout based on the section's name
            let category = self.categories[sectionIndex]
            
            if category.name == "Trending" {
                // Layout for Trending Events (1 item per row, horizontally scrollable)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(182))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .absolute(182))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                
                // Header
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
                
            } else {
                // Layout for Fun and Entertainment, Workshops (2 items per row, horizontally scrollable)
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
                
                // Group with two items per row
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                
                // Header
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                
                return section
            }
        }
    }


 
    
    private func setupTabBar() {
        let tabBar = UITabBar()
        tabBar.items = [
            UITabBarItem(title: "Feed", image: UIImage(systemName: "house"), tag: 0),
            UITabBarItem(title: "Chat", image: UIImage(systemName: "bubble.right"), tag: 1),
            UITabBarItem(title: "Swipe", image: UIImage(systemName: "rectangle.on.rectangle.angled"), tag: 2),
            UITabBarItem(title: "Calendar", image: UIImage(systemName: "calendar"), tag: 3),
            UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 4)
        ]
        view.addSubview(tabBar)
        
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    private func populateData() {
        
        let trendingEvents = [
            EventModel(
                eventId: "19", title: "Aaruush Grand Finale",
                category: "Trending",
                attendanceCount: 1000,
                organizerName: "Aaruush Team",
                date: "Wed, 3 Jan",
                time: "18:00 - 22:00 IST",
                location: "Main Arena",
                locationDetails: "Central Lawn",
                imageName: "AarushIn",
                speakers: [Speaker(name: "Samay Raina", imageURL: "samayrainaimg"),Speaker(name: "Rohit Saraf", imageURL: "rohitsaraf")],
                description: "The grand finale of Aaruush, featuring cultural and tech highlights.",
                latitude: 13.0604,
                longitude: 80.2496
            ),
            EventModel(
                eventId: "1", title: "Samay Raina Comedy Night",
                category: "Fun and Entertainment",
                attendanceCount: 100,
                organizerName: "Fun Team",
                date: "Fri, 15 Dec",
                time: "19:00 - 21:00 IST",
                location: "Auditorium A",
                locationDetails: "Downtown Center",
                imageName: "SamayRaina",
                speakers: [Speaker(name: "Samay Raina", imageURL: "samayrainaimg")],
                description: "A hilarious evening of stand-up comedy by Samay Raina.",
                latitude: 13.0827,
                longitude: 80.2707
            ),
            EventModel(
                eventId: "19", title: "Aaruush Grand Finale",
                category: "Trending",
                attendanceCount: 1000,
                organizerName: "Aaruush Team",
                date: "Wed, 3 Jan",
                time: "18:00 - 22:00 IST",
                location: "Main Arena",
                locationDetails: "Central Lawn",
                imageName: "AarushIn",
                speakers: [],
                description: "The grand finale of Aaruush, featuring cultural and tech highlights.",
                latitude: 13.0604,
                longitude: 80.2496
            )
        ]
        let funEvents = [
                EventModel(
                    eventId: "1", title: "Samay Raina Comedy Night",
                    category: "Fun and Entertainment",
                    attendanceCount: 100,
                    organizerName: "Fun Team",
                    date: "Fri, 15 Dec",
                    time: "19:00 - 21:00 IST",
                    location: "Auditorium A",
                    locationDetails: "Downtown Center",
                    imageName: "SamayRaina",
                    speakers: [Speaker(name: "Samay Raina", imageURL: "samayrainaimg")],
                    description: "A hilarious evening of stand-up comedy by Samay Raina.",
                    latitude: 13.0827,
                    longitude: 80.2707
                ),
                EventModel(
                    eventId: "2", title: "Aditi Mittal Comedy Show",
                    category: "Fun and Entertainment",
                    attendanceCount: 150,
                    organizerName: "Laughter Club",
                    date: "Sat, 16 Dec",
                    time: "18:00 - 20:00 IST",
                    location: "Auditorium B",
                    locationDetails: "City Square",
                    imageName: "AditiMittal",
                    speakers: [Speaker(name: "Aditi Mittal", imageURL: "aditimittalimg")],
                    description: "Experience the wit and humor of Aditi Mittal.",
                    latitude: 13.0780,
                    longitude: 80.2500
                ),
                EventModel(
                    eventId: "3", title: "Sahil Shah Live",
                    category: "Fun and Entertainment",
                    attendanceCount: 200,
                    organizerName: "Event Pro",
                    date: "Sun, 17 Dec",
                    time: "20:00 - 22:00 IST",
                    location: "Grand Theatre",
                    locationDetails: "East Avenue",
                    imageName: "Sahilshah",
                    speakers: [Speaker(name: "Sahil Shah", imageURL: "sahilshahimg")],
                    description: "Join Sahil Shah for a night full of entertainment.",
                    latitude: 13.0750,
                    longitude: 80.2600
                ),
                EventModel(
                    eventId: "4", title: "Square One Fest",
                    category: "Fun and Entertainment",
                    attendanceCount: 250,
                    organizerName: "City Events",
                    date: "Mon, 18 Dec",
                    time: "10:00 - 22:00 IST",
                    location: "City Park",
                    locationDetails: "Greenwood",
                    imageName: "SqareOne",
                    speakers: [],
                    description: "Enjoy a full day of activities, music, and fun at Square One Fest.",
                    latitude: 13.0800,
                    longitude: 80.2400
                )
            ]

            let techEvents = [
                EventModel(
                    eventId: "5", title: "Roboriot Championship",
                    category: "Tech and Innovation",
                    attendanceCount: 300,
                    organizerName: "Tech Society",
                    date: "Tue, 19 Dec",
                    time: "09:00 - 17:00 IST",
                    location: "Tech Hall",
                    locationDetails: "Innovation Avenue",
                    imageName: "Roboriot",
                    speakers: [],
                    description: "Robotics championship featuring teams from across the region.",
                    latitude: 13.0450,
                    longitude: 80.2200
                ),
                EventModel(
                    eventId: "6", title: "Figma Summit",
                    category: "Tech and Innovation",
                    attendanceCount: 150,
                    organizerName: "Designers Guild",
                    date: "Wed, 20 Dec",
                    time: "10:00 - 16:00 IST",
                    location: "Creative Hub",
                    locationDetails: "Design Plaza",
                    imageName: "FigmaSummit",
                    speakers: [],
                    description: "Explore the latest in UI/UX design with industry experts.",
                    latitude: 13.0480,
                    longitude: 80.2120
                ),
                EventModel(
                    eventId: "7", title: "Ideathon",
                    category: "Tech and Innovation",
                    attendanceCount: 100,
                    organizerName: "Innovation Lab",
                    date: "Thu, 21 Dec",
                    time: "10:00 - 18:00 IST",
                    location: "Campus Center",
                    locationDetails: "Innovation Lane",
                    imageName: "Ideathon",
                    speakers: [],
                    description: "A full-day idea generation competition for students and professionals.",
                    latitude: 13.0530,
                    longitude: 80.2150
                ),
                EventModel(
                    eventId: "8", title: "DShack Coding Challenge",
                    category: "Tech and Innovation",
                    attendanceCount: 200,
                    organizerName: "Tech Coders",
                    date: "Fri, 22 Dec",
                    time: "09:00 - 21:00 IST",
                    location: "Coding Arena",
                    locationDetails: "Code Street",
                    imageName: "DShack",
                    speakers: [],
                    description: "A high-energy coding challenge for developers of all skill levels.",
                    latitude: 13.0650,
                    longitude: 80.2300
                )
            ]
        let clubAndSocietiesEvents = [
                EventModel(
                    eventId: "9", title: "DSA Club Meetup",
                    category: "Club and Societies",
                    attendanceCount: 50,
                    organizerName: "DSA Club",
                    date: "Sat, 23 Dec",
                    time: "15:00 - 17:00 IST",
                    location: "Library Hall",
                    locationDetails: "SRMIST Campus",
                    imageName: "DSA",
                    speakers: [],
                    description: "Meetup for Data Structures and Algorithms enthusiasts.",
                    latitude: 13.0604,
                    longitude: 80.2496
                ),
                EventModel(
                    eventId: "10", title: "D-Bug Workshop",
                    category: "Club and Societies",
                    attendanceCount: 75,
                    organizerName: "Coding Club",
                    date: "Sun, 24 Dec",
                    time: "10:00 - 13:00 IST",
                    location: "Tech Lab 2",
                    locationDetails: "SRMIST Campus",
                    imageName: "Dbug",
                    speakers: [],
                    description: "Learn debugging techniques for efficient coding.",
                    latitude: 13.0604,
                    longitude: 80.2496
                ),
                EventModel(
                    eventId: "11", title: "MLSA Knowledge Sharing",
                    category: "Club and Societies",
                    attendanceCount: 60,
                    organizerName: "Microsoft Club",
                    date: "Mon, 25 Dec",
                    time: "14:00 - 16:00 IST",
                    location: "Room 203",
                    locationDetails: "IT Block",
                    imageName: "MLSA",
                    speakers: [],
                    description: "Knowledge sharing session hosted by MLSA members.",
                    latitude: 13.0604,
                    longitude: 80.2496
                )
            ]
            
            let culturalEvents = [
                EventModel(
                    eventId: "12", title: "Big Deal Dance Battle",
                    category: "Cultural",
                    attendanceCount: 200,
                    organizerName: "Cultural Committee",
                    date: "Tue, 26 Dec",
                    time: "18:00 - 21:00 IST",
                    location: "Main Stage",
                    locationDetails: "Central Lawn",
                    imageName: "BigDeal",
                    speakers: [],
                    description: "Dance competition featuring amazing talent.",
                    latitude: 13.0604,
                    longitude: 80.2496
                ),
                EventModel(
                    eventId: "13", title: "Musication Evening",
                    category: "Cultural",
                    attendanceCount: 300,
                    organizerName: "Music Club",
                    date: "Wed, 27 Dec",
                    time: "19:00 - 22:00 IST",
                    location: "Auditorium C",
                    locationDetails: "SRMIST Campus",
                    imageName: "Musication",
                    speakers: [],
                    description: "An evening filled with soothing music performances.",
                    latitude: 13.0604,
                    longitude: 80.2496
                )
            ]
            
            let networkingEvents = [
                EventModel(
                    eventId: "14", title: "Aaruush Live Session 1",
                    category: "Networking",
                    attendanceCount: 100,
                    organizerName: "Networking Club",
                    date: "Thu, 28 Dec",
                    time: "10:00 - 12:00 IST",
                    location: "Lecture Hall 1",
                    locationDetails: "Networking Block",
                    imageName: "AarushLive1",
                    speakers: [],
                    description: "Interactive live session with industry professionals.",
                    latitude: 13.0604,
                    longitude: 80.2496
                ),
                EventModel(
                    eventId: "15", title: "TEDx Youth",
                    category: "Networking",
                    attendanceCount: 400,
                    organizerName: "TEDx Team",
                    date: "Fri, 29 Dec",
                    time: "14:00 - 17:00 IST",
                    location: "Grand Theatre",
                    locationDetails: "East Avenue",
                    imageName: "TedX",
                    speakers: [],
                    description: "A platform for sharing inspiring ideas and innovation.",
                    latitude: 13.0604,
                    longitude: 80.2496
                )
            ]
            let wellnessEvents = [
                EventModel(
                    eventId: "16", title: "Beach Cleanup Drive",
                    category: "Wellness",
                    attendanceCount: 50,
                    organizerName: "NCC Club",
                    date: "Sat, 30 Dec",
                    time: "06:00 - 09:00 IST",
                    location: "Marina Beach",
                    locationDetails: "Chennai",
                    imageName: "BeachClean",
                    speakers: [],
                    description: "Volunteer drive to clean up Marina Beach.",
                    latitude: 13.0604,
                    longitude: 80.2496
                )
            ]
            let sportsEvents = [
                EventModel(
                    eventId: "17", title: "Twisted Trivia",
                    category: "Sports",
                    attendanceCount: 80,
                    organizerName: "Sports Club",
                    date: "Mon, 1 Jan",
                    time: "16:00 - 18:00 IST",
                    location: "Sports Complex",
                    locationDetails: "SRMIST Campus",
                    imageName: "TwistedTrivia",
                    speakers: [],
                    description: "Fun trivia challenge focusing on sports topics.",
                    latitude: 13.0604,
                    longitude: 80.2496
                )
            ]
            let careerConnectEvents = [
                EventModel(
                    eventId: "18", title: "Career Guidance Session",
                    category: "Career Connect",
                    attendanceCount: 200,
                    organizerName: "Placement Cell",
                    date: "Tue, 2 Jan",
                    time: "10:00 - 12:00 IST",
                    location: "Lecture Hall 2",
                    locationDetails: "Placement Block",
                    imageName: "ppt1",
                    speakers: [],
                    description: "Session on shaping careers and leveraging opportunities.",
                    latitude: 13.0604,
                    longitude: 80.2496
                )
            ]
            categories = [
                CategoryModel(name: "Trending ", events: trendingEvents),
                CategoryModel(name: "Fun and Entertainment", events: funEvents),
                        CategoryModel(name: "Tech and Innovation", events: techEvents),
                CategoryModel(name: "Club and Societies", events: clubAndSocietiesEvents),
                CategoryModel(name: "Cultural", events: culturalEvents),
                CategoryModel(name: "Networking", events: networkingEvents),
                CategoryModel(name: "Wellness", events: wellnessEvents),
                CategoryModel(name: "Sports", events: sportsEvents),
                CategoryModel(name: "Career Connect", events: careerConnectEvents),
                
                
            ]
        
        collectionView.reloadData()
    }

    // Collection View DataSource methods
       func numberOfSections(in collectionView: UICollectionView) -> Int {
           if collectionView == categoryCollectionView {
                      return 1
                  }
                  return categories.count
       }
       
       func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           if collectionView == categoryCollectionView {
               return ["All 🎓", "Club 🚀", "Tech 👨🏻‍💻", "Cult 🎭","Fun 🥳", "Well 🌱", "Netw 🤝","Conn 💼" ].count
           }
           return categories[section].events.count
       }
       func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           if collectionView == categoryCollectionView {
                       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryButtonCell.identifier, for: indexPath) as! CategoryButtonCell
                       let categories = ["All 🎓", "Club 🚀", "Tech 👨🏻‍💻", "Cult 🎭","Fun 🥳", "Well 🌱", "Netw 🤝","Conn 💼" ]
                       cell.configure(with: categories[indexPath.item])
                       return cell
                   }
                   
                   let event = categories[indexPath.section].events[indexPath.item]
                   let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EventCell.identifier, for: indexPath) as! EventCell
                   cell.configure(with: event)
                   return cell
               }

       // Add headers for section titles
       func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
           let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CategoryHeader.identifier, for: indexPath) as! CategoryHeader
           header.titleLabel.text = categories[indexPath.section].name
           return header
       }
       func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
              guard collectionView != categoryCollectionView else {
                  // If the tapped collection view is the categoryCollectionView, ignore this action
                  return
              }
              let selectedEvent = categories[indexPath.section].events[indexPath.item]
              
              // Instantiate EventDetailViewController
              let eventDetailVC = EventDetailViewController()
              // Pass the selected event data to the detail view controller
              eventDetailVC.event = selectedEvent
              // Push EventDetailViewController onto the navigation stack
              navigationController?.pushViewController(eventDetailVC, animated: true)
          }
   }
