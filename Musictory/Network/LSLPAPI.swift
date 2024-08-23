//
//  LSLPAPI.swift
//  Musictory
//
//  Created by 김상규 on 8/18/24.
//

import Foundation

final class LSLP_API {
    static let shared = LSLP_API()
    private init() { }
    
    func callRequest<T: Decodable>(apiType: LSLPRouter, decodingType: T.Type, completionHandler: ((Result<T, NetworkError>) -> Void)? = nil) {
        
        let encodingUrl = apiType.baseURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var component = URLComponents(string: encodingUrl)
        component?.queryItems = apiType.parameters
        
        guard let url = component?.url else { return }
        var request = URLRequest(url: url.appendingPathComponent(apiType.path))
        request.httpMethod = apiType.method
        request.allHTTPHeaderFields = apiType.header
        request.httpBody = apiType.httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print(error?.localizedDescription)
                    
                    return
                }
                
                guard let response = response as? HTTPURLResponse else {
                    print("response error")
                    
                    return
                }
                
                switch response.statusCode {
                case 200 :
                    guard let data = data else { return }
                    do {
                        let result = try JSONDecoder().decode(decodingType.self, from: data)
                        return completionHandler?(.success(result)) ?? ()
                        
                    } catch {
                        completionHandler?(.failure(.decodingError("디코딩 에러")))
                    }
                default:
                    let error = apiType.errorHandler(statusCode: response.statusCode)
                    print(error, 1)
                    print(response.statusCode)
                    completionHandler?(.failure(error))
                }
            }
        }.resume()
    }
}
