//
//  MainControllerFactory.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 24/07/2023.
//

import Foundation

final class MainControllerFactory {
    func create() -> MainController {
        MainController(
            currencyService: CurrenciesServiceFactory().create(),
            baseCurrencyController: BaseCurrencyViewControllerFactory().create(),
            userSettings: UserSettings(),
            currenciesStorage: CurrenciesStorage.shared
        )
    }
}
