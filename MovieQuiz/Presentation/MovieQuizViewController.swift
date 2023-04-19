import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private var correctAnswers : Int = 0 // счетчика правильных ответов
    private let questionsAmount: Int = 10 // количество вопросов
    private var currentQuestionIndex : Int = 0 // счетчика индекса вопроса
    
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(delegate: self)
        statisticService = StatisticServiceImplementation()
        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
           
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) { // нажиматие на кнопку "Да"
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer, sender: sender)
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {  //нажиматие на кнопку "Нет"
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer, sender: sender)
    }
    
    private func convert( model: QuizQuestion ) -> QuizStepViewModel { // метод конвертации, возвращает вью модель для экрана вопроса
        return QuizStepViewModel (
            image : UIImage(named: model.image) ?? UIImage(), // загружаем картинку или показываем пустую UIImage
            question : model.text, // текст вопроса
            questionNumber :  "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    private func show( quiz step: QuizStepViewModel ) { // вывода на экран данных каждого вопроса
        imageView.image = step.image // выгружаем картинку
        textLabel.text = step.question // выгружаем вопрос
        counterLabel.text = step.questionNumber // выгружаем текст вопроса
    }
    
    private func showAnswerResult(isCorrect: Bool, sender: UIButton) { // метод красит рамку
        imageView.layer.masksToBounds = true // даём разрешение на рисование рамки
        imageView.layer.borderWidth = 8 // толщина рамки
        imageView.layer.cornerRadius = 15 // радиус скругления углов рамки
        
        if isCorrect { // проверка правильного вопроса
            correctAnswers += 1 // увеличиваем индекс вопроса
            imageView.layer.borderColor = UIColor.green.cgColor // делаем рамку зеленой
        } else {
            imageView.layer.borderColor = UIColor.red.cgColor // делаем рамку красной
        }
        
        buttonIsEnabledToogle()
        
        // асинхронно на мейн потоке даем задержку в 1 секунду
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults() // загружаем следующий вопрос
            sender.isUserInteractionEnabled = true
            self.imageView.layer.borderWidth = 0 // убираем рамку
            self.buttonIsEnabledToogle()
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            let alertModel = AlertModel(
                title: "Этот раунд окончен",
                message: makeResultMessage(),
                buttonText: "OK") { [weak self] _ in
                    guard let self = self else { return }
                    self.correctAnswers = 0
                    self.currentQuestionIndex = 0
                    self.questionFactory?.requestNextQuestion() }
            alertPresenter?.showAlert(quiz: alertModel)
            
        } else { // если еще не конец игры
            currentQuestionIndex += 1 // увеличиваем индекс вопроса
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

    func buttonIsEnabledToogle() {
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
    
}
