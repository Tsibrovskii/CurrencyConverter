//
//  UserSettings.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 19/09/2023.
//

import Foundation

final class UserSettings {
    
    static let shared = UserSettings()
    
    var currenciesList: [CurrencyList.CurrencySymbol] = []

    let defaults = UserDefaults.standard
    var currentCurrency: String {
        get {
            defaults.string(forKey: Constants.baseKey) ?? "SEK"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.baseKey)
        }
    }
    var currencies: [String] {
        get {
            defaults.stringArray(forKey: Constants.selectedCurrenciesKey) ?? ["USD", "RUB", "EUR"]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.selectedCurrenciesKey)
        }
    }
}

private extension UserSettings {
    enum Constants {
        static let baseKey = "BaseCurrency"
        static let selectedCurrenciesKey = "DefaultCurrencies"
    }
}
