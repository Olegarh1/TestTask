//
// Network.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import Foundation

final class Network {
    
    static let shared = Network()
    
    private let endpoint = "https://frontend-test-assignment-api.abz.agency/api/v1"
    private init() {}
    
    func getUsers(_ requestModel: UsersRequestModel, response: @escaping NetworkCompletion<UsersModel>) {
        guard let url = URL(string: endpoint + "/users") else {
            print("Wrong enpoint")
            return
        }
        
        NetworkProvider.shared.baseDataTask(url: url,
                                            httpMethod: "GET",
                                            headers: ["Content-Type": "application/json"],
                                            body: requestModel.asData(),
                                            completion: response).resume()
    }
    
    func signUpUser(_ requestModel: SignUpRequestModel, token: String, response: @escaping NetworkCompletion<SignUpModel>) {
        guard let url = URL(string: endpoint + "/users") else {
            print("Wrong enpoint")
            return
        }
        
        NetworkProvider.shared.baseDataTask(url: url,
                                            httpMethod: "POST",
                                            headers: ["Content-Type": "application/json",
                                                      "Token": token],
                                            body: requestModel.asData(),
                                            completion: response).resume()
    }
    
    func generateToken(response: @escaping NetworkCompletion<TokenModel>) {
        guard let url = URL(string: endpoint + "/token") else {
            print("Wrong enpoint")
            return
        }
        
        NetworkProvider.shared.baseDataTask(url: url,
                                            httpMethod: "POST",
                                            headers: ["Content-Type": "application/json"],
                                            completion: response).resume()
        
    }
    
    func getPositions(response: @escaping NetworkCompletion<PositionModel>) {
        guard let url = URL(string: endpoint + "/positions") else {
            print("Wrong enpoint")
            return
        }
        
        NetworkProvider.shared.baseDataTask(url: url,
                                            httpMethod: "GET",
                                            headers: ["Content-Type": "application/json"],
                                            completion: response).resume()
        
    }
}
