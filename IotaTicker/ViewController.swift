//
//  ViewController.swift
//  IotaTicker
//
//  Created by Kristof Van der Jonckheyd on 13/01/18.
//  Copyright © 2018 Kristof Van der Jonckheyd. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let baseURL = "https://api.coinmarketcap.com/v1/ticker/iota/?convert="
    var fullURL = ""
    var currency = ""
    let currencyArray = ["AUD", "BRL", "CAD", "CHF", "CLP", "CNY", "CZK", "DKK", "EUR", "GBP", "HKD", "HUF", "IDR", "ILS", "INR", "JPY", "KRW", "MXN", "MYR", "NOK", "NZD", "PHP", "PKR", "PLN", "RUB", "SEK", "SGD", "THB", "TRY", "TWD", "ZAR"]
    
    let currencySymbolArray = ["$", "R$", "$", "Fr", "chil$" , "¥" , "Kč" , "øre" , "€" , "£" , "HK$" , "Ft" , "Rp" , "₪" ,  "₹" , "¥" , "₩" , "$" , "RM" , "kr" , "NZ$" , "₱" , "Rs" , "zł" , "₽" , "kr" , "S$" , "฿" , "₺" , "NT$" , "R"]
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var courseLabe: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let str : String = currencyArray[row]
        return str
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(currencyArray[row])
        
        currency = currencyArray[row]
        fullURL = baseURL + currency
        print(fullURL)
        var currencySymbol = String(currencySymbolArray[row])
        getCurrencyData(url: fullURL , symbol: currencySymbol)
    }
    
    
    // NETWORKING
    func getCurrencyData(url: String , symbol: String) {
        
        Alamofire.request(fullURL, method: .get)
            .responseJSON { response in
                if response.result.isSuccess {
                    
                    print("Sucess! Currency data retrieved")
                    let currencyJSON : JSON = JSON(response.result.value!)
                    
                    self.updateCurrencyData(json: currencyJSON , symbol: symbol)
                    
                } else {
                    print("Error: \(String(describing: response.result.error))")
                    self.priceLabel.text = "Connection Issues"
                }
        }
    }
    
    
    // PARSING
    func updateCurrencyData(json : JSON , symbol: String) {
        
        if let currencyResult = json[0]["price_"+currency.lowercased()].string {
            let currencyDoubleResult = Double(currencyResult)
            priceLabel.text = symbol + " " + String(format: "%.2f", currencyDoubleResult!)
        } else {
            self.priceLabel.text = "Exchange rate unavailable"
            priceLabel.font = priceLabel.font.withSize(20)
        }
        
        if let courseResult = json[0]["percent_change_24h"].string {
            if Double(courseResult)! >= 0 {
                courseLabe.textColor = UIColor.green
            } else {
                courseLabe.textColor = UIColor.red
            }
            courseLabe.text = courseResult
        } else {
            self.courseLabe.text = "24h course unavailable"
            courseLabe.font = courseLabe.font.withSize(20)
        }
    }
    
    
}

