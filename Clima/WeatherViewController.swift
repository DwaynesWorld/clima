//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    func getWeatherData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { (response) in
            
            if response.result.isSuccess {
                
                if let data = response.result.value {
                    let weatherJson = JSON(data)
                    self.updateWeatherData(json: weatherJson)
                }
                
            } else {
                
                print("Error \(response.result.error!)")
                self.cityLabel.text = "Internet Connection Issues"
                
            }
        }
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
    func updateWeatherData(json: JSON) {

        guard
            let temp = json["main"]["temp"].double
            else {
                self.cityLabel.text = "Weather Unavailable"
                return
            }
        
        weatherDataModel.temperature = Int(temp - 273.15)
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        self.updateUI()
    }
    
    //MARK: - UI Updates
    /***************************************************************/
    func updateUI() {
        DispatchQueue.main.async {
            self.cityLabel.text = self.weatherDataModel.city
            self.temperatureLabel.text = "\(self.weatherDataModel.temperature)"
            self.weatherIcon.image = UIImage(named: self.weatherDataModel.weatherIconName)
        }
    }
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard
            let location = locations.last, location.horizontalAccuracy > 0
            else { return }
        
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        
        let longitude = String(location.coordinate.longitude)
        let latitude = String(location.coordinate.latitude)
        
        let params: [String : String] = ["lat" : latitude, "lon": longitude, "appid": APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    
    
}


