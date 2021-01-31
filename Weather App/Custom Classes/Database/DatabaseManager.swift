//
//  DatabaseManager.swift
//  Weather App
//
//  Created by Nika Nikolishvili on 29.01.21.
//

import Foundation
import CoreData

final class DatabaseManager {
    static var shared = DatabaseManager()
    
    private init() {}
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Weather_App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func addForecastToDatabase(from result: ForecastResponse, in context: NSManagedObjectContext) {
        let location = Location(context: context)
        location.country = Locale(identifier: "en_US").localizedString(forRegionCode: result.city.country)
        location.city = result.city.name
        
        let forecastList = result.list
        for forecast in forecastList {
            let futureWeather = FutureWeather(context: context)
            let weather = forecast.weather[0]
            
            futureWeather.icon = weather.icon
            futureWeather.date = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            futureWeather.conditionDescription = weather.description
            futureWeather.temperature = forecast.main.temp
            location.addToFutureWeathers(futureWeather)
        }
        
        do {
            try context.save()
        } catch {}
    }
}
