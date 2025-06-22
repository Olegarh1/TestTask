//
// RequestModels.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import Foundation

struct UsersRequestModel: Codable {
    let page: Int
    let count: Int
    
    enum CodingKeys: String, CodingKey {
        case page, count
    }
}

struct SignUpRequestModel: Codable {
    var name: String
    var email: String
    var phone: String
    var position_id: Int
    var photo: String
}
