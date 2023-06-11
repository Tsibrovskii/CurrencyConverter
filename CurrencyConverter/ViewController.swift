//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

import UIKit

class ViewController: UIViewController {
    
    var currencyService = Service(currencyHelper: CurrencyHelper(), requestBuilder: RequestBuilder(), deserializeHelper: DeserializeHelper())
    
    private var data: [CurrencyList.CurrencySymbol] = []
    
    private lazy var textLabel: UILabel = {
        let view = UILabel()
        view.text = "Some Text"
        view.textColor = .green
        view.backgroundColor = .yellow
        view.textAlignment = .center
        return view
    }()
    
    let tableView = UITableView()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.data.capacity
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        UITableViewCell()
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CurrencyNameCell
//        cell.textLabel?.text = self.data[indexPath.row]
        cell.setupCell(text: self.data[indexPath.row].value)
        return cell
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.currencyService.getCurrencies(){ result in
            switch result {
            case .success(let symbols):
                self.data = symbols
                self.setupSubviews()
                print(symbols)
                print(symbols[0].key)
            case .failure(let error):
                print(error)
                print(error.localizedDescription)
            }
        }
//        self.currencyService.getExchangeRates(baseCurrency: "EUR", currencyList: ["GBP", "AUD"], completion: {
//            result in
//            switch result {
//            case .success(let rates):
//                print(rates)
//            case .failure(let error):
//                print(error)
//            }
//        })
//        createTable()
//        setupSubviews()
        
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupSubviews() {
        
//        view.addSubview(textLabel)
//
//        textLabel.translatesAutoresizingMaskIntoConstraints = false
//        textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//
//        textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
//        textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.backgroundColor = .yellow
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CurrencyNameCell.self, forCellReuseIdentifier: "cell")
    }
}

