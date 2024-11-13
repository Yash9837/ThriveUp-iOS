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
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(250))
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
                title: "Tech Conference",
                category: "Technology, Conference",
                attendanceCount: 250,
                organizerName: "Tech Innovators",
                date: "Fri, 22 Nov",
                time: "10:00 - 17:00 WIB",
                location: "T.P Auditorium",
                locationDetails: "Tech Park, Chennai",
                imageName: "AarushIn",
                speakers: [
                    Speaker(name: "Samay Raina", imageURL: "samayrainaimg"),
                    Speaker(name: "Rohit Saraf", imageURL: "rohitsaraf")
                ],
                description: "A conference for tech enthusiasts featuring leading experts."
            ),
            EventModel(
                title: "Music Festival",
                category: "Music, Concert",
                attendanceCount: 500,
                organizerName: "Live Nation",
                date: "Sat, 23 Nov",
                time: "18:00 - 23:00 WIB",
                location: "City Amphitheatre",
                locationDetails: "Downtown, Chennai",
                imageName: "AarushIn",
                speakers: [
                    Speaker(name: "DJ Armin", imageURL: "djArmin"),
                    Speaker(name: "Sarah Connor", imageURL: "sarahConnor")
                ],
                description: "Enjoy a night of amazing music with top DJs and bands."
            ),
            EventModel(
                title: "Art Expo",
                category: "Art, Exhibition",
                attendanceCount: 300,
                organizerName: "Art Community",
                date: "Sun, 24 Nov",
                time: "11:00 - 18:00 WIB",
                location: "City Art Gallery",
                locationDetails: "Museum Road, Chennai",
                imageName: "AarushIn",
                speakers: [
                    Speaker(name: "Leonardo Ray", imageURL: "leonardoRay"),
                    Speaker(name: "Mona Lisa", imageURL: "monaLisa")
                ],
                description: "A display of incredible art pieces from talented artists."
            )
        ]
        
        let funEvents = [
            EventModel(
                title: "Samay Raina Comedy Night",
                category: "Comedy, Show",
                attendanceCount: 500,
                organizerName: "Aaruush",
                date: "Sat, 24 Nov",
                time: "19:00 - 21:00 WIB",
                location: "T.P Auditorium",
                locationDetails: "SRMIST, Chennai",
                imageName: "SamayRaina",
                speakers: [
                    Speaker(name: "Samay Raina", imageURL: "samayRaina")
                ],
                description: "A night full of laughter with stand-up comedy by Samay Raina."
            ),
            EventModel(
                title: "City Carnival",
                category: "Fun, Festival",
                attendanceCount: 1000,
                organizerName: "City Council",
                date: "Sun, 25 Nov",
                time: "09:00 - 20:00 WIB",
                location: "Central Park",
                locationDetails: "Downtown, Chennai",
                imageName: "Sahilshah",
                speakers: [
                    Speaker(name: "Sahil Shah", imageURL: "sahilShah")
                ],
                description: "An exciting carnival with food, games, and live performances."
            ),
            EventModel(
                title: "Jazz Night",
                category: "Music, Concert",
                attendanceCount: 200,
                organizerName: "Music Lovers Club",
                date: "Mon, 26 Nov",
                time: "19:00 - 22:00 WIB",
                location: "Blue Note Jazz Club",
                locationDetails: "Jazz Street, Chennai",
                imageName: "AditiMittal",
                speakers: [
                    Speaker(name: "Aditi Mittal", imageURL: "aditiMittal")
                ],
                description: "A cozy jazz night featuring soulful music and great ambiance."
            )
        ]
        
        let workshopEvents = [
            EventModel(
                title: "iOS Development Workshop",
                category: "Technology, Workshop",
                attendanceCount: 50,
                organizerName: "Code Labs",
                date: "Mon, 27 Nov",
                time: "10:00 - 15:00 WIB",
                location: "Tech Hub",
                locationDetails: "IT Park, Chennai",
                imageName: "Roboriot",
                speakers: [
                    Speaker(name: "John Appleseed", imageURL: "johnAppleseed"),
                    Speaker(name: "Jane Doe", imageURL: "janeDoe")
                ],
                description: "Learn the basics of iOS app development in this interactive workshop."
            ),
            EventModel(
                title: "Photography Basics",
                category: "Art, Workshop",
                attendanceCount: 30,
                organizerName: "Photo Club",
                date: "Tue, 28 Nov",
                time: "14:00 - 18:00 WIB",
                location: "City Hall",
                locationDetails: "Photography District, Chennai",
                imageName: "Ideathon",
                speakers: [
                    Speaker(name: "Peter Parker", imageURL: "peterParker")
                ],
                description: "Master the basics of photography and capture stunning images."
            ),
            EventModel(
                title: "Cooking Class",
                category: "Cooking, Workshop",
                attendanceCount: 20,
                organizerName: "Gourmet Club",
                date: "Wed, 29 Nov",
                time: "16:00 - 19:00 WIB",
                location: "Gourmet Kitchen",
                locationDetails: "Food Street, Chennai",
                imageName: "DShack",
                speakers: [
                    Speaker(name: "Chef Mario", imageURL: "chefMario")
                ],
                description: "Join this hands-on class to learn gourmet cooking techniques."
            )
        ]
        
        // Store these arrays in your data source, or use them to populate your UI.
    

        
    categories = [
            CategoryModel(name: "Trending", events: trendingEvents),
            CategoryModel(name: "Fun and Entertainment", events: funEvents),
            CategoryModel(name: "Workshops", events: workshopEvents)
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
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView != categoryCollectionView {
//            // Retrieve the selected event
//            let selectedEvent = categories[indexPath.section].events[indexPath.item]
//            
//            // Initialize EventDetailViewController and pass the selected event
//            let detailVC = EventDetailViewController(event: selectedEvent)
//            
//            // Push EventDetailViewController onto the navigation stack
//            navigationController?.pushViewController(detailVC, animated: true)
//        }
//    }
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




