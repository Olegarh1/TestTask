//
// ParseModels.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import Foundation

struct UsersModel: Codable {
    let success: Bool
    let page: Int?
    let pages: Int?
    let totalUsers: Int?
    let count: Int?
    var users: [UserModel]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case page
        case pages = "total_pages"
        case totalUsers = "total_users"
        case count, users
    }
}

struct UserModel: Codable {
    let id: Int?
    let name: String?
    let email: String?
    let phone: String?
    let position: String?
    let positionID: Int?
    let registrationDate: Date?
    let photo: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, email, phone, position
        case positionID = "position_id"
        case registrationDate = "registration_timestamp"
        case photo
    }
}

struct SignUpModel: Codable {
    let success: Bool
    let userId: Int?
    let message: String?
    let fails: [String: [String]]?
}

struct TokenModel: Codable {
    let success: Bool
    let token: String?
}

struct PositionModel: Codable {
    let success: Bool
    let message: String?
    let positions: [Position]?
}

struct Position: Codable {
    let id: Int?
    let name: String
}
