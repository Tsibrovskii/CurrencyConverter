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
    }
    
    //надо в uiview обернуть для начала?
    private lazy var currencyImage: UIImageView = {
        let currencyImage = UIImageView()
        currencyImage.layer.cornerRadius = 16
        currencyImage.clipsToBounds = true
        return currencyImage
    }()
    
    private lazy var currencyId: UILabel = {
        let currencyId = UILabel()
        currencyId.numberOfLines = 1
        //тут верно шрифт задается?
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
        currencyImage.image = UIImage(named: "\(model.currencyId).pdf")
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
        setupCurrencyNameLabel()
    }
    
    func setupCurrencyNameLabel() {
        currencyImage.translatesAutoresizingMaskIntoConstraints = false
        currencyId.translatesAutoresizingMaskIntoConstraints = false
        totalAmount.translatesAutoresizingMaskIntoConstraints = false
        currencyName.translatesAutoresizingMaskIntoConstraints = false
        currencyExchangeRate.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyImage.heightAnchor.constraint(equalToConstant: 44),
            currencyImage.widthAnchor.constraint(equalToConstant: 44),
            currencyImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            currencyId.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: 10),
            totalAmount.leadingAnchor.constraint(equalTo: currencyId.trailingAnchor, constant: 20),
            totalAmount.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            currencyName.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: 10),
            currencyName.bottomAnchor.constraint(equalTo: currencyImage.bottomAnchor),
            currencyExchangeRate.leadingAnchor.constraint(equalTo: currencyName.trailingAnchor, constant: 20),
            currencyExchangeRate.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            currencyExchangeRate.bottomAnchor.constraint(equalTo: currencyImage.bottomAnchor)
        ])
        currencyId.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        totalAmount.setContentCompressionResistancePriority(UILayoutPriority(750), for: .horizontal)
        currencyName.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        currencyExchangeRate.setContentCompressionResistancePriority(UILayoutPriority(750), for: .horizontal)
    }
}
