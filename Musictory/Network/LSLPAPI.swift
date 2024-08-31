//
//  LSLPAPI.swift
//  Musictory
//
//  Created by 김상규 on 8/18/24.
//

import Foundation
import Kingfisher

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
                    completionHandler?(.failure(.responseError("네트워크를 확인할 수 없습니다.")))
                    return
                }
                
                print("response.url =", response.url)
                print("response.statusCode =", response.statusCode)
                
                switch response.statusCode {
                case 200 :
                    guard let data = data else { return }
                    do {
                        let result = try JSONDecoder().decode(decodingType.self, from: data)
                        return completionHandler?(.success(result)) ?? ()
                        
                    } catch {
                        completionHandler?(.failure(.decodingError("디코딩 에러")))
                    }
                case 419:
                    self.updateRefresh { result in
                        switch result {
                        case .success(let refresh):
                            UserDefaultsManager.shared.accessT = refresh.accessToken
                            KingfisherManager.shared.setHeaders()
                            self.callRequest(apiType: apiType, decodingType: decodingType) { result2 in
                                completionHandler?(result2)
                            }
                        case .failure(let error):
                            completionHandler?(.failure(error))
                        }
                    }
                default:
                    print(response.url)
                    let error = apiType.errorHandler(statusCode: response.statusCode)
                    print(response.statusCode)
                    completionHandler?(.failure(error))
                }
            }
        }.resume()
    }
    
    func uploadRequest<T: Decodable>(apiType: LSLPRouter, decodingType: T.Type, completionHandler: ((Result<T, NetworkError>) -> Void)? = nil) {
        let component = URLComponents(string: apiType.baseURL)
        
        guard let url = component?.url else { return }
        var request = URLRequest(url: url.appendingPathComponent(apiType.path))
        request.httpMethod = apiType.method
        
        guard let boundary = apiType.boundary else { return }
        let contentType = "multipart/form-data; boundary=\(boundary)"
        
        request.allHTTPHeaderFields = [
            APIHeader.sesac.rawValue: APIKey.key,
            APIHeader.authorization.rawValue: UserDefaultsManager.shared.accessT,
            "Content-Type": contentType
        ]
        
        request.httpBody = apiType.httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    return
                }
                
                if let response = response as? HTTPURLResponse {
                    print("Status Code: \(response.statusCode)")
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("Response Body: \(responseBody)")
                    }
                    
                    if response.statusCode == 200 {
                        do {
                            let result = try JSONDecoder().decode(decodingType.self, from: data!)
                            completionHandler?(.success(result))
                            print(result)
                        } catch {
                            completionHandler?(.failure(.decodingError("Decoding error: \(error)")))
                        }
                    } else {
                        completionHandler?(.failure(.responseError("HTTP Error: \(response.statusCode)")))
                    }
                }
            }
        }.resume()
    }

    
    func updateRefresh(completionHandler: ((Result<RefreshModel, NetworkError>) -> Void)? = nil) {
        self.callRequest(apiType: .refresh, decodingType: RefreshModel.self) { result in
            completionHandler?(result)
        }
    }
}
