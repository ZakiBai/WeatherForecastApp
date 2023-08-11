//
//  ViewController.swift
//  WeatherForecastApp
//
//  Created by Zaki on 09.08.2023.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    private let backgroundImageView = UIImageView()
    private var weatherImageView = UIImageView()
    
    private let temperatureLabel = UILabel()
    private let temperatureDegreeLabel = UILabel()
    
    private let feelsLikeTemperatureLabel = UILabel()
    private let feelsLikeTemperatureDegreeLabel = UILabel()
    
    private let weatherCityLabel = UILabel()
    private let searchButton = UIButton()
    
    private let bothWeatherStackView = UIStackView()
    private let mainWeatherStackView = UIStackView()
    private let feelWeatherStackView = UIStackView()
    private let bottomStackView = UIStackView()
    
    private var networkManager = NetworkManager.shared
    
    
    lazy var locationManager: CLLocationManager = {
        let lm = CLLocationManager()
        lm.delegate = self
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        lm.requestWhenInUseAuthorization()
        return lm
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        setLayoutConstraints()
        stylize()
        setActions()
    
        networkManager.onCompletion = { [weak self] currentWeather in
            guard let self = self else { return }
            self.setUpInterface(withCurrentWeatherData: currentWeather)
        }
        DispatchQueue.global(qos: .userInteractive).async {
            if CLLocationManager.locationServicesEnabled() {
                DispatchQueue.main.async {
                    self.locationManager.requestLocation()
                }
            } else {
                DispatchQueue.main.async {
                    print("didn't get location")
                }
            }
        }
        
    }
    
    func addSubviews() {
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        view.addSubview(weatherImageView)
        
        view.addSubview(bothWeatherStackView)
        bothWeatherStackView.addArrangedSubview(mainWeatherStackView)
        bothWeatherStackView.addArrangedSubview(feelWeatherStackView)
        
        mainWeatherStackView.addArrangedSubview(temperatureLabel)
        mainWeatherStackView.addArrangedSubview(temperatureDegreeLabel)
        
        feelWeatherStackView.addArrangedSubview(feelsLikeTemperatureLabel)
        feelWeatherStackView.addArrangedSubview(feelsLikeTemperatureDegreeLabel)
        
        view.addSubview(bottomStackView)
        bottomStackView.addArrangedSubview(weatherCityLabel)
        bottomStackView.addArrangedSubview(searchButton)
        
    }
    
    func setLayoutConstraints() {
        var layoutConstraints: [NSLayoutConstraint] = []
        
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        layoutConstraints += [
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        
        weatherImageView.translatesAutoresizingMaskIntoConstraints = false
        layoutConstraints += [
            weatherImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            weatherImageView.widthAnchor.constraint(equalToConstant: 148),
            weatherImageView.heightAnchor.constraint(equalToConstant: 150),
            weatherImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        bothWeatherStackView.translatesAutoresizingMaskIntoConstraints = false
        layoutConstraints += [
            bothWeatherStackView.topAnchor.constraint(equalTo: weatherImageView.bottomAnchor, constant: 40),
            bothWeatherStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ]
        
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        layoutConstraints += [
            bottomStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            bottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ]
        
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        layoutConstraints += [
            searchButton.widthAnchor.constraint(equalToConstant: 31),
            searchButton.heightAnchor.constraint(equalToConstant: 31)
        ]
        NSLayoutConstraint.activate(layoutConstraints)
    }
    
    func stylize() {
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleToFill
        
        weatherImageView.image = UIImage(systemName: "cloud.rain.fill")
        weatherImageView.tintColor = .white
        weatherImageView.contentMode = .scaleAspectFit
        
        bothWeatherStackView.axis = .vertical
        bothWeatherStackView.alignment = .fill
        bothWeatherStackView.distribution = .fill
        bothWeatherStackView.spacing = 0
        
        mainWeatherStackView.axis = .horizontal
        mainWeatherStackView.spacing = 8
        
        temperatureLabel.text = "25"
        temperatureLabel.font = UIFont.systemFont(ofSize: 70, weight: .black)
        temperatureLabel.textColor = .white
        
        temperatureDegreeLabel.text = "ºC"
        temperatureDegreeLabel.font = UIFont.systemFont(ofSize: 70)
        temperatureDegreeLabel.textColor = .white
        
        feelWeatherStackView.axis = .horizontal
        feelWeatherStackView.spacing = 10
        
        feelsLikeTemperatureLabel.text = "Feels like"
        feelsLikeTemperatureLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        feelsLikeTemperatureLabel.textAlignment = .right
        feelsLikeTemperatureLabel.textColor = .white
        
        feelsLikeTemperatureDegreeLabel.text = "23 ºC"
        feelsLikeTemperatureDegreeLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        feelsLikeTemperatureDegreeLabel.textColor = .white
        
        bottomStackView.spacing = 8
        
        weatherCityLabel.text = "Ufa"
        weatherCityLabel.textColor = .white
        weatherCityLabel.font = UIFont.systemFont(ofSize: 28, weight: .medium)
    
        searchButton.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        searchButton.tintColor = .white
        searchButton.imageView?.contentMode = .scaleAspectFill
        searchButton.contentVerticalAlignment = .fill
        searchButton.contentHorizontalAlignment = .fill
    }
    
    func setActions() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
    }

    @objc func searchButtonTapped() {
        self.presentSearchAlertController(title: "Enter city name", message: nil, preferredStyle: .alert) { [unowned self] city in
            self.networkManager.fetchCurrentWeather(forRequestType: .cityName(city: city))
            
        }
    }
}

extension ViewController {
    func presentSearchAlertController(title: String?, message: String?, preferredStyle: UIAlertController.Style, completionHandler: @escaping ((String) -> Void?) ) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        alertController.addTextField { textField in
            let cities = ["Almaty", "Taraz", "London", "New York", "San Francisco"]
            textField.placeholder = cities.randomElement()
            
        }
        
        let search = UIAlertAction(title: "Search", style: .default) { action in
            let textField = alertController.textFields?.first
            guard let cityName = textField?.text else { return }
            if cityName != "" {
                print("Search info for the \(cityName)")
                let city = cityName.split(separator: " ").joined(separator: "%20")
                completionHandler(city)
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(search)
        alertController.addAction(cancel)
        
        present(alertController, animated: true)
    }
}

extension ViewController {
    func setUpInterface(withCurrentWeatherData currentWeather: CurrentWeather) {
        DispatchQueue.main.async {
            self.weatherCityLabel.text = currentWeather.name
            self.temperatureLabel.text = currentWeather.temperatureString
            self.feelsLikeTemperatureDegreeLabel.text = "\(currentWeather.feelsLikeTemperatureString) ºC"
            self.weatherImageView.image = UIImage(systemName: currentWeather.conditionCodeString)
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        print("\(longitude) \(latitude)")
    
        networkManager.fetchCurrentWeather(forRequestType: .coordinates(latitude: latitude, longitude: longitude))
        
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
