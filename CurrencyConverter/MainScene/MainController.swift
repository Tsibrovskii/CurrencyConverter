//
//  MainController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 18/06/2023.
//

import UIKit

protocol MainControllerProtocol {
    func recalculateTotalAmount(amount: Double?)
}

final class MainController: UIViewController, MainControllerProtocol {
    
    private let baseCurrencyController: BaseCurrencyViewController
    private let currencyService: CurrencyServiceProtocol
    private let currenciesStorage: CurrenciesStorageProtocol
    private let userSettings: UserSettingsProtocol
    
    private var exchangeRateData: [Exchange.ExchangeRate] = []
    private var amountDouble: Double = 1
    
    private var beforeUpdateCurrencies: [String] = []
    private var beforeUpdateBaseCurrency: String = ""

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
        view.backgroundColor = .white
        view.delegate = self
        view.dataSource = self
        view.tableFooterView = UIView()
        view.separatorStyle = .none
        view.register(CurrencyInfoCell.self, forCellReuseIdentifier: Constants.currencyCellInfo)
        return view
    }()
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .medium)
    
    private lazy var errorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.isHidden = true
        return view
    }()
    
    private lazy var errorMessage: UILabel = {
        let labelErrorMessage = UILabel()
        labelErrorMessage.text = "Something got wrong. Please try again later."
        labelErrorMessage.textColor = .gray
        labelErrorMessage.isHidden = true
        return labelErrorMessage
    }()

    private lazy var tryAgainButton: UIButton = {
        let tryAgainButton = UIButton()
        tryAgainButton.setTitle("Try again", for: .normal)
        tryAgainButton.backgroundColor = .blue
        tryAgainButton.isHidden = true
        tryAgainButton.layer.cornerRadius = 8
        tryAgainButton.addTarget(self, action: #selector(self.tryAgain), for: .touchUpInside)
        return tryAgainButton
    }()

    override func viewDidLoad() {
        view.backgroundColor = .white
        beforeUpdateCurrencies = userSettings.currencies
        beforeUpdateCurrencies.sort()
        beforeUpdateBaseCurrency = userSettings.currentCurrency
        
        setupSubviews()
        setupNavBar()
        addSubViewController(viewController: baseCurrencyController)
        requestInitialData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (isSettingsChanged()) {
            requestConversionRates()
            updateBaseCurrencyView()
        }
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
        
        let imageName = UIImage(named: exchangeRateData[indexPath.row].currency.uppercased()) != nil ? exchangeRateData[indexPath.row].currency.uppercased() : "default"
        let model = CurrencyInfoCell.Model(
            currencyId: currencyId,
            currencyName: currenciesStorage.getSymbolName(by: currencyId) ?? "",
            totalAmount: String(amountDouble * exchangeRateData[indexPath.row].rate),
            currencyExchangeRate: String(exchangeRateData[indexPath.row].rate),
            image: UIImage(named: imageName) ?? UIImage()
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
    
    func isSettingsChanged() -> Bool {      
        var currenciesSorted = userSettings.currencies.map { $0 }
        currenciesSorted.sort()

        if (beforeUpdateBaseCurrency != userSettings.currentCurrency) {
            beforeUpdateBaseCurrency = userSettings.currentCurrency
            return true
        }
        if (beforeUpdateCurrencies != currenciesSorted) {
            beforeUpdateCurrencies = currenciesSorted
            return true
        }
        return false
    }
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(goToCurrenciesList))
        title = "💱 Currencies"
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
    
    @objc func tryAgain() {
        hideError()
        requestInitialData()
    }

    func showLoader() {
        loadingView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoader() {
        loadingView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func showError() {
        errorView.isHidden = false
        errorMessage.isHidden = false
        tryAgainButton.isHidden = false
    }
    
    func hideError() {
        errorView.isHidden = true
        errorMessage.isHidden = true
        tryAgainButton.isHidden = true
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
        let imageName = UIImage(named: userSettings.currentCurrency) != nil ? userSettings.currentCurrency : "default"
        let model = BaseCurrencyViewController.Model(
            currencyId: userSettings.currentCurrency,
            currencyName: currenciesStorage.getSymbolName(by: userSettings.currentCurrency) ?? "",
            currencyImage: UIImage(named: imageName) ?? UIImage()
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
        view.addSubview(errorMessage)
        view.addSubview(tryAgainButton)
        loadingView.addSubview(activityIndicator)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        baseCurrencyView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorMessage.translatesAutoresizingMaskIntoConstraints = false
        tryAgainButton.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tintColor = .red

        NSLayoutConstraint.activate([
            baseCurrencyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIGrid.padding),
            baseCurrencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIGrid.padding),
            baseCurrencyView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIGrid.padding),
            tableView.topAnchor.constraint(equalTo: baseCurrencyView.bottomAnchor, constant: UIGrid.padding),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: UIGrid.padding),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIGrid.padding),
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor),
        ])
        
        [loadingView, errorView].forEach {
            $0.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            $0.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            $0.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            $0.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
        errorMessage.centerXAnchor.constraint(equalTo: errorView.centerXAnchor).isActive = true
        errorMessage.centerYAnchor.constraint(equalTo: errorView.centerYAnchor).isActive = true
        tryAgainButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor).isActive = true
        tryAgainButton.bottomAnchor.constraint(equalTo: errorView.bottomAnchor, constant: -UIGrid.padding).isActive = true
    }
}

