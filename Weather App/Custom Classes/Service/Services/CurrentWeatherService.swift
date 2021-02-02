//
//  CurrentWeatherService.swift
//  Weather App
//
//  Created by Nika Nikolishvili on 01.02.21.
//

import Foundation

class CurrentWeatherService {
    
    //TODO: Handle errors
    private let apiKey = "cf270b8b540ec2bbdc4c6aa1093b0653" //TODO: Move into Keychain
    private var components = URLComponents()
    private var databaseContext = DatabaseManager.shared.persistentContainer.viewContext
    
    init() {
        //TODO: Find a way to avoid duplication
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/weather"
    }
    
    func getCurrentWeather(for city: String) {
        let parameters = [
            "q": city,
            "units": "metric",
            "appid": apiKey
        ]
        components.queryItems = parameters.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        
        if let url = components.url {
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let result = try decoder.decode(CurrentWeatherResponse.self, from: data)
                        DatabaseManager.addLocation(id: result.id, city: result.name, country: result.sys.country, in: self.databaseContext)
                        DatabaseManager.updateCurrentWeather(with: result, in: self.databaseContext)
                    } catch {
                        print(error)
                    }
                } else {
                    print("No Data")
                }
            })
            task.resume()
        } else {
            print("Invalid Parameters")
        }
    }
}