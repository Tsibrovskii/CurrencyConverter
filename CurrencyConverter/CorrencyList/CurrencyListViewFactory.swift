//
//  CurrencyListViewFactory.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 10/07/2023.
//

import Foundation

final class CurrencyListViewFactory {
    func create(data: [CurrencyList.CurrencySymbol], selectedIds: [String]) -> CurrencyListViewController {
        CurrencyListViewController(
            data: data,
            selectedIds: selectedIds
        )
    }
}
