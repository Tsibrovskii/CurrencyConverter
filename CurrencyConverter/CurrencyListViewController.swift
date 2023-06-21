//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//


import UIKit

protocol CurrencyListViewDelegateProtocol: AnyObject {
    func selectionChanged(currencyId: String, isSelected: Bool)
}

final class CurrencyListViewController: UIViewController {
    
    weak var delegate: CurrencyListViewDelegateProtocol?
    
    private let currencyService: ServiceProtocol
    private var data: [CurrencyList.CurrencySymbol] = []
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .blue
        view.delegate = self
        view.dataSource = self
        view.register(CurrencyNameCell.self, forCellReuseIdentifier: Constants.currencyCellId)
        return view
    }()
    
    init(currencyService: ServiceProtocol, select: Set<String>) {
        self.currencyService = currencyService
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
                
        setupNavigationBar()
        setupSubviews()
        
        currencyService.getCurrencies() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let symbols):
                self.data = symbols
                self.tableView.reloadData()
            case .failure(let error):
                print(error)
                print(error.localizedDescription)
            }
        }
    }
}

extension CurrencyListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as? CurrencyNameCell
        let model = CurrencyNameCell.Model(
            currencyCode: "",
            currencyName: data[indexPath.row].value,
            isChecked: true
        )
        selectedCell?.update(with: model)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as? CurrencyNameCell
        let model = CurrencyNameCell.Model(
            currencyCode: "",
            currencyName: data[indexPath.row].value,
            isChecked: false
        )
        selectedCell?.update(with: model)
    }
}
    
extension CurrencyListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.currencyCellId,
            for: indexPath
        ) as? CurrencyNameCell
        
        let model = CurrencyNameCell.Model(
            currencyCode: "",
            currencyName: data[indexPath.row].value,
            isChecked: false
        )
        cell?.update(with: model)
        return cell ?? UITableViewCell()
    }
}

private extension CurrencyListViewController {
    
    enum Constants {
        static let currencyCellId = "CurrencyNameCellId"
    }
    
    func setupSubviews() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func setupNavigationBar() {
        title = "Add Currency"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
