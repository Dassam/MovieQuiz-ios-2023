//
//  MovieQuizPresenterTests.swift
//  MovieQuizTests
//
//  Created by Dassam on 23.05.2023.
//

import XCTest
 @testable import MovieQuiz
 
final class MovieQuizViewControllerMock: UIViewController, MovieQuizViewControllerProtocol {
    func switchButtonsState() {
        
    }
    
    func showResult(message: String) {
      
    }
    
    func extinguishImageBorder() {
       
    }
    
    func show(quiz step: QuizStepViewModel) {
        
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        
    }
    
    func showLoadingIndicator() {
        
    }
    
    func hideLoadingIndicator() {
        
    }
    
    func showNetworkError(message: String) {
        
    }
}
 
final class MovieQuizPresenterTests: XCTestCase {
    func testPresenterConvertModel() throws {
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(image: emptyData, text: "Question Text", correctAnswer: true)
        let viewModel = presenter.convert(model: question)
        
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Question Text")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
}
 
