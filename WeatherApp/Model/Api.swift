//
//  Api.swift
//  WeatherApp
//
//  Created by 林煜凱 on 11/10/21.
//

import Foundation

struct Weather: Codable {
    var lat: Double
    var lon: Double
    var current: CurrentWeather
    var timezone: String
    var daily: [DailyWeather]
    var hourly: [HourlyWeather]

}
struct CurrentWeather: Codable {
    var dt: Double
    var temp: Float
    var weather: [CurrentWeatherSub]
}

struct CurrentWeatherSub: Codable {
    var main: String
    var description: String
    var icon: String
}

struct DailyWeather: Codable {
    var daytime: Double
    var temp: [String: Float]
    var weather: [CurrentWeatherSub]
    
    enum CodingKeys: String, CodingKey {
        case daytime = "dt"
        case temp
        case weather
    }
}
struct HourlyWeather: Codable {
    var daytime: Double
    var temp: Float
    var weather: [CurrentWeatherSub]
    
    enum CodingKeys: String, CodingKey {
        case daytime = "dt"
        case temp
        case weather
    }
}

struct Coordinate: Codable, Hashable {
    var lat: Double
    var lon: Double
    var current: Bool = false
}

struct WeatherAndCityNameCombine {
    var weather: Weather
    var cityName: String
}
class WeatherApi {
    
    
    static func getWeather(coordinate: (lat:Double,lon:Double) ,completion: @escaping (Result<Weather, Error>) -> Void ) {
        let url = "https://api.openweathermap.org/data/2.5/onecall?lat=\(coordinate.lat)&lon=\(coordinate.lon)&exclude=minutely&appid=2a5f8913bcbee5cf5a28aa3e122da8ef&lang=zh_tw&units=metric"
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            
            if error != nil {
                print(error)
            }
            guard let data = data else {
               return
            }
            do {
                let weatherInfo = try JSONDecoder().decode(Weather.self, from: data)
                //print("at api...weatherInfo.. \(weatherInfo)")
                completion(.success(weatherInfo))
            } catch {
                print(error)
                completion(.failure(error))
            }
        }
        
        task.resume()
        
        
    }
    
    static func getMultipleWeather(coordinates: Set<Coordinate>, completion: @escaping ([Result<Weather, Error>]) -> Void) {
        let group = DispatchGroup()
        var multipleWeather: [Result<Weather, Error>] = []
        for location in coordinates {
            group.enter()
          
            WeatherApi.getWeather(coordinate: (lat: location.lat,lon: location.lon)) { result in
                multipleWeather.append(result)
                
                group.leave()
            }
           
        }
        group.notify(queue: .main) {
          
            completion(multipleWeather)
        }
        //print("multipleWeather...\(multipleWeather)")
        
        
    }
}

struct LocationResponse: Codable {
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    
}


class LocationApi {
    static func searchCoordinate(locationName: String ,completion: @escaping (Result<[LocationResponse], Error>) -> Void ) {
        let url = "https://api.openweathermap.org/geo/1.0/direct?q=\(locationName)&limit=5&appid=2a5f8913bcbee5cf5a28aa3e122da8ef"
        let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, response, error in
            
            if error != nil {
                print(error)
            }
            guard let data = data else {
               return
            }
            do {
                let locationInfo = try JSONDecoder().decode([LocationResponse].self, from: data)
                //print("at api...weatherInfo.. \(weatherInfo)")
                completion(.success(locationInfo))
            } catch {
                print(error)
                completion(.failure(error))
            }
        }
        
        task.resume()
        
        
    }
}
