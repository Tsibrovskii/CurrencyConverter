//
//  CurrencyListViewFactory.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 10/07/2023.
//

import Foundation

class CurrencyListViewFactory {
    func create() -> CurrencyListViewController {
        CurrencyListViewController(
            currencyService: CurrenciesServiceFactory().create(),
            userSettings: UserSettings.shared
        )
    }
}

