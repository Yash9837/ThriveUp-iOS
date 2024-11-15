//
//  DataModel.swift
//  workingModel
//
//  Created by Yash's Mackbook on 12/11/24.
//

import Foundation

struct Speaker {
    let name: String
    let imageURL: String
}

struct EventModel {
    let eventId : String
    let title: String
    let category: String
    let attendanceCount: Int
    let organizerName: String
    let date: String
    let time: String
    let location: String
    let locationDetails: String
    let imageName: String
    let speakers: [Speaker]
    let description: String?
    var latitude: Double? // New property
        var longitude: Double? // New property
}

struct CategoryModel {
    let name: String
    let events: [EventModel]
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
