//
//  CurrencyInfoCell.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 09/07/2023.
//

import UIKit

final class CurrencyInfoCell: UITableViewCell {
    
    struct Model {
        let currencyId: String
        let currencyName: String
        let totalAmount: String
        let currencyExchangeRate: String
        let image: UIImage
    }
    
    private lazy var currencyImage: UIImageView = {
        let currencyImage = UIImageView()
        currencyImage.layer.cornerRadius = 16
        currencyImage.clipsToBounds = true
        currencyImage.contentMode = .scaleAspectFit
        return currencyImage
    }()
    
    private lazy var currencyId: UILabel = {
        let currencyId = UILabel()
        currencyId.numberOfLines = 1
        currencyId.font = UIFont.boldSystemFont(ofSize: 16)
        return currencyId
    }()
    
    private var totalAmount: UILabel = {
        let totalAmount = UILabel()
        totalAmount.numberOfLines = 1
        return totalAmount
    }()
    
    private var currencyName: UILabel = {
       let currencyName = UILabel()
        currencyName.numberOfLines = 1
        currencyName.font = currencyName.font.withSize(12)
        currencyName.textColor = .gray
        return currencyName
    }()
    
    private var currencyExchangeRate: UILabel = {
       let currencyExchangeRate = UILabel()
        currencyExchangeRate.numberOfLines = 1
        currencyExchangeRate.textColor = .gray
        return currencyExchangeRate
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .green
        setupSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func update(with model: Model) {
        currencyImage.image = model.image
        currencyId.text = String.uppercased(model.currencyId)()
        totalAmount.text = model.totalAmount
        currencyName.text = model.currencyName
        currencyExchangeRate.text = model.currencyExchangeRate
    }
}

private extension CurrencyInfoCell {
    
    func setupSubviews() {
        contentView.addSubview(currencyImage)
        contentView.addSubview(currencyId)
        contentView.addSubview(totalAmount)
        contentView.addSubview(currencyName)
        contentView.addSubview(currencyExchangeRate)
        setupCurrencyInfoCell()
    }
    
    func setupCurrencyInfoCell() {
        currencyImage.translatesAutoresizingMaskIntoConstraints = false
        currencyId.translatesAutoresizingMaskIntoConstraints = false
        totalAmount.translatesAutoresizingMaskIntoConstraints = false
        currencyName.translatesAutoresizingMaskIntoConstraints = false
        currencyExchangeRate.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyImage.heightAnchor.constraint(equalToConstant: 44),
            currencyImage.widthAnchor.constraint(equalToConstant: 44),
            currencyImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            currencyImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            currencyImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            currencyId.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: 10),
            currencyId.topAnchor.constraint(equalTo: currencyImage.topAnchor),
            totalAmount.topAnchor.constraint(equalTo: currencyImage.topAnchor),
            totalAmount.leadingAnchor.constraint(equalTo: currencyId.trailingAnchor, constant: 20),
            totalAmount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            totalAmount.widthAnchor.constraint(equalToConstant: 80),
            currencyName.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: 10),
            currencyName.bottomAnchor.constraint(equalTo: currencyImage.bottomAnchor),
            currencyExchangeRate.leadingAnchor.constraint(equalTo: totalAmount.leadingAnchor),
            currencyExchangeRate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            currencyExchangeRate.bottomAnchor.constraint(equalTo: currencyImage.bottomAnchor)
        ])
        currencyId.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        totalAmount.setContentCompressionResistancePriority(UILayoutPriority(750), for: .horizontal)
        currencyName.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        currencyExchangeRate.setContentCompressionResistancePriority(UILayoutPriority(750), for: .horizontal)
    }
}
