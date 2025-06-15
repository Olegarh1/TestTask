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
    let name: String
    let email: String
    let phone: String
    let position_id: Int
    let photo: String // string($binary)
//    Minimum size of photo 70x70px. The photo format must be jpeg/jpg type. The photo size must not be greater than 5 Mb.
}
