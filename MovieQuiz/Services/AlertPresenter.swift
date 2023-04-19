//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Dassam on 16.04.2023.
//

import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    private weak var delegate: UIViewController?
    
    init(delegate: UIViewController) {
        self.delegate = delegate 
    }
    
    func showAlert(quiz alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )

        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: alertModel.completion
        )
        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
}
