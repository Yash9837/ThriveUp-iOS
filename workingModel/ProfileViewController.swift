//
//  ProfileViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 16/11/24.
//
//
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, RegisteredEventCellDelegate {

    // MARK: - Properties
    private var registeredEvents: [EventModel] = [] // Stores registered events
    private let db = Firestore.firestore()

    // UI Elements
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_profile")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 40
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .black
        return label
    }()

    private let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        return label
    }()

    private let segmentControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Details", "Events"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = UIColor.orange
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()

    private let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()

    private let aboutDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Passionate college student who thrives on new experiences, attending events, and connecting with people."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.numberOfLines = 0
        return label
    }()

    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 20
        return stackView
    }()

    private let eventsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RegisteredEventCell.self, forCellReuseIdentifier: RegisteredEventCell.identifier)
        tableView.isHidden = true
        return tableView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        setupUI()
        setupConstraints()
        loadUserDetails()
        loadRegisteredEvents()
    }

    // MARK: - Configure Navigation Bar
    private func configureNavigationBar() {
        navigationItem.title = "Profile"
        navigationController?.navigationBar.titleTextAttributes = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]

        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        logoutButton.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.systemBlue
        ], for: .normal)
        navigationItem.rightBarButtonItem = logoutButton
    }

    @objc private func handleLogout() {
        let userTabBarController = GeneralTabbarController()

        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.window?.rootViewController = userTabBarController
            sceneDelegate.window?.makeKeyAndVisible()
        }
    }

    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(emailLabel)
        view.addSubview(segmentControl)
        view.addSubview(aboutLabel)
        view.addSubview(aboutDescriptionLabel)
        view.addSubview(detailsStackView)
        view.addSubview(eventsTableView)

        let yearView = createDetailView(title: "III", value: "YEAR")
        let departmentView = createDetailView(title: "DSBS", value: "DEPARTMENT")
        let friendsView = createDetailView(title: "50+", value: "FRIENDS")
        [yearView, departmentView, friendsView].forEach { detailsStackView.addArrangedSubview($0) }

        eventsTableView.dataSource = self
        eventsTableView.delegate = self
    }

    private func setupConstraints() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        aboutLabel.translatesAutoresizingMaskIntoConstraints = false
        aboutDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsStackView.translatesAutoresizingMaskIntoConstraints = false
        eventsTableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 16),

            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            segmentControl.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            aboutLabel.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 20),
            aboutLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            aboutDescriptionLabel.topAnchor.constraint(equalTo: aboutLabel.bottomAnchor, constant: 8),
            aboutDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            aboutDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            detailsStackView.topAnchor.constraint(equalTo: aboutDescriptionLabel.bottomAnchor, constant: 20),
            detailsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            eventsTableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 16),
            eventsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eventsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func createDetailView(title: String, value: String) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .orange

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = UIFont.systemFont(ofSize: 14)
        valueLabel.textColor = .gray

        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.spacing = 4
        stackView.alignment = .center
        return stackView
    }

    // MARK: - Load User Details and Events
    private func loadUserDetails() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }

        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user details: \(error.localizedDescription)")
                return
            }

            guard let data = document?.data() else { return }
            self?.nameLabel.text = data["name"] as? String ?? "Name"
            self?.emailLabel.text = data["email"] as? String ?? "Email"
        }
    }

    private func loadRegisteredEvents() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }

        db.collection("registrations").whereField("uid", isEqualTo: userId).getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching registrations: \(error.localizedDescription)")
                return
            }

            let eventIds = querySnapshot?.documents.compactMap { $0.data()["eventId"] as? String } ?? []
            if eventIds.isEmpty {
                print("No registered events found.")
            } else {
                self.fetchEvents(for: eventIds)
            }
        }
    }

    private func fetchEvents(for eventIds: [String]) {
        let group = DispatchGroup()
        registeredEvents.removeAll()

        for eventId in eventIds {
            group.enter()
            db.collection("events").document(eventId).getDocument { [weak self] document, error in
                defer { group.leave() }

                if let error = error {
                    print("Error fetching event details for \(eventId): \(error.localizedDescription)")
                    return
               
                }

                guard let data = document?.data(), let self = self else {
                    print("No data found for eventId: \(eventId)")
                    return
                }

                let imageNameOrUrl = data["imageName"] as? String ?? ""
                let isImageUrl = URL(string: imageNameOrUrl)?.scheme != nil

                let event = EventModel(
                    eventId: eventId,
                    title: data["title"] as? String ?? "Untitled",
                    category: data["category"] as? String ?? "Uncategorized",
                    attendanceCount: data["attendanceCount"] as? Int ?? 0,
                    organizerName: data["organizerName"] as? String ?? "Unknown",
                    date: data["date"] as? String ?? "Unknown Date",
                    time: data["time"] as? String ?? "Unknown Time",
                    location: data["location"] as? String ?? "Unknown Location",
                    locationDetails: data["locationDetails"] as? String ?? "",
                    imageName: isImageUrl ? imageNameOrUrl : "",
                    speakers: [],
                    description: data["description"] as? String ?? "",
                    latitude: data["latitude"] as? Double,
                    longitude: data["longitude"] as? Double
                )
                self.registeredEvents.append(event)
            }
        }

        group.notify(queue: .main) {
            self.eventsTableView.reloadData()
        }
    }

    // MARK: - Unregister Event
    func didTapUnregister(event: EventModel) {
        let alert = UIAlertController(
            title: "Unregister",
            message: "Are you sure you want to unregister from \(event.title)?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.unregisterEvent(event)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true)
    }

    private func unregisterEvent(_ event: EventModel) {
        guard let userId = Auth.auth().currentUser?.uid else { return }

        db.collection("registrations")
            .whereField("uid", isEqualTo: userId)
            .whereField("eventId", isEqualTo: event.eventId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching registration for unregistration: \(error.localizedDescription)")
                    return
                }

                guard let document = snapshot?.documents.first else {
                    print("No registration found for event \(event.eventId)")
                    return
                }

                document.reference.delete { error in
                    if let error = error {
                        print("Error deleting registration: \(error.localizedDescription)")
                    } else {
                        print("Successfully unregistered from event \(event.eventId)")
                        self.registeredEvents.removeAll { $0.eventId == event.eventId }
                        DispatchQueue.main.async {
                            self.eventsTableView.reloadData()
                        }
                    }
                }
            }
    }

    // MARK: - UITableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registeredEvents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegisteredEventCell.identifier, for: indexPath) as! RegisteredEventCell
        cell.configure(with: registeredEvents[indexPath.row])
        cell.delegate = self
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventDetailVC = EventDetailViewController()
        eventDetailVC.event = registeredEvents[indexPath.row]
        navigationController?.pushViewController(eventDetailVC, animated: true)
    }

    // MARK: - Segment Control Action
    @objc private func segmentChanged() {
        let isShowingEvents = segmentControl.selectedSegmentIndex == 1
        aboutLabel.isHidden = isShowingEvents
        aboutDescriptionLabel.isHidden = isShowingEvents
        detailsStackView.isHidden = isShowingEvents
        eventsTableView.isHidden = !isShowingEvents
    }
}
