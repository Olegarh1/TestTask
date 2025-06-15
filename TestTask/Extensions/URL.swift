//
// URL.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

extension URL {
    func addingQueryParameters(from data: Data) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        components?.queryItems = json.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        return components?.url
    }
}
