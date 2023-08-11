//
//  CurrentWeatherData.swift
//  WeatherForecastApp
//
//  Created by Zaki on 11.08.2023.
//

import Foundation

struct CurrentWeatherData: Codable {
    let name: String
    let weather: [Weather]
    let main: Main
}

struct Weather: Codable {
    let id: Int
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
    }
}
