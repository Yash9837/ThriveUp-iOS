//
//  EventDetailViewController.swift
//  workingModel
//
//  Created by Yash's Mackbook on 13/11/24.
//
import UIKit
import MapKit

class EventDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var event: EventModel?
    
    
    // UI Elements
    private let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()

    private let organizerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private let registerButton: UIButton = UIButton()
    private func setupRegisterButton() {
            // Configure the register button if not already configured
            registerButton.setTitle("Register", for: .normal)
            registerButton.backgroundColor = .orange
            registerButton.setTitleColor(.white, for: .normal)
            registerButton.layer.cornerRadius = 10
            registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        }
    

    @objc private func registerButtonTapped() {
        guard let eventId = event?.eventId else { return }

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

        let registrationVC = RegistrationViewController(formFields: formFields, eventId: eventId)
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.cornerRadius = 10
        map.clipsToBounds = true
        return map
    }()

    // Stack view to hold date and location labels alongside the map
    private let detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .top
        return stackView
    }()
    
    // Speakers Collection View
    private let speakersCollectionView: UICollectionView

    init() {
        // Initialize collection view with flow layout for horizontal scroll
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 120)
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        speakersCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUIWithData()  // Populate UI with data
        setupMapTapGesture() 
        setupRegisterButton()
    }

    private func setupUI() {
        view.backgroundColor = .white

        // Set up collection view data source and delegate
        speakersCollectionView.dataSource = self
        speakersCollectionView.delegate = self
        speakersCollectionView.register(SpeakerCell.self, forCellWithReuseIdentifier: SpeakerCell.identifier)
        speakersCollectionView.backgroundColor = .clear
        
        // Add date and location labels to the details stack view
        let labelsStackView = UIStackView(arrangedSubviews: [dateLabel, locationLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 40
        detailsStackView.addArrangedSubview(labelsStackView)
        detailsStackView.addArrangedSubview(mapView)
        
        // Add all views to the main view
        [eventImageView, titleLabel, categoryLabel, organizerLabel, detailsStackView, speakersCollectionView, registerButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            eventImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
               eventImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
               eventImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8), // Use -8 for trailing
               eventImageView.heightAnchor.constraint(equalToConstant: 300),
            

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Category Label
            categoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Organizer Label
            organizerLabel.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            organizerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            organizerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // Details Stack View (Date, Location, Map)
            detailsStackView.topAnchor.constraint(equalTo: organizerLabel.bottomAnchor, constant: 16),
            detailsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            detailsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Map View Size Constraints
            mapView.widthAnchor.constraint(equalToConstant: 100),
            mapView.heightAnchor.constraint(equalToConstant: 100),

            // Speakers Collection View
            speakersCollectionView.topAnchor.constraint(equalTo: detailsStackView.bottomAnchor, constant: 16),
            speakersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            speakersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            speakersCollectionView.heightAnchor.constraint(equalToConstant: 120),

            // Register Button
            registerButton.topAnchor.constraint(equalTo: speakersCollectionView.bottomAnchor, constant: 24),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            registerButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }

    private func configureUIWithData() {
        guard let event = event else { return }

        // Populate labels and image with event data
        titleLabel.text = event.title
        categoryLabel.text = "\(event.category) • \(event.attendanceCount) people"
        organizerLabel.text = "Organized by \(event.organizerName)"
        dateLabel.text = "\(event.date), \(event.time)"
        locationLabel.text = event.location
        eventImageView.image = UIImage(named: event.imageName)

        // Set map location to custom event coordinates if available; otherwise, default to Chennai
        if let latitude = event.latitude, let longitude = event.longitude {
            // Custom coordinates for the event location
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: false)

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = event.location
            mapView.addAnnotation(annotation)
        } else {
            // Default to Chennai coordinates if no custom location is provided
            let chennaiCoordinate = CLLocationCoordinate2D(latitude: 13.0827, longitude: 80.2707)
            let region = MKCoordinateRegion(center: chennaiCoordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
            mapView.setRegion(region, animated: false)

            let chennaiAnnotation = MKPointAnnotation()
            chennaiAnnotation.coordinate = chennaiCoordinate
            chennaiAnnotation.title = "Chennai"
            mapView.addAnnotation(chennaiAnnotation)
        }

        // Configure register button based on attendance status
        registerButton.setTitle(event.attendanceCount > 0 ? "Registered" : "Register", for: .normal)

        // Reload speakers collection view
        speakersCollectionView.reloadData()
    }
    private func setupMapTapGesture() {
           let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openInMaps))
           mapView.addGestureRecognizer(tapGesture)
           mapView.isUserInteractionEnabled = true
        
       }

       @objc private func openInMaps() {
           guard let latitude = event?.latitude, let longitude = event?.longitude else { return }
           let urlString = "http://maps.apple.com/?ll=\(latitude),\(longitude)"
           if let url = URL(string: urlString) {
               UIApplication.shared.open(url)
           }
       }

    // Collection View DataSource methods
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
