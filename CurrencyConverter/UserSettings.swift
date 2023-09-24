//
//  UserSettings.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 19/09/2023.
//

import Foundation

final class UserSettings {

    enum defaultKeys {
        static let defaultCurrencies = "DefaultCurrencies"
        static let baseCurrency = "BaseCurrency"
    }
    
    static let shared = UserSettings()
    
    var currenciesList: [CurrencyList.CurrencySymbol] = []

    let defaults = UserDefaults.standard
    var currentCurrency: String {
        get {
            defaults.string(forKey: defaultKeys.baseCurrency) ?? "SEK"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: defaultKeys.baseCurrency)
        }
    }
    var currencies: [String] {
        get {
            defaults.stringArray(forKey: defaultKeys.defaultCurrencies) ?? ["USD", "RUB", "EUR"]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: defaultKeys.defaultCurrencies)
        }
    }
}
