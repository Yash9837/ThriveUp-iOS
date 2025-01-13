//
//  RegistrationsListViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 09/01/25.
//

import UIKit
import FirebaseFirestore

class RegistrationListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private var registrations: [[String: Any]] = [] // Holds fetched registrations data
    private let eventId: String
    private let db = Firestore.firestore()
    
    // MARK: - UI Components
    private let tableViewHeader: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        let headers = ["S.No", "Name", "Email", "Year"]
        for header in headers {
            let label = UILabel()
            label.text = header
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textColor = .black
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
        return stackView
    }()
    
    private let registrationsTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(RegistrationTableViewCell.self, forCellReuseIdentifier: RegistrationTableViewCell.identifier)
        tableView.rowHeight = 60 // Set row height for better UI
        return tableView
    }()
    
    private let totalCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download File", for: .normal)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Initializer
    init(eventId: String) {
        self.eventId = eventId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        fetchRegistrations()
        downloadButton.addTarget(self, action: #selector(handleDownload), for: .touchUpInside)
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        title = "Registrations"
        view.backgroundColor = .white
        view.addSubview(totalCountLabel)
        view.addSubview(tableViewHeader)
        view.addSubview(registrationsTableView)
        view.addSubview(downloadButton)
        
        registrationsTableView.delegate = self
        registrationsTableView.dataSource = self
    }
    
    private func setupConstraints() {
        tableViewHeader.translatesAutoresizingMaskIntoConstraints = false
        registrationsTableView.translatesAutoresizingMaskIntoConstraints = false
        totalCountLabel.translatesAutoresizingMaskIntoConstraints = false
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Total Count Label
            totalCountLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            totalCountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            totalCountLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            // Table Header
            tableViewHeader.topAnchor.constraint(equalTo: totalCountLabel.bottomAnchor, constant: 8),
            tableViewHeader.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableViewHeader.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableViewHeader.heightAnchor.constraint(equalToConstant: 30),
            
            // TableView
            registrationsTableView.topAnchor.constraint(equalTo: tableViewHeader.bottomAnchor, constant: 8),
            registrationsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            registrationsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            registrationsTableView.bottomAnchor.constraint(equalTo: downloadButton.topAnchor, constant: -16),
            
            // Download Button
            downloadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            downloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            downloadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            downloadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Fetch Registrations
    private func fetchRegistrations() {
        db.collection("registrations")
            .whereField("eventId", isEqualTo: eventId)
            .getDocuments { [weak self] (snapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching registrations: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("No registrations found for event \(self.eventId)")
                    return
                }
                
                self.registrations = documents.map { $0.data() }
                
                // Debugging: Print each registration document
                for registration in self.registrations {
                    print("Registration Data: \(registration)")
                }
                
                DispatchQueue.main.async {
                    self.totalCountLabel.text = "Total Number of Registrations: \(self.registrations.count)"
                    self.registrationsTableView.reloadData()
                }
            }
    }


    // MARK: - UITableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registrations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RegistrationTableViewCell.identifier, for: indexPath) as! RegistrationTableViewCell
        let registration = registrations[indexPath.row]
        cell.configure(with: registration, index: indexPath.row)
        return cell
    }
    
    // MARK: - Download Button Action
    @objc private func handleDownload() {
        let csvData = generateCSVData()
        let fileName = "registrations_event_\(eventId).csv"
        
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvData.write(to: tempURL, atomically: true, encoding: .utf8)
            let activityViewController = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            present(activityViewController, animated: true)
        } catch {
            print("Error writing CSV file: \(error.localizedDescription)")
        }
    }
    
    private func generateCSVData() -> String {
        var csvString = "S.No,Name,Email,Year\n" // Header row
        
        for (index, registration) in registrations.enumerated() {
            let serialNumber = index + 1
            let name = registration["Name"] as? String ?? "N/A"
            let email = registration["E-mail ID"] as? String ?? "N/A"
            let year = registration["Year of Study"] as? String ?? "N/A"
            
            csvString += "\(serialNumber),\"\(name)\",\"\(email)\",\"\(year)\"\n"
        }
        
        return csvString
    }
}
