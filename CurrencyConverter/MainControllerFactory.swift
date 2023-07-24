//
//  MainControllerFactory.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 24/07/2023.
//

import Foundation

class MainControllerFactory {
    func create() -> MainController {
        MainController(
            currencyService: CurrenciesServiceFactory().create(),
            baseCurrencyController: BaseCurrencyViewController()
        )
    }
}
