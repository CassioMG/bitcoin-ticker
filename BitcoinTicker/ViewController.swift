//
//  ViewController.swift
//  BitcoinTicker
//
//  Created by Angela Yu on 23/01/2016.
//  Copyright © 2016 London App Brewery. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    let baseURL = "https://apiv2.bitcoinaverage.com/indices/global/ticker/BTC"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencySymbolArray = ["$", "R$", "$", "¥", "€", "£", "$", "Rp", "₪", "₹", "¥", "$", "kr", "$", "zł", "lei", "₽", "kr", "$", "$", "R"]

    var currencyDict : [String : String] = Dictionary()
    var finalURL = ""
    var selectedCurrency = ""

    @IBOutlet weak var bitcoinPriceLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    
    // MARK: - Lifecylcle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currencyPicker.delegate = self
        currencyPicker.dataSource = self

        initCurrencyDict()
    }

    // Initialize the Currency Dictionary so that we can grab the currency symbol associated with the currency acronym
    func initCurrencyDict () {
        
        for i in 0 ..< currencyArray.count {
            currencyDict[currencyArray[i]] = currencySymbolArray[i]
        }
        
    }
    
    
    // MARK: - UIPickerView Delegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedCurrency = currencyArray[row]
        finalURL = baseURL + selectedCurrency
        
        getPriceData(url: finalURL)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyArray[row]
    }
    
    // MARK: - UIPickerView DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyArray.count
    }
    
    
    // MARK: - Networking
    func getPriceData(url: String) {
        
        Alamofire.request(url, method: .get).responseJSON { response in
            
            if response.result.isSuccess {
                
                let priceJSON : JSON = JSON(response.result.value!)
                self.updatePriceValue(json: priceJSON)
                
            } else {
                print("Error: \(String(describing: response.result.error))")
                self.bitcoinPriceLabel.text = "Connection issues"
                
            }
        }
    }

    // MARK: - JSON Parsing
    func updatePriceValue(json : JSON) {

        print("JSON: ", json)
        
        if let lastPrice = json["last"].double {
            
            if let currencySymbol : String = currencyDict[selectedCurrency] {
                bitcoinPriceLabel.text = "\(currencySymbol) \(lastPrice)"
                
            } else {
                bitcoinPriceLabel.text = "\(lastPrice)"
            }
            
        } else {
            bitcoinPriceLabel.text = "Unable to get last price"
        }
    }

    
}

