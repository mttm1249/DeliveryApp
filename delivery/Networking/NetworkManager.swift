//
//  NetworkManager.swift
//  delivery
//
//  Created by mttm on 04.04.2023.
//

import Foundation

protocol CodableModel: Codable { }

extension Array: CodableModel where Element: CodableModel { }

func asyncMain(action: @escaping () -> Void) {
    DispatchQueue.main.async(execute: action)
}

class NetworkManager {
    
    private static var session: URLSession?
    
    static let shared: NetworkManager = {
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config)
        return NetworkManager()
    }()
    
    func loadJson<T: CodableModel>(urlString: String, completion: @escaping (Result<T, Error>) -> Void) {
        guard let urlComponents = URLComponents(string: urlString) else { return }
        if let url = urlComponents.url {
            let urlSession = NetworkManager.session?.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    asyncMain { completion(.failure(error)) }
                }
                if let data = data {
                    do {
                        let value = try JSONDecoder().decode(T.self, from: data)
                        asyncMain { completion(.success(value)) }
                    } catch {
                        print(error)
                        asyncMain { completion(.failure(error)) }
                    }
                }
            }
            urlSession?.resume()
        }
    }
    
}

