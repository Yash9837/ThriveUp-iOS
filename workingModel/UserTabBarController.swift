//
//  MainTabBarController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 16/11/24.
//
import UIKit

class UserTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize tab bar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white // Set the tab bar background color to white
        appearance.stackedLayoutAppearance.selected.iconColor = .orange // Set icon color when selected
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.orange // Set title color when selected
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = .gray // Default icon color
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray // Default title color
        ]
        
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
        
        setupTabs()
    }
    
    private func setupTabs() {
        let eventsVC = UINavigationController(rootViewController: EventListViewController())
        eventsVC.tabBarItem = UITabBarItem(title: "Feed", image: UIImage(systemName: "house"), tag: 0)
        
        let chatVC = UINavigationController(rootViewController: ChatViewController())
        chatVC.tabBarItem = UITabBarItem(title: "Chat", image: UIImage(systemName: "bubble.right"), tag: 1)
        
        let swipeVC = UINavigationController(rootViewController: SwipeViewController())
        swipeVC.view.backgroundColor = .white
        swipeVC.tabBarItem = UITabBarItem(title: "Swipe", image: UIImage(systemName: "rectangle.on.rectangle.angled"), tag: 2)
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController()) // Profile tab
        profileVC.view.backgroundColor = .white
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person"), tag: 3)
        
        viewControllers = [eventsVC, chatVC, swipeVC, profileVC]
    }
}
