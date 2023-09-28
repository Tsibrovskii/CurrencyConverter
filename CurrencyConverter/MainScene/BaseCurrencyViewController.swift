//
//  BaseCurrencyController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 16/07/2023.
//

import UIKit

final class BaseCurrencyViewController: UIViewController {
    
    struct Model {
        let currencyId: String
        let currencyName: String
        let currencyImage: UIImage?
    }
    
    weak var delegate: MainController?

    private lazy var labelFrom: UILabel = {
        let labelFrom = UILabel()
        labelFrom.text = "From:"
        labelFrom.font = UIFont.boldSystemFont(ofSize: 16)
        labelFrom.textColor = .black
        return labelFrom
    }()
    
    private lazy var labelTo: UILabel = {
        let labelTo = UILabel()
        labelTo.text = "To:"
        labelTo.font = UIFont.boldSystemFont(ofSize: 16)
        labelTo.textColor = .black
        return labelTo
    }()

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
        amountInput.keyboardType = .decimalPad
        amountInput.autocorrectionType = .no
        return amountInput
    }()
        
    private lazy var views = [
        labelFrom,
        currencyImage,
        currencyId,
        currencyName,
        amountInput,
        labelTo
    ]

    func update(with model: Model) {
        currencyImage.image = model.currencyImage
        currencyId.text = model.currencyId.uppercased()
        currencyName.text = model.currencyName
    }

    override func viewDidLoad() {
        view.backgroundColor = .blue
        setupSubviews()
        layoutSubviews()
    }
}

private extension BaseCurrencyViewController {
    
    func setupSubviews() {
        view.backgroundColor = .brown
        
        views.forEach { view.addSubview($0) }
        
        setupToolbar()
    }
    
    func layoutSubviews() {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            labelFrom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            labelFrom.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            currencyImage.heightAnchor.constraint(equalToConstant: 44),
            currencyImage.widthAnchor.constraint(equalToConstant: 44),
            currencyImage.topAnchor.constraint(equalTo: labelFrom.bottomAnchor, constant: 10),
            currencyImage.leadingAnchor.constraint(equalTo: labelFrom.leadingAnchor),
            currencyId.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: 10),
            currencyId.topAnchor.constraint(equalTo: currencyImage.topAnchor),
            currencyName.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: 10),
            currencyName.bottomAnchor.constraint(equalTo: currencyImage.bottomAnchor),
            amountInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            amountInput.centerYAnchor.constraint(equalTo: currencyImage.centerYAnchor),
            amountInput.widthAnchor.constraint(equalToConstant: 100),
            labelTo.topAnchor.constraint(equalTo: currencyImage.bottomAnchor, constant: 10),
            labelTo.leadingAnchor.constraint(equalTo: labelFrom.leadingAnchor),
            labelTo.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func setupToolbar() {
        let bar = UIToolbar()
        let doneBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        bar.items = [flexSpace, flexSpace, doneBtn]
        bar.sizeToFit()
        amountInput.inputAccessoryView = bar
    }

    @objc
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension BaseCurrencyViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.recalculateTotalAmount(amount: Double(textField.text ?? "1") ?? 1.0)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
        let updatedText = text.replacingCharacters(in: textRange, with: string)
            // updatedText - тут текст
            // TODO: поиграться с текстом который приходит сюда
            // text и updatedText
        }
        return true
    }
}
