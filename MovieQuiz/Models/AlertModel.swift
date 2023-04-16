//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Dassam on 16.04.2023.
//

import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: ((UIAlertAction) -> Void)?
}
