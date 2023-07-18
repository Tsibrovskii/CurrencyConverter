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
        view.separatorInset = UIEdgeInsets.zero
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
        view.backgroundColor = .orange
        setupSubviews()
        //setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupNavBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.removeFromSuperview()
        currenciesLabel.removeFromSuperview()
    }
}

private extension MainController {
    
    func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(goToCurrenciesList))
        navigationController?.navigationBar.prefersLargeTitles = true
                
        guard let navigationBar = navigationController?.navigationBar else { return }
        //так верно модифицировать nav bar?
        navigationBar.addSubview(imageView)
        navigationBar.addSubview(currenciesLabel)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        currenciesLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currenciesLabel.leadingAnchor.constraint(equalTo: navigationBar.leadingAnchor, constant: 10),
            currenciesLabel.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            imageView.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: currenciesLabel.trailingAnchor, constant: 10),
            imageView.heightAnchor.constraint(equalToConstant: 44),
            imageView.widthAnchor.constraint(equalToConstant: 44)
        ])
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
        3
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
            currencyExchangeRate: "303248201470214788723148780294920174921389",
            image: UIImage(named: "usd") ?? UIImage()
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
        //тут lazy надо?
        let baseCurrencyController = BaseCurrencyViewController()
        baseCurrencyController.delegate = self
        let model = BaseCurrencyViewController.BaseCurrencyModel(
            currencyId: "usd",
            currencyName: "united state dollar",
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
}


extension MainController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("hello")
        print(textField.text)
        return true
    }
}
