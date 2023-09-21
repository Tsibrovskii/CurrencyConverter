//
//  UserSettings.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 19/09/2023.
//

import Foundation

final class UserSettings {
    private let defaults = UserDefaults.standard
    
    var currentCurrency: String {
        get {
            defaults.string(forKey: Constants.baseKey) ?? "SEK"
        }
        set {
            defaults.set(newValue, forKey: Constants.baseKey)
        }
    }
    var currencies: [String] {
        get {
            defaults.stringArray(forKey: Constants.selectedCurrenciesKey) ?? ["USD", "RUB", "EUR"]
        }
        set {
            // TODO: обновить настройки
        }
    }
}

private extension UserSettings {
    enum Constants {
        static let baseKey = "BaseCurrency"
        static let selectedCurrenciesKey = "DefaultCurrencies"
    }
}
