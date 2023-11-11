//
//  BaseCurrencyController.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 16/07/2023.
//

import UIKit

final class BaseCurrencyViewController: UIViewController {
    
    private let userSettings: UserSettingsProtocol
    private let currenciesStorage: CurrenciesStorageProtocol
    
    init(
        userSettings: UserSettingsProtocol,
        currenciesStorage: CurrenciesStorageProtocol
    ) {
        self.userSettings = userSettings
        self.currenciesStorage = currenciesStorage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Model {
        let currencyId: String
        let currencyName: String
        let currencyImage: UIImage?
    }
    
    var delegate: MainControllerProtocol?

    private lazy var labelFrom: UILabel = {
        let labelFrom = UILabel()
        labelFrom.text = "From:"
        labelFrom.font = UIFont.boldSystemFont(ofSize: 16)
        labelFrom.textColor = .white
        return labelFrom
    }()
    
    private lazy var labelTo: UILabel = {
        let labelTo = UILabel()
        labelTo.text = "To:"
        labelTo.font = UIFont.boldSystemFont(ofSize: 16)
        labelTo.textColor = .white
        return labelTo
    }()

    private lazy var currencyImage: UIImageView = {
        let currencyImage = UIImageView()
        currencyImage.layer.cornerRadius = 8
        currencyImage.clipsToBounds = true
        currencyImage.contentMode = .scaleAspectFit
        return currencyImage
    }()
    
    private lazy var currencyId: UILabel = {
        let currencyId = UILabel()
        currencyId.numberOfLines = 1
        currencyId.font = UIFont.boldSystemFont(ofSize: 16)
        currencyId.textColor = .white
        return currencyId
    }()
    
    private lazy var currencyName: UILabel = {
        let currencyName = UILabel()
        currencyName.numberOfLines = 1
        currencyName.font = currencyName.font.withSize(12)
        currencyName.textColor = .white
        return currencyName
    }()
    
    private lazy var amountInput: UITextField = {
        let amountInput = UITextField()
        amountInput.backgroundColor = .white
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
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(updateBaseCurrency))
        view.addGestureRecognizer(tapGR)
        view.isUserInteractionEnabled = true
        view.backgroundColor = .blue
        setupSubviews()
        layoutSubviews()
    }
}

private extension BaseCurrencyViewController {
    
    @objc func updateBaseCurrency() {
        let vc = CurrencyListViewFactory().create(
            data: currenciesStorage.items,
            selectedIds: [userSettings.currentCurrency],
            isMultipleMode: false
        )
        vc.currencyDelegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func setupSubviews() {
        view.backgroundColor = .blue
        
        views.forEach { view.addSubview($0) }
        
        setupToolbar()
    }
    
    func layoutSubviews() {
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            labelFrom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            labelFrom.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: UIGrid.padding),
            currencyImage.heightAnchor.constraint(equalToConstant: 36),
            currencyImage.widthAnchor.constraint(equalToConstant: 44),
            currencyImage.topAnchor.constraint(equalTo: labelFrom.bottomAnchor, constant: UIGrid.padding),
            currencyImage.leadingAnchor.constraint(equalTo: labelFrom.leadingAnchor),
            currencyId.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: UIGrid.padding),
            currencyId.topAnchor.constraint(equalTo: currencyImage.topAnchor),
            currencyName.leadingAnchor.constraint(equalTo: currencyImage.trailingAnchor, constant: UIGrid.padding),
            currencyName.bottomAnchor.constraint(equalTo: currencyImage.bottomAnchor),
            amountInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -UIGrid.padding),
            amountInput.centerYAnchor.constraint(equalTo: currencyImage.centerYAnchor),
            amountInput.widthAnchor.constraint(equalToConstant: 100),
            labelTo.topAnchor.constraint(equalTo: currencyImage.bottomAnchor, constant: UIGrid.padding),
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

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            var resultToReturn = true
            var updatedValue: Double  = 1
            
            if let value = Double(updatedText) {
                if (value >= 0) {
                    updatedValue = value
                } else {
                    resultToReturn = false
                }
            } else {
                updatedValue = updatedText.isEmpty ? 1 : Double(text) ?? 1
                resultToReturn = updatedText.isEmpty
            }

            delegate?.recalculateTotalAmount(amount: updatedValue)
           
            return resultToReturn
        }
        return true
    }
}

extension BaseCurrencyViewController: CurrencyListViewDelegateProtocol {
        
    func selectionChanged(currencyId: String, isSelected: Bool) {
        userSettings.currentCurrency = currencyId
    }
}
