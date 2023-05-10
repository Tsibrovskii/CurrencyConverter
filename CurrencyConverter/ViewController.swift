//
//  Created by Dmitriy Mirovodin on 28.04.2023.
//

import UIKit

class ViewController: UIViewController {
    
    var currencyService = Service()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
//        self.currencyService.getCurrencies(){ result in
//            switch result {
//            case .success(let symbols):
//                print(symbols)
//                print(symbols[0].key)
//            case .failure(let error):
//                print(error)
//                print(error.localizedDescription)
//            }
//        }
        self.currencyService.getExchangeRates(baseCurrency: "EUR", currencyList: ["GBP", "AUD"], completion: {
            result in
            
        })
    }
}


