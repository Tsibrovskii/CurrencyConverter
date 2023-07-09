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
        let viewTable = UIView()
        viewTable.backgroundColor = .green
        viewTable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewTable)
        viewTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        viewTable.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        let model = CurrencyInfoCell.Model(
            currencyId: "usd",
            currencyName: "united state dollar",
            totalAmount: "303248201470214788723148780294920174921389",
            currencyExchangeRate: "303248201470214788723148780294920174921389"
        )
        let ci = CurrencyInfoCell()
        ci.update(with: model)
        viewTable.addSubview(ci)

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
            selectedCurrencies.insert(currencyId)
        } else {
            selectedCurrencies.remove(currencyId)
        }
        print("selected currencies \(selectedCurrencies)")
    }
}
