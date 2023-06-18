//
//  CurrencyNameCell.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 08/06/2023.
//

import UIKit

final class CurrencyNameCell: UITableViewCell {
    
    struct Model {
        let currencyCode: String
        let currencyName: String
        let isChecked: Bool
    }
    
    private lazy var currencyNameLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .green
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .yellow
        setupSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        // Поиграться с prepareForReuse
        super.prepareForReuse()
        accessoryType = .none
    }
    
    func update(with model: Model) {
        currencyNameLabel.text = model.currencyName
        // Перейти на обновление через модель
        if model.isChecked {
            accessoryType = .checkmark
        } else {
            accessoryType = .none
        }
    }
}

private extension CurrencyNameCell {
    
    func setupSubviews() {
        contentView.addSubview(currencyNameLabel)
        setupCurrencyNameLabel()
    }
    
    func setupCurrencyNameLabel() {
        currencyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.0),
            currencyNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.0),
            currencyNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
