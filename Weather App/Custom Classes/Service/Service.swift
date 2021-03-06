//
//  Service.swift
//  Weather App
//
//  Created by Nika Nikolishvili on 01.02.21.
//

import Foundation
import CoreLocation

class Service<T: Codable> {
    
    private final let apiKey = openWeatherAPIKey
    private var components = URLComponents()
    
    init() {
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/"
        
        switch T.self {
        case is CurrentWeatherResponse.Type:
            components.path += "weather"
        case is ForecastResponse.Type:
            components.path += "forecast"
        default:
            break
        }
    }
    
    func getServiceResult(for city: String?, at location: CLLocationCoordinate2D?, completion: @escaping (Result<T, Error>) -> ()) {
        var parameters = [
            "units": "metric",
            "appid": apiKey
        ]
        if (city != nil) {
            parameters["q"] = city ?? ""
        } else if (location != nil) {
            parameters["lat"] = location?.latitude.description ?? ""
            parameters["lon"] = location?.longitude.description ?? ""
        } else {
            completion(.failure(ServiceError.invalidParameters))
        }
        
        components.queryItems = parameters.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        
        if let url = components.url {
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode(T.self, from: data)
                        completion(.success(result))
                    } catch {
                        completion(.failure(ServiceError.keyNotFound))
                    }
                } else {
                    completion(.failure(ServiceError.noData))
                }
            })
            task.resume()
        } else {
            completion(.failure(ServiceError.invalidParameters))
        }
    }
}

enum ServiceError: Error {
    case noData
    case invalidParameters
    case keyNotFound
}
