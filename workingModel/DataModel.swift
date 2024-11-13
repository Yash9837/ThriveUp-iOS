//
//  DataModel.swift
//  workingModel
//
//  Created by Yash's Mackbook on 12/11/24.
//

import Foundation

//struct EventModel {
//    let title: String
//    let date: String
//    let imageName: String
//}
struct Speaker {
    let name: String
    let imageURL: String
}

struct EventModel {
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
}

struct CategoryModel {
    let name: String
    let events: [EventModel]
}
