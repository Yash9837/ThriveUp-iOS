//
//  EventDetailViewController.swift
//  workingModel
//
//  Created by Yash's Mackbook on 13/11/24.
//

import UIKit
import Foundation

class EventDetailViewController: UIViewController, UICollectionViewDataSource {
   
    

    // Properties to hold event data
    var event: EventModel?

    // UI Elements
    private let eventImageView = UIImageView()
    private let titleLabel = UILabel()
    private let categoryLabel = UILabel()
    private let organizerLabel = UILabel()
    private let dateLabel = UILabel()
    private let locationLabel = UILabel()
    private let speakersCollectionView: UICollectionView
    private let registerButton = UIButton(type: .system)



    // Initialize with flow layout for horizontal scroll in collection view
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 100) // Example size
        layout.minimumInteritemSpacing = 8
        speakersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureUIWithData()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Configure register button appearance
        registerButton.backgroundColor = .orange
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 8

        // Set up the collection view data source and register the cell
        speakersCollectionView.dataSource = self
        speakersCollectionView.register(SpeakerCell.self, forCellWithReuseIdentifier: SpeakerCell.identifier)

        // Add all views to the main view
        view.addSubview(eventImageView)
        view.addSubview(titleLabel)
        view.addSubview(categoryLabel)
        view.addSubview(organizerLabel)
        view.addSubview(dateLabel)
        view.addSubview(locationLabel)
        view.addSubview(speakersCollectionView)
        view.addSubview(registerButton)

        // Set up Auto Layout constraints
        setupConstraints()
    }

    private func setupConstraints() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        eventImageView.translatesAutoresizingMaskIntoConstraints = false
        categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        organizerLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        speakersCollectionView.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Event image view constraints
            eventImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            eventImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            eventImageView.heightAnchor.constraint(equalToConstant: 300),
            eventImageView.widthAnchor.constraint(equalToConstant: 400),

            // Category label constraints
            categoryLabel.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 16),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Organizer label constraints
            organizerLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            organizerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            organizerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Date label constraints
            dateLabel.topAnchor.constraint(equalTo: organizerLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Location label constraints
            locationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Speakers collection view constraints
            speakersCollectionView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            speakersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            speakersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            speakersCollectionView.heightAnchor.constraint(equalToConstant: 120),

            // Register button constraints
            registerButton.topAnchor.constraint(equalTo: speakersCollectionView.bottomAnchor, constant: 16),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.widthAnchor.constraint(equalToConstant: 200),
            registerButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }



    private func configureUIWithData() {
        guard let event = event else { return }

        // Configure text-based UI elements with event data
        titleLabel.text = event.title
        categoryLabel.text = "\(event.category) • \(event.attendanceCount) people"
        organizerLabel.text = "Organized by \(event.organizerName)"
        dateLabel.text = "\(event.date), \(event.time)"
        locationLabel.text = event.location
        // Set optional description if available
        

        // Set the register button title
        let registrationStatus = event.attendanceCount > 0 ? "Registered" : "Register"
        registerButton.setTitle(registrationStatus, for: .normal)

        // Load event image from the event's `imageName`
//        loadImage(named: event.imageName, into: eventImageView)

        // Reload the speakers collection view
        speakersCollectionView.reloadData()
        eventImageView.image = UIImage(named: event.imageName)
    }

    // Helper function to load images asynchronously
//    private func loadImage(named imageName: String, into imageView: UIImageView) {
//        if let imageURL = URL(string: imageName) {
//            let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
//                if let data = data, let image = UIImage(data: data) {
//                    DispatchQueue.main.async {
//                        imageView.image = image
//                    }
//                } else {
//                    // Set placeholder image if there's an error
//                    DispatchQueue.main.async {
//                        imageView.image = UIImage(systemName: "photo")
//                    }
//                }
//            }
//            task.resume()
//        } else {
//            // Set placeholder image if URL is invalid
//            imageView.image = UIImage(systemName: "photo")
//        }
//    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return event?.speakers.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpeakerCell.identifier, for: indexPath) as! SpeakerCell
                if let speaker = event?.speakers[indexPath.item] {
                    cell.configure(with: speaker)
                }
                return cell
    }
}

