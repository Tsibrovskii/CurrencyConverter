//
//  MainSceneFactory.swift
//  CurrencyConverter
//
//  Created by Dmitriy Mirovodin on 27.09.2023.
//

import Foundation
import UIKit

final class MainSceneFactory {
    
    func create() -> UIViewController {
        let nav = UINavigationController(rootViewController: MainControllerFactory().create())
        
        let appearance = UINavigationBarAppearance()
        appearance.shadowImage = nil
        appearance.shadowColor = nil
        appearance.backgroundColor = .white
        
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.isTranslucent = false
        
        return nav
    }
}
