//
// NetworkProvider.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import Foundation

typealias DynamicResult<T:Codable> = Result<T, Error>
typealias NetworkCompletion<T:Codable> = (DynamicResult<T>)->Void

final class NetworkProvider {
    
    static let shared = NetworkProvider()
    
    private let timeOut = 90.0
    fileprivate let appInfoHeaderFields: [String:String] = [
        "applicationId": "1"
    ]
    fileprivate let session = URLSession(configuration: .default)
    
    private init() {}
    
    func baseRequest(url: URL, httpMethod:String = "POST", headers: [String:String]? = nil, body: Data? = nil) -> URLRequest {
        let updatedURL: URL
        
        if httpMethod.uppercased() == "GET", let unwrappedBody = body {
            updatedURL = url.addingQueryParameters(from: unwrappedBody) ?? url
        } else {
            updatedURL = url
        }
        
        var request = URLRequest(url: updatedURL)
            request.timeoutInterval = timeOut
            request.httpMethod = httpMethod
        
        appInfoHeaderFields.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        headers?.forEach { (key, value) in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body, httpMethod.uppercased() == "POST" {
            request.httpBody = body
        }
        
        return request
    }
    
    func baseDataTask<Result:Codable>(url: URL,
                                             httpMethod: String = "POST",
                                             headers: [String:String]? = nil,
                                             body: Data? = nil,
                                             completion: @escaping NetworkCompletion<Result>) -> URLSessionDataTask {
        let request = baseRequest(url: url, httpMethod: httpMethod, headers: headers, body: body)
        
        return session.dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data else {
                completion(.failure(error ??  NSError(domain: "Unknown error", code: -11)))
                return
            }
            
            guard !data.isEmpty else {
                let emptyResponse = NSError(
                    domain: "Response error",
                    code: -12,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Server returns empty response"
                    ]
                )
                completion(.failure(emptyResponse))
                return
            }
            
//            print("\n NetworkManager requestGetPersonalizeChartInfo: \(String(describing: String(data: data, encoding: .utf8)))")
            
            let decoder = JSONDecoder()
            do {
               

                let responseResult = try decoder.decode(Result.self, from: data)
                completion(.success(responseResult))
            } catch let decodeError {
                let dataString = String(describing: data.asString())
                let decodingError = NSError(
                    domain: "DecodingError",
                    code: -12,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Failed to decode. \(dataString)",
                        NSUnderlyingErrorKey: decodeError
                    ]
                )
                print("\n NetworkManager baseDataTask response dataString: \(String(describing: dataString))")
                print("\n NetworkManager baseDataTask response decodingError: \(String(describing: decodingError))")
                completion(.failure(decodingError))
            }
        })
    }
}
