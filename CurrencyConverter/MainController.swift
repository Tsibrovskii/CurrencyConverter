//
//  MainController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 18/06/2023.
//

import UIKit

final class MainController: UIViewController {

    private var selectedCurrencies = Set<String>()

    override func viewDidLoad() {
        view.backgroundColor = .orange
        setupNavBar()
    }
}

private extension MainController {
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(goToCurrenciesList))
    }
    
    @objc
    func goToCurrenciesList() {
        // TODO: перевести на Factory
        // let vc = CurrencyListViewFactory().create()
        // Убрать зависимость от service!
        //
        let service = CurrenciesServiceFactory().create()
        let vc = CurrencyListViewController(currencyService: service, selectedIds: [])
        vc.currencyDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainController: CurrencyListViewDelegateProtocol {
    
    func selectionChanged(currencyId: String, isSelected: Bool) {
        if isSelected {
            selectedCurrencies.remove(currencyId)
        } else {
            selectedCurrencies.insert(currencyId)
        }
        print("selected currencies \(selectedCurrencies)")
    }
}
