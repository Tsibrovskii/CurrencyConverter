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
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .large)
    
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
            currencyName: currenciesStorage.items.first{ $0.key == currencyId }?.value ?? "",
            totalAmount: String(amountDouble * exchangeRateData[indexPath.row].rate),
            currencyExchangeRate: String(exchangeRateData[indexPath.row].rate),
            image: UIImage(named: exchangeRateData[indexPath.row].currency.uppercased()) ?? UIImage()
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
        startLoading()
    }
    
    func hideLoader() {
        loadingView.isHidden = true
        stopLoading()
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
            self.hideLoader()
            switch result {
            case .success(let exchangeRates):
                self.exchangeRateData = exchangeRates
                self.tableView.reloadData()
            case .failure(_):
                self.showError()
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
            self.hideLoader()
            if let ratesData = try? getExchangeRatesResult?.get(), let currenciesData = try? getCurrenciesResult?.get() {
                self.exchangeRateData = ratesData
                self.currenciesStorage.items = currenciesData
                self.tableView.reloadData()
                self.updateBaseCurrencyView()
            } else {
                self.showError()
            }
        }
    }
    
    func updateBaseCurrencyView() {
        let model = BaseCurrencyViewController.Model(
            currencyId: userSettings.currentCurrency,
            currencyName: currenciesStorage.items.first{ $0.key == userSettings.currentCurrency }?.value ?? "",
            currencyImage: UIImage(named: userSettings.currentCurrency) ?? UIImage()
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
        view.addSubview(activityIndicator)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        baseCurrencyView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .red
        activityIndicator.backgroundColor = .orange
        activityIndicator.layer.cornerRadius = 16
        activityIndicator.isHidden = true
        stopLoading()

        NSLayoutConstraint.activate([
            baseCurrencyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            baseCurrencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            baseCurrencyView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            tableView.topAnchor.constraint(equalTo: baseCurrencyView.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.heightAnchor.constraint(equalToConstant: 32),
            activityIndicator.widthAnchor.constraint(equalToConstant: 32)
        ])
        
        [loadingView, errorView].forEach {
            $0.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
    }
    
    func startLoading() {
        view.bringSubviewToFront(activityIndicator)
        
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }
}

