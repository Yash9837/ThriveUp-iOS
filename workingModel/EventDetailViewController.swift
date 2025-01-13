//
//  EventDetailViewController.swift
//  workingModel
//
//  Created by Yash's Mackbook on 13/11/24.
//
import UIKit
import MapKit

class EventDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var event: EventModel? // Holds the event data passed from the previous screen

    // MARK: - UI Elements
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Details", "Updates", "Photos"])
        control.selectedSegmentIndex = 0
        control.selectedSegmentTintColor = .black
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()
    
    private let eventImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 22)
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
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()

    private let mapView: MKMapView = {
        let map = MKMapView()
        map.layer.cornerRadius = 10
        map.clipsToBounds = true
        return map
    }()

    private let speakersCollectionView: UICollectionView
    private let registerButton: UIButton = UIButton()

    // MARK: - Initializer
    init() {
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

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureUIWithData()
        setupRegisterButton()
        setupMapTapGesture()
    }

    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        
        // Configure speakers collection view
        speakersCollectionView.dataSource = self
        speakersCollectionView.delegate = self
        speakersCollectionView.register(SpeakerCell.self, forCellWithReuseIdentifier: SpeakerCell.identifier)
        speakersCollectionView.backgroundColor = .clear

        // Add subviews
        [eventImageView, segmentedControl, titleLabel, categoryLabel, organizerLabel, dateLabel, locationLabel, mapView, speakersCollectionView, registerButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Event Image View
            eventImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            eventImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            eventImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            eventImageView.heightAnchor.constraint(equalToConstant: 250),

            // Segmented Control
            segmentedControl.topAnchor.constraint(equalTo: eventImageView.bottomAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            segmentedControl.heightAnchor.constraint(equalToConstant: 36),

            // Title Label
            titleLabel.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 16),
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

            // Date Label
            dateLabel.topAnchor.constraint(equalTo: organizerLabel.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // Location Label
            locationLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            // Map View
            /*mapView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16)*/
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 240),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            mapView.widthAnchor.constraint(equalToConstant: 140),
                        mapView.heightAnchor.constraint(equalToConstant: 100), // Adjusted size

            // Speakers Collection View
            speakersCollectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
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

    // MARK: - Configure Data
    private func configureUIWithData() {
        guard let event = event else { return }

        titleLabel.text = event.title
        categoryLabel.text = "\(event.category) • \(event.attendanceCount) people"
        organizerLabel.text = "Organized by \(event.organizerName)"
        dateLabel.text = "\(event.date), \(event.time)"
        locationLabel.text = event.location
        eventImageView.image = UIImage(named: event.imageName)

        if let latitude = event.latitude, let longitude = event.longitude {
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            mapView.setRegion(region, animated: false)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = event.location
            mapView.addAnnotation(annotation)
        }
        speakersCollectionView.reloadData()
    }

    private func setupRegisterButton() {
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .orange
        registerButton.setTitleColor(.white, for: .normal)
        registerButton.layer.cornerRadius = 10
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
    }

    @objc private func registerButtonTapped() {
        guard let event = event else { return }
        let formFields = [
            FormField(placeholder: "Name", value: ""),
            FormField(placeholder: "Last Name", value: ""),
            FormField(placeholder: "Phone Number", value: ""),
            FormField(placeholder: "Year of Study", value: ""),
            FormField(placeholder: "Course", value: ""),
            FormField(placeholder: "Department", value: ""),
            FormField(placeholder: "Specialization", value: "")
        ]
        let registrationVC = RegistrationViewController(formFields: formFields, event: event)
        navigationController?.pushViewController(registrationVC, animated: true)
    }

    @objc private func segmentChanged() {
        print("Segment changed to index \(segmentedControl.selectedSegmentIndex)")
    }
    private func setupMapTapGesture() {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openInAppleMaps))
                mapView.addGestureRecognizer(tapGesture)
                mapView.isUserInteractionEnabled = true
            }
@objc private func openInAppleMaps() {
                guard let latitude = event?.latitude, let longitude = event?.longitude else { return }
                let urlString = "http://maps.apple.com/?ll=\(latitude),\(longitude)"
                if let url = URL(string: urlString) {
                    UIApplication.shared.open(url)
                }
            }

    // MARK: - Collection View DataSource
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

