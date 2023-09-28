//
//  UserSettings.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 19/09/2023.
//

import Foundation

protocol UserSettingsProtocol: AnyObject {
    var currentCurrency: String { get set }
    var currencies: [String] { get set }
}

final class UserSettings: UserSettingsProtocol {
    
    var currentCurrency: String {
        get {
            UserDefaults.standard.string(forKey: Constants.baseKey) ?? "SEK"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.baseKey)
        }
    }
    
    var currencies: [String] {
        get {
            UserDefaults.standard.stringArray(forKey: Constants.selectedCurrenciesKey) ?? ["USD", "RUB", "EUR"]
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
