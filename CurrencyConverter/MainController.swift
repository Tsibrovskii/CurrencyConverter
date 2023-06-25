//
//  MainController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 18/06/2023.
//

import UIKit

final class MainController: UIViewController {
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
        navigationController?.pushViewController(vc, animated: true)
    }
}

// Responder Chain
// Message dispatcing

