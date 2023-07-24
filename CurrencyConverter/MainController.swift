//
//  MainController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 18/06/2023.
//

import UIKit

final class MainController: UIViewController {
    
    private var selectedCurrencies = Set<String>() // TODO: на будующее, перейти на сеттинги UserDefault?
    private let baseCurrencyController: BaseCurrencyViewController
    private let currencyService: ServiceProtocol
    
    private var data: [Exchange.ExchangeRate] = []
    private var amountDouble: Double
    
    init(currencyService: ServiceProtocol, baseCurrencyController: BaseCurrencyViewController) {
        self.currencyService = currencyService
        self.baseCurrencyController = baseCurrencyController
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
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "main-image"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var currenciesLabel: UILabel = {
        let currenciesLabel = UILabel()
        currenciesLabel.text = "Currencies"
        currenciesLabel.font = UIFont.boldSystemFont(ofSize: 36)
        return currenciesLabel
    }()
    
    private lazy var labelFrom: UILabel = {
        let labelFrom = UILabel()
        labelFrom.text = "From:"
        labelFrom.font = UIFont.boldSystemFont(ofSize: 16)
        labelFrom.textColor = .gray
        return labelFrom
    }()
    
    private lazy var labelTo: UILabel = {
        let labelTo = UILabel()
        labelTo.text = "To:"
        labelTo.font = UIFont.boldSystemFont(ofSize: 16)
        labelTo.textColor = .gray
        return labelTo
    }()
    
    override func viewDidLoad() {
        let defaults = UserDefaults.standard
        defaults.set("sek", forKey: "BaseCurrency")
        let defaultCurrencies = ["usd", "rub", "eur"]
        defaults.set(defaultCurrencies, forKey: "DefaultCurrencies")
        //как с defaults работать? нужен !
        selectedCurrencies = Set<String>(defaults.stringArray(forKey: "DefaultCurrencies")!)
        view.backgroundColor = .orange
        
        currencyService.getExchangeRates(baseCurrency: defaults.string(forKey: "BaseCurrency")!, currencyList: Array(selectedCurrencies)) { [weak self] result in
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
        
        setupSubviews()
        setupNavBar()
        addSubViewController(viewController: baseCurrencyController)
    }
}

private extension MainController {
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(goToCurrenciesList))
        title = "Currencies"
        navigationController?.navigationBar.prefersLargeTitles = true
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
        
        let model = CurrencyInfoCell.Model(
            currencyId: data[indexPath.row].currency,
            currencyName: "united state dollar",
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
        view.addSubview(labelFrom)
        view.addSubview(labelTo)
        view.addSubview(baseCurrencyView)
        
        labelFrom.translatesAutoresizingMaskIntoConstraints = false
        labelTo.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        baseCurrencyView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            labelFrom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            labelFrom.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            baseCurrencyView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            baseCurrencyView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            baseCurrencyView.topAnchor.constraint(equalTo: labelFrom.bottomAnchor, constant: 10),
            labelTo.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            labelTo.topAnchor.constraint(equalTo: baseCurrencyView.bottomAnchor, constant: 10),
            tableView.topAnchor.constraint(equalTo: labelTo.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
    }
    
    func selectionChanged(currencyId: String, isSelected: Bool) {
        if isSelected {
            selectedCurrencies.insert(currencyId)
        } else {
            selectedCurrencies.remove(currencyId)
        }
        print("selected currencies \(selectedCurrencies)")
    }
    
    func recalculateTotalAmount(amount: String) {
        amountDouble = Double(amount) ?? 1
        tableView.reloadData()
    }
}
