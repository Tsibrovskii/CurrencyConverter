//
//  UserSettings.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 19/09/2023.
//

import Foundation

final class UserSettings {
    let defaults = UserDefaults.standard
    var currentCurrency: String {
        get {
            defaults.string(forKey: "BaseCurrency") ?? "sek"
        }
        set {
        }
    }
    var currencies: [String] {
        get {
            defaults.stringArray(forKey: "DefaultCurrencies") ?? ["usd", "rub", "eur"]
        }
        set {
        }
    }
}
