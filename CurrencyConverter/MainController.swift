//
//  MainController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 18/06/2023.
//

import UIKit

final class MainController: UIViewController {
    
    private let baseCurrencyController: BaseCurrencyViewController
    private let currencyService: ServiceProtocol
    
    private var data: [Exchange.ExchangeRate] = []
    private var amountDouble: Double
    
    private let userSettings: UserSettings

    init(currencyService: ServiceProtocol, baseCurrencyController: BaseCurrencyViewController, userSettings: UserSettings) {
        self.currencyService = currencyService
        self.baseCurrencyController = baseCurrencyController
        self.userSettings = userSettings
        amountDouble = 1
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .blue
        view.delegate = self
        view.dataSource = self
        view.register(CurrencyInfoCell.self, forCellReuseIdentifier: Constants.currencyCellInfo)
        view.separatorInset = .zero
        return view
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .orange
        
        currencyService.getCurrencies() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let symbols):
                self.userSettings.currenciesList = symbols
            case .failure(let error):
                print(error)
                print(error.localizedDescription)
            }
        }
        
        makeTable()
        
        setupSubviews()
        setupNavBar()
        addSubViewController(viewController: baseCurrencyController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        makeTable()
    }
}

private extension MainController {
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(goToCurrenciesList))
        title = "💱 Currencies"
//        navigationController?.navigationBar.prefersLargeTitles = true
        //.always почему-то не работает?
        navigationItem.largeTitleDisplayMode = .never
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
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.currencyCellInfo,
            for: indexPath
        ) as? CurrencyInfoCell
        
        let currencyId = data[indexPath.row].currency
//        let firstIndex = userSettings.currenciesList.
        let model = CurrencyInfoCell.Model(
            currencyId: currencyId,
            currencyName: "test",
            totalAmount: String(amountDouble*data[indexPath.row].rate),
            currencyExchangeRate: String(data[indexPath.row].rate),
            image: UIImage(named: data[indexPath.row].currency.lowercased()) ?? UIImage()
        )
        cell?.update(with: model)
        return cell ?? UITableViewCell()
    }
}

extension MainController: CurrencyListViewDelegateProtocol {
    
    enum Constants {
        static let currencyCellInfo = "CurrencyInfoCellId"
    }
    
    func makeTable() {
        currencyService.getExchangeRates(baseCurrency: userSettings.currentCurrency
                                         , currencyList: userSettings.currencies) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let exchangeRates):
                self.data = exchangeRates
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
                print(error.localizedDescription)
            }
        }
    }
    
    func addSubViewController(viewController: UIViewController) {
        addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func setupSubviews() {
        baseCurrencyController.delegate = self


        let model = BaseCurrencyViewController.BaseCurrencyModel(
            currencyId: "sek",
            currencyName: "Swedich krona",
            image: UIImage(named: "sek") ?? UIImage()
        )
        baseCurrencyController.update(with: model)
        let baseCurrencyView: UIView = baseCurrencyController.view
        view.addSubview(tableView)
        view.addSubview(baseCurrencyView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        baseCurrencyView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            baseCurrencyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            baseCurrencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            baseCurrencyView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            tableView.topAnchor.constraint(equalTo: baseCurrencyView.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func selectionChanged(currencyId: String, isSelected: Bool) {
        if isSelected {
            userSettings.currencies.append(currencyId)
        } else {
            let index = userSettings.currencies.firstIndex(of: currencyId)
            userSettings.currencies.remove(at: index!)
        }
        print("selected currencies \(userSettings.currencies)")
    }
    
    func recalculateTotalAmount(amount: Double?) {
        amountDouble = amount ?? 1.0
        tableView.reloadData()
    }
}
