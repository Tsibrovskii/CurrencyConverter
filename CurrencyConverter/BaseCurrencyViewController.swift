//
//  BaseCurrencyController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 16/07/2023.
//

import UIKit

final class BaseCurrencyViewController: UIViewController {
    
    struct BaseCurrencyModel {
        let currencyId: String
        let currencyName: String
        let image: UIImage
    }
    
    weak var delegate: MainController?

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
    
    private lazy var currencyName: UILabel = {
        let currencyName = UILabel()
        currencyName.numberOfLines = 1
        currencyName.font = currencyName.font.withSize(12)
        return currencyName
    }()
    
    private lazy var amountInput: UITextField = {
        let amountInput = UITextField()
        amountInput.backgroundColor = .green
        amountInput.delegate = self
        return amountInput
    }()
    
    func update(with model: BaseCurrencyModel) {
        currencyImage.image = model.image
        currencyId.text = String.uppercased(model.currencyId)()
        currencyName.text = model.currencyName
    }

    override func viewDidLoad() {
        view.backgroundColor = .blue
        setupSubviews()
    }
}

private extension BaseCurrencyViewController {
    
    func setupSubviews() {
        view.backgroundColor = .brown
        view.addSubview(currencyImage)
        view.addSubview(currencyId)
        view.addSubview(currencyName)
        view.addSubview(amountInput)
        setupBaseCurrencyView()
    }
    
    func setupBaseCurrencyView() {
        currencyImage.translatesAutoresizingMaskIntoConstraints = false
        currencyId.translatesAutoresizingMaskIntoConstraints = false
        currencyName.translatesAutoresizingMaskIntoConstraints = false
        amountInput.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currencyImage.heightAnchor.constraint(equalToConstant: 44),
            currencyImage.widthAnchor.constraint(equalToConstant: 44),
            currencyImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            currencyImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            currencyImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            currencyImage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            currencyImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            currencyId.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: 10),
            currencyId.topAnchor.constraint(equalTo: currencyImage.topAnchor),
            currencyName.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: 10),
            currencyName.bottomAnchor.constraint(equalTo: currencyImage.bottomAnchor),
            amountInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            amountInput.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            amountInput.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
}

extension BaseCurrencyViewController: UITextFieldDelegate {
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if let x = string.rangeOfCharacter(from: NSCharacterSet.decimalDigits) {
//            return true
//        } else {
//            return false
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delegate?.recalculateTotalAmount(amount: textField.text ?? "")
        return true
    }
}
