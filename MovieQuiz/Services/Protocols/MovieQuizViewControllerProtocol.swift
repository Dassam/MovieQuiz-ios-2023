//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Dassam on 21.05.2023.
//

import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    
    func showResult(message: String)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func extinguishImageBorder()
    
    func showLoadingIndicator()
    
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
    
    func switchButtonsState()
} 
