//
//  MainController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 18/06/2023.
//

import UIKit

final class MainController: UIViewController {
    
    private let baseCurrencyController: BaseCurrencyViewController
    private let currencyService: CurrencyServiceProtocol
    private let currenciesStorage: CurrenciesStorageProtocol
    private let userSettings: UserSettingsProtocol
    
    private var exchangeRateData: [Exchange.ExchangeRate] = []
    private var amountDouble: Double = 1

    init(
        currencyService: CurrencyServiceProtocol,
        baseCurrencyController: BaseCurrencyViewController,
        userSettings: UserSettingsProtocol,
        currenciesStorage: CurrenciesStorageProtocol
    ) {
        self.currencyService = currencyService
        self.baseCurrencyController = baseCurrencyController
        self.userSettings = userSettings
        self.currenciesStorage = currenciesStorage
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
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
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.isHidden = true
        return view
    }()
    
    private lazy var errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .yellow
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .orange
        
        setupSubviews()
        setupNavBar()
        addSubViewController(viewController: baseCurrencyController)
        requestInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        requestConversionRates()
    }
    
    func recalculateTotalAmount(amount: Double?) {
        amountDouble = amount ?? 1.0
        tableView.reloadData()
    }
}

extension MainController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension MainController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        exchangeRateData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.currencyCellInfo,
            for: indexPath
        ) as? CurrencyInfoCell
        
        let currencyId = exchangeRateData[indexPath.row].currency

        let model = CurrencyInfoCell.Model(
            currencyId: currencyId,
            currencyName: "test",
            totalAmount: String(amountDouble * exchangeRateData[indexPath.row].rate),
            currencyExchangeRate: String(exchangeRateData[indexPath.row].rate),
            image: UIImage(named: exchangeRateData[indexPath.row].currency.lowercased()) ?? UIImage()
        )
        cell?.update(with: model)
        return cell ?? UITableViewCell()
    }
}

extension MainController: CurrencyListViewDelegateProtocol {
        
    func selectionChanged(currencyId: String, isSelected: Bool) {
        if isSelected {
            userSettings.currencies.append(currencyId)
        } else {
            if let index = userSettings.currencies.firstIndex(of: currencyId) {
                userSettings.currencies.remove(at: index)
            }
        }
        print("selected currencies \(userSettings.currencies)")
    }
}

private extension MainController {
    
    enum Constants {
        static let currencyCellInfo = "CurrencyInfoCellId"
    }
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(goToCurrenciesList))
        title = "💱 Currencies"
//        navigationController?.navigationBar.prefersLargeTitles = true
        //.always почему-то не работает?
        navigationItem.largeTitleDisplayMode = .never
    }
    
    @objc
    func goToCurrenciesList() {
        let vc = CurrencyListViewFactory().create(
            data: currenciesStorage.items,
            selectedIds: userSettings.currencies
        )
        vc.currencyDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showLoader() {
        loadingView.isHidden = false
    }
    
    func hideLoader() {
        loadingView.isHidden = true
    }
    
    func showError() {
        errorView.isHidden = false
    }
    
    func hideError() {
        errorView.isHidden = true
    }
    
    func requestConversionRates() {
        showLoader()
        currencyService.getExchangeRates(baseCurrency: userSettings.currentCurrency, currencyList: userSettings.currencies) { [weak self] result in
            guard let self else { return }
            hideLoader()
            switch result {
            case .success(let exchangeRates):
                exchangeRateData = exchangeRates
                tableView.reloadData()
            case .failure(_):
                showError()
            }
        }
    }
    
    func requestInitialData() {
        showLoader()
        
        let requestGroup = DispatchGroup()
        
        requestGroup.enter()
        requestGroup.enter()
        
        var getCurrenciesResult: Result<[CurrencyList.CurrencySymbol], SerivceError>?
        var getExchangeRatesResult: Result<[Exchange.ExchangeRate], SerivceError>?
        
        currencyService.getCurrencies { (result: Result<[CurrencyList.CurrencySymbol], SerivceError>) in
            getCurrenciesResult = result
            requestGroup.leave()
        }
        
        currencyService.getExchangeRates(
            baseCurrency: userSettings.currentCurrency,
            currencyList: userSettings.currencies
        ) { (result: Result<[Exchange.ExchangeRate], SerivceError>) in
            getExchangeRatesResult = result
            requestGroup.leave()
        }
        
        requestGroup.notify(queue: .main) { [weak self] in
            guard let self else { return }
            hideLoader()
            if let ratesData = try? getExchangeRatesResult?.get(), let currenciesData = try? getCurrenciesResult?.get() {
                exchangeRateData = ratesData
                currenciesStorage.items = currenciesData
                tableView.reloadData()
                updateBaseCurrencyView()
            } else {
                showError()
            }
        }
    }
    
    func updateBaseCurrencyView() {
        // TODO: currencyId нужно брать уже из настроек
        // currencyName уже можно брать из currenciesStorage
        ///
        let model = BaseCurrencyViewController.Model(
            currencyId: "SEK",
            currencyName: "Swedich krona",
            currencyImage: UIImage(named: "SEK") ?? UIImage()
        )
        baseCurrencyController.update(with: model)
    }
    
    func addSubViewController(viewController: UIViewController) {
        addChild(viewController)
        viewController.didMove(toParent: self)
    }
    
    func setupSubviews() {
        baseCurrencyController.delegate = self
        
        let baseCurrencyView: UIView = baseCurrencyController.view
        view.addSubview(tableView)
        view.addSubview(baseCurrencyView)
        view.addSubview(loadingView)
        view.addSubview(errorView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        baseCurrencyView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            baseCurrencyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            baseCurrencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            baseCurrencyView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            tableView.topAnchor.constraint(equalTo: baseCurrencyView.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        [loadingView, errorView].forEach {
            $0.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }
}

