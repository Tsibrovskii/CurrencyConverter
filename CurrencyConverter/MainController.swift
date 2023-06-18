//
//  MainController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 18/06/2023.
//

import UIKit

class MainController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = .orange
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(goToCurrenciesList))
    }
    
    @objc func goToCurrenciesList() {
        navigationController?.pushViewController(CurrencyListViewController(currencyService: FactoryController().getCurrenciesService()), animated: true)
    }
}
