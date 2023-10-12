//
//  BaseCurrencyViewControllerFactory.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 11.10.2023.
//

import Foundation

final class BaseCurrencyViewControllerFactory {
    func create() -> BaseCurrencyViewController {
        BaseCurrencyViewController(
            userSettings: UserSettings(),
            currenciesStorage: CurrenciesStorage.shared
        )
    }
}

