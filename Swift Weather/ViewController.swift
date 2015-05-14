//
//  ViewController.swift
//  Swift Weather
//
//  Created by xuhui on 15/5/13.
//  Copyright (c) 2015年 xuhui. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    // 定义常量 locationManager
    let locationManager:CLLocationManager = CLLocationManager()

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLab: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 设置精度
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        
        let background:UIImage! = UIImage(named: "background")
        self.view.backgroundColor = UIColor(patternImage: background)
        
        self.loadingIndicator.startAnimating()
        
        if IOS8()
        {
            locationManager.requestAlwaysAuthorization()
        }
        
        locationManager.startUpdatingLocation()
        
    }
    
    /**
    IOS8判断
    
    :returns:
    */
    func IOS8() -> Bool
    {
        var version:String = UIDevice.currentDevice().systemVersion
        
        let indexRange:Range<String.Index>? = version.rangeOfString(".", options: NSStringCompareOptions.BackwardsSearch)
        
        var versionInt:Int? = version.substringToIndex(indexRange!.startIndex).toInt()
        
        return versionInt! >= 8
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!)
    {
        var location:CLLocation = locations[locations.count - 1] as! CLLocation
        
        if location.horizontalAccuracy > 0
        {
            println(location.coordinate.latitude)
            println(location.coordinate.longitude)
            
            //调用接口获取天气
            updateWeatherInfo(location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!)
    {
        println(error)
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        self.loadingLab.text = "地理位置信息不可用"
    }
    
    /**
    获取天气
    
    :param: latitude  纬度
    :param: longitude 经度
    */
    func updateWeatherInfo(latitude:CLLocationDegrees, longitude:CLLocationDegrees)
    {
        let url = "http://api.openweathermap.org/data/2.5/weather"
        let params = ["lat":latitude, "lon":longitude, "cnt":0]
        
        let httpManager = AFHTTPRequestOperationManager()

        httpManager.requestSerializer.setValue("text/html", forHTTPHeaderField: "content-type")
        
        httpManager.GET(url,
            parameters: params,
            success: { (operation:AFHTTPRequestOperation!, responseObject:AnyObject!) -> Void in
                println(responseObject.description)
                
                self.updateUISuccess(responseObject as! NSDictionary)
                
            },
            failure:{ (operation:AFHTTPRequestOperation!, error:NSError!) -> Void in
                println(error.localizedDescription)
                self.loadingIndicator.hidden = true
                self.loadingIndicator.stopAnimating()
                self.loadingLab.text = "天气信息不可用"
            }
        )
        
    }
    
    /**
    解析数据
    
    :param: jsonResult
    */
    func updateUISuccess(jsonResult:NSDictionary!)
    {
        self.loadingIndicator.hidden = true
        self.loadingIndicator.stopAnimating()
        self.loadingLab.text = nil
        
        if let tempResult = (jsonResult["main1"] as! NSDictionary)["temp"] as? Double
        {
            var tempTxt: Double
            if (jsonResult["sys"] as! NSDictionary)["country"] as? String == "US"
            {
                tempTxt = round(((tempResult - 273.15) * 1.8) + 32)
            }
            else
            {
                tempTxt = round(tempResult - 273.15)
            }
            
//            self.temperature.text = String(format: "%.0f°", tempTxt)
            self.temperature.text = "\(tempTxt)°"
            
            var name = jsonResult["name"] as! String
            self.location.text = "\(name)"
            
            var condition = ((jsonResult["weather"] as! NSArray)[0] as! NSDictionary)["id"] as? Int
            var sunrise = (jsonResult["sys"] as! NSDictionary)["sunrise"] as? Double
            var sunset = (jsonResult["sys"] as! NSDictionary)["sunset"] as? Double

            var nightTime = false
            var now = NSDate().timeIntervalSince1970
            
            if now < sunrise || now > sunset
            {
                nightTime = true
            }
            self.updateWeatherIcon(condition!, nightTime: nightTime)
            
        }
        else
        {
            self.loadingLab.text = "数据异常"
        }
    }
    
    
    func updateWeatherIcon(condition:Int, nightTime:Bool)
    {
        if condition < 300
        {
            if nightTime
            {
                self.icon.image = UIImage(named: "tstorm1_night")
            }
            else
            {
                self.icon.image = UIImage(named: "tstorm1")
            }
        }
        else if condition < 500
        {
            self.icon.image = UIImage(named: "light_rain")
        }
        else if condition < 600
        {
            self.icon.image = UIImage(named: "shower3")
        }
        else if condition < 700
        {
            self.icon.image = UIImage(named: "shower4")
        }
        else if condition < 771
        {
            if nightTime
            {
                self.icon.image = UIImage(named: "fog_night")
            }
            else
            {
                self.icon.image = UIImage(named: "fog")
            }
        }
        else if condition < 800
        {
            self.icon.image = UIImage(named: "tstorm3")
        }
        else if condition == 800
        {
            if nightTime
            {
                self.icon.image = UIImage(named: "sunny_night")
            }
            else
            {
                self.icon.image = UIImage(named: "sunny")
            }
        }
        else if condition <= 804
        {
            if nightTime
            {
                self.icon.image = UIImage(named: "cloudy2_night")
            }
            else
            {
                self.icon.image = UIImage(named: "cloudy2")
            }
        }
        else if (condition >= 900 && condition < 903) || (condition > 904 && condition < 1000)
        {
            self.icon.image = UIImage(named: "tstorm3")
        }
        else if condition == 903
        {
            self.icon.image = UIImage(named: "snow5")
        }
        else if condition == 904
        {
            self.icon.image = UIImage(named: "dunno")
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

