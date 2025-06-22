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
    
    func uploadMultipartFormData<Result: Codable>(url: URL,
                                                  formFields: [String: String],
                                                  fileFieldName: String,
                                                  fileName: String,
                                                  mimeType: String,
                                                  fileData: Data,
                                                  headers: [String: String]? = nil,
                                                  completion: @escaping NetworkCompletion<Result>) -> URLSessionDataTask {
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        for (key, value) in formFields {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(fileFieldName)\"; filename=\"\(fileName)\"\r\n")
        body.append("Content-Type: \(mimeType)\r\n\r\n")
        body.append(fileData)
        body.append("\r\n")
        
        body.append("--\(boundary)--\r\n")
        
        var allHeaders = headers ?? [:]
        allHeaders["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        appInfoHeaderFields.forEach { (key, value) in
            allHeaders[key] = value
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        allHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.httpBody = body
        
        return session.dataTask(with: request) { data, response, error in
            guard let data = data else {
                completion(.failure(error ?? NSError(domain: "No data", code: -1)))
                return
            }
            do {
                let result = try JSONDecoder().decode(Result.self, from: data)
                completion(.success(result))
            } catch {
                let responseString = String(data: data, encoding: .utf8) ?? "No response string"
                let decodingError = NSError(
                    domain: "DecodingError",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Failed to decode response. \(responseString)",
                        NSUnderlyingErrorKey: error
                    ]
                )
                completion(.failure(decodingError))
            }
        }
    }
}
