//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Dassam on 14.05.2023.
//

import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    // MARK: - Variables
    
    private var correctAnswers: Int = 0 // счетчика правильных ответов
    private var currentQuestionIndex: Int = 0
    private let questionsAmount: Int = 10
    
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        self.viewController?.showLoadingIndicator()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
        statisticService = StatisticServiceImplementation()
    }
    
    func isLastQuestion() -> Bool { currentQuestionIndex == questionsAmount - 1 }
    
    func resetQuestionIndex() { currentQuestionIndex = 0 }
    
    func switchToNextQuestion() { currentQuestionIndex += 1 }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    // MARK: - ButtonsActionHandler
    
    func yesButtonClicked() { answerCheck(true) }
    
    func noButtonClicked() { answerCheck(false) }
    
    // MARK: -
    
    private func answerCheck(_ receivedAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        proceedWithAnswer(isCorrect: currentQuestion.correctAnswer == receivedAnswer)
    }
    
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.switchButtonsState()
        viewController?.showLoadingIndicator()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
            self.viewController?.switchButtonsState()
            self.viewController?.hideLoadingIndicator()
            self.viewController?.extinguishImageBorder()
        }
    }
    
    // MARK: -
    
    func proceedToNextQuestionOrResults() {
        if isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            let message = makeResultMessage()
            viewController?.showResult(message: message)
        } else { // если еще не конец игры
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService else { return "" }
        
        let average = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let bestGameInfoLine = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let currentGameResult = "Ваш результат: \(correctAnswers)/\(questionsAmount)"
        let totalGamesPlayed = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        
        let resultMessage = [currentGameResult,
                             totalGamesPlayed,
                             bestGameInfoLine,
                             average].joined(separator: "\n")
        return resultMessage
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func restartGame() {
        resetQuestionIndex()
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func reloadGame() {
        restartGame()
        questionFactory?.loadData()
    }
}
