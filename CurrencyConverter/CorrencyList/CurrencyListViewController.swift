//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//


import UIKit

protocol CurrencyListViewDelegateProtocol: AnyObject {
    func selectionChanged(currencyId: String, isSelected: Bool)
}

final class CurrencyListViewController: UIViewController {
    
    weak var currencyDelegate: CurrencyListViewDelegateProtocol?
    
    private let data: [CurrencyList.CurrencySymbol]
    private var selectedIds = Set<String>()
    private var isMultipleMode: Bool
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.backgroundColor = .blue
        view.delegate = self
        view.dataSource = self
        view.register(CurrencyNameCell.self, forCellReuseIdentifier: Constants.currencyCellId)
        return view
    }()
    
    init(
        data: [CurrencyList.CurrencySymbol],
        selectedIds: [String],
        isMultipleMode: Bool
    ) {
        self.data = data
        self.selectedIds = Set(selectedIds)
        self.isMultipleMode = isMultipleMode
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
        tableView.reloadData()
    }
}

extension CurrencyListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currencyId = data[indexPath.row].key
        
        var isSelected = selectedIds.contains(currencyId)
        
        if (isMultipleMode) {
            isSelected = !isSelected

            if isSelected {
                selectedIds.insert(currencyId)
            } else {
                selectedIds.remove(currencyId)
            }
        } else {
            if (!isSelected) {
                selectedIds = [currencyId]
            }
        }
        tableView.reloadData()
        currencyDelegate?.selectionChanged(currencyId: currencyId, isSelected: isSelected)
    }
}
    
extension CurrencyListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.currencyCellId,
            for: indexPath
        ) as? CurrencyNameCell
        
        let key = data[indexPath.row].key
        
        let isChecked = selectedIds.contains(key)
        
        let model = CurrencyNameCell.Model(
            currencyId: data[indexPath.row].key,
            currencyName: data[indexPath.row].value,
            isChecked: isChecked
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
        title = isMultipleMode ? "Add Currency" : "Select default currency"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
    }
}
