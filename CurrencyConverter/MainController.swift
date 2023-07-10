//
//  MainController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 18/06/2023.
//

import UIKit

final class MainController: UIViewController {

    private var selectedCurrencies = Set<String>()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .blue
        view.delegate = self
        view.dataSource = self
        view.register(CurrencyInfoCell.self, forCellReuseIdentifier: Constants.currencyCellInfo)
        return view
    }()

    override func viewDidLoad() {
        view.backgroundColor = .orange
        setupSubviews()
        setupNavBar()
    }
}

private extension MainController {
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(goToCurrenciesList))
    }
    
    @objc
    func goToCurrenciesList() {
        let vc = CurrencyListViewFactory().create()
        vc.currencyDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension MainController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.currencyCellInfo,
            for: indexPath
        ) as? CurrencyInfoCell
        
        let model = CurrencyInfoCell.Model(
            currencyId: "usd",
            currencyName: "united state dollar",
            totalAmount: "303248201470214788723148780294920174921389",
            currencyExchangeRate: "303248201470214788723148780294920174921389"
        )
        cell?.update(with: model)
        return cell ?? UITableViewCell()
    }
}

extension MainController: CurrencyListViewDelegateProtocol {
    
    enum Constants {
        static let currencyCellInfo = "CurrencyInfoCellId"
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func selectionChanged(currencyId: String, isSelected: Bool) {
        if isSelected {
            selectedCurrencies.insert(currencyId)
        } else {
            selectedCurrencies.remove(currencyId)
        }
        print("selected currencies \(selectedCurrencies)")
    }
}
