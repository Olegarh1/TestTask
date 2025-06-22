//
// Network.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

final class Network {
    
    static let shared = Network()
    
    private let endpoint = "https://frontend-test-assignment-api.abz.agency/api/v1"
    private init() {}
    
    func getUsers(_ requestModel: UsersRequestModel, response: @escaping NetworkCompletion<UsersModel>) {
        guard let url = URL(string: endpoint + "/users") else {
            response(.failure(NSError(domain: "Wrong enpoint", code: -12)))
            return
        }
        
        NetworkProvider.shared.baseDataTask(url: url,
                                            httpMethod: "GET",
                                            headers: ["Content-Type": "application/json"],
                                            body: requestModel.asData(),
                                            completion: response
        ).resume()
    }
    
    func signUpUser(_ requestModel: SignUpRequestModel, image: UIImage, token: String, response: @escaping NetworkCompletion<SignUpModel>) {
        guard let url = URL(string: endpoint + "/users") else {
            response(.failure(NSError(domain: "Wrong endpoint", code: -12)))
            return
        }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            response(.failure(NSError(domain: "Failed to convert image", code: -13)))
            return
        }
        
        let formFields: [String: String] = [
            "name": requestModel.name,
            "email": requestModel.email,
            "phone": requestModel.phone,
            "position_id": String(requestModel.position_id)
        ]
        
        NetworkProvider.shared.uploadMultipartFormData(
            url: url,
            formFields: formFields,
            fileFieldName: "photo",
            fileName: "profile.jpg",
            mimeType: "image/jpeg",
            fileData: imageData,
            headers: ["Token": token],
            completion: response
        ).resume()
    }
    
    func generateToken(response: @escaping NetworkCompletion<TokenModel>) {
        guard let url = URL(string: endpoint + "/token") else {
            response(.failure(NSError(domain: "Wrong enpoint", code: -12)))
            return
        }
        
        NetworkProvider.shared.baseDataTask(url: url,
                                            httpMethod: "POST",
                                            headers: ["Content-Type": "application/json"],
                                            completion: response
        ).resume()
    }
    
    func getPositions(response: @escaping NetworkCompletion<PositionModel>) {
        guard let url = URL(string: endpoint + "/positions") else {
            response(.failure(NSError(domain: "Wrong enpoint", code: -12)))
            return
        }
        
        NetworkProvider.shared.baseDataTask(url: url,
                                            httpMethod: "GET",
                                            headers: ["Content-Type": "application/json"],
                                            completion: response
        ).resume()
    }
}
