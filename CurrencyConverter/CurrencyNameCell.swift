//
//  CurrencyNameCell.swift
//  CurrencyConverter
//
//  Created by Aleksei Tsibrovskii on 08/06/2023.
//

import Foundation
import UIKit

class CurrencyNameCell: UITableViewCell {
    lazy var currency: UILabel = {
        let label = UILabel()
//        label.backgroundColor = .yellow
//        label.text = "CellSwift"
        label.translatesAutoresizingMaskIntoConstraints = false

//        view.addSubview(label)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .yellow
        addSubview(currency)
        NSLayoutConstraint.activate([
//            currency.topAnchor.constraint(equalTo: ),
//            currency.bottomAnchor.constraint(equalTo: bottomAnchor),
            //почему тут просто анкор без вью?
            //как выровнять по вертикали текст?
            //как добавить флаги
            currency.leadingAnchor.constraint(equalTo: leadingAnchor),
            currency.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setupCell(text: String) {
        currency.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
