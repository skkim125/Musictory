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
    
    func callRequest<T: Decodable>(apiType: LSLPRouter, decodingType: T.Type, completionHandler: @escaping ((T) -> Void)) {
        
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
                
                guard response.statusCode == 200 else {
                    print(apiType.errorHandler(statusCode: response.statusCode))
                    return
                }
                
                guard let data = data else { return }
                do {
                    let result = try JSONDecoder().decode(decodingType.self, from: data)
                    return completionHandler(result)
                    
                } catch {
                    NetworkError.decodingError("애러가 발생했습니다.")
                }
            }
        }.resume()
    }
}
