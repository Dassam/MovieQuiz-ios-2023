import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var correctAnswers : Int = 0 // счетчика правильных ответов
    
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    
    private let presenter = MovieQuizPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.viewController = self
        
        let transfrom = CGAffineTransform.init(scaleX: 2.5, y: 2.5)
        activityIndicator.transform = transfrom
        
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(),delegate: self)
        
        activityIndicator.startAnimating()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory?.requestNextQuestion()
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
           
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - ButtonsActionHandler
    
    @IBAction private func yesButtonClicked() {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked() {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    private func switchButtonsState() {
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
    
    // MARK: - FillingTheDataModels
    
    private func show(quiz step: QuizStepViewModel) { // вывода на экран данных каждого вопроса
        imageView.image = step.image // выгружаем картинку
        textLabel.text = step.question // выгружаем вопрос
        counterLabel.text = step.questionNumber // выгружаем текст вопроса
    }
    
    func showAnswerResult(isCorrect: Bool) { // метод красит рамку
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.cornerRadius = 15 // радиус скругления углов рамки
        
        if isCorrect {
            correctAnswers += 1
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
        } else {
            imageView.layer.borderColor = UIColor.ypRed.cgColor
        }
        
        switchButtonsState()
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults() // загружаем следующий вопрос
            self.imageView.layer.borderWidth = 0 
            activityIndicator.stopAnimating()
            self.switchButtonsState()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен",
                message: makeResultMessage(),
                buttonText: "OK") { [weak self] _ in
                    guard let self = self else { return }
                    self.presenter.resetQuestionIndex()
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion() }
            alertPresenter?.showAlert(quiz: alertModel)
            
        } else { // если еще не конец игры
            presenter.switchToNextQuestion() // увеличиваем индекс вопроса
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        
        let alertModel = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] _ in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory?.loadData()
                activityIndicator.startAnimating()
            }
        alertPresenter?.showAlert(quiz: alertModel)
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService = statisticService else { return "" }
        
        let average = "Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%"
        let bestGameInfoLine = "Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))"
        let currentGameResult = "Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)"
        let totalGamesPlayed = "Количество сыгранных квизов: \(statisticService.gamesCount)"
        
        let resultMessage = [currentGameResult,
                             totalGamesPlayed,
                             bestGameInfoLine,
                             average].joined(separator: "\n")
        return resultMessage
    }
    
}
