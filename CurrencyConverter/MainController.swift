//
//  MainController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 18/06/2023.
//

import UIKit

final class MainController: UIViewController {

    private var selectedCurrencies: Set<String> = []

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
        let service = CurrenciesServiceFactory().createCurrenciesService()
        let vc = CurrencyListViewController(currencyService: service, select: [])
        vc.currencyDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainController: CurrencyListViewDelegateProtocol {
    func selectionChanged(currencyId: String, isSelected: Bool) {
        if isSelected {
            guard let index = selectedCurrencies.firstIndex(of: currencyId) else {
                return
            }
            selectedCurrencies.remove(at: index)
        } else {
            selectedCurrencies.insert(currencyId)
        }
        print("selected currencies \(selectedCurrencies)")
    }
}

// Responder Chain
// Message dispatcing

