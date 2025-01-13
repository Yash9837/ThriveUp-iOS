//
//  RegistrationViewController.swift
//  ThriveUp
//
//  Created by Yash's Mackbook on 14/11/24.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class RegistrationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    private let tableView = UITableView()
    private var formFields: [FormField]
    private var eventId: String
    private var event: EventModel // Store the event model
    private let db = Firestore.firestore() // Firestore instance
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = .orange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializer
    init(formFields: [FormField], event: EventModel) {
        self.formFields = formFields
        self.event = event
        self.eventId = event.eventId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Registration"
        
        // Configure table view
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FormFieldTableViewCell.self, forCellReuseIdentifier: "FormFieldTableViewCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        // Add submit button
        view.addSubview(submitButton)
        submitButton.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: submitButton.topAnchor, constant: -16),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            submitButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return formFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FormFieldTableViewCell", for: indexPath) as! FormFieldTableViewCell
        let field = formFields[indexPath.row]
        cell.configure(with: field.placeholder, value: field.value)
        cell.textField.tag = indexPath.row
        cell.textField.delegate = self
        return cell
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard textField.tag < formFields.count else { return }
        let updatedValue = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        formFields[textField.tag].value = updatedValue
        print("Updated field: \(formFields[textField.tag].placeholder), value: '\(updatedValue)'")
    }
    
    // MARK: - Handle Submit
    @objc private func handleSubmit() {
        // Force end editing to ensure textFieldDidEndEditing updates formFields
        view.endEditing(true)
        
        // Validate all fields
        guard validateFields() else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        // Save to Firebase
        saveRegistrationToFirebase()
    }

    private func validateFields() -> Bool {
        return !formFields.contains(where: { $0.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty })
    }
    
    private func saveRegistrationToFirebase() {
        // Ensure the user is authenticated
        guard let currentUser = Auth.auth().currentUser else {
            showAlert(title: "Error", message: "You must be logged in to register for an event.")
            return
        }
        
        // Prepare registration data
        var registrationData: [String: Any] = [:]
        for field in formFields {
            registrationData[field.placeholder] = field.value
        }
        registrationData["uid"] = currentUser.uid
        registrationData["eventId"] = eventId
        registrationData["timestamp"] = Timestamp(date: Date()) // Add timestamp
        
        // Save to Firestore under a single `registrations` collection
        db.collection("registrations").addDocument(data: registrationData) { [weak self] error in
            if let error = error {
                print("Error saving registration: \(error.localizedDescription)")
                self?.showAlert(title: "Error", message: "Failed to save registration. Please try again.")
            } else {
                print("Registration successfully saved for event \(self?.eventId ?? "")")
                self?.showAlert(title: "Success", message: "Registration successful!", completion: {
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }
    }
    
    // MARK: - Helper Methods
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion?()
        }))
        present(alert, animated: true, completion: nil)
    }
}
