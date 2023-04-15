import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private var currentQuestionIndex : Int = 0 // счетчика индекса вопроса
    private var correctAnswers : Int  = 0 // счетчика правильных ответов
    
    private let questionsAmount: Int = 10
    private let questionFactory: QuestionFactory = QuestionFactory()
    private var currentQuestion: QuizQuestion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstQuestion = questionFactory.requestNextQuestion() {
            currentQuestion = firstQuestion
            let viewModel = convert(model: firstQuestion)
            show(quiz: viewModel)
        }
    } // запуск экрана
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) { // нажиматие на кнопку "Да"
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = true
        showAnswerResult( isCorrect: givenAnswer == currentQuestion.correctAnswer, sender: sender )
        
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {  //нажиматие на кнопку "Нет"
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = false
        showAnswerResult( isCorrect: givenAnswer == currentQuestion.correctAnswer, sender: sender )
        
    }
    
    private func convert( model: QuizQuestion ) -> QuizStepViewModel { // метод конвертации, возвращает вью модель для экрана вопроса
        let questionStep = QuizStepViewModel (
            image : UIImage(named: model.image) ?? UIImage(), // загружаем картинку или показываем пустую UIImage
            question : model.text, // текст вопроса
            questionNumber :  "\(currentQuestionIndex + 1)/\(questionsAmount)" ) // номер вопроса из заданного количества
        return questionStep
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
            let text = correctAnswers == questionsAmount ?
                       "Поздравляем, Вы ответили на 10 из 10!" :
                       "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let resultModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                   text: text,
                                                   buttonText: "Начать заново") // заполняем модель для алерта о конце игры
            showResult(quiz: resultModel) // вызывает алерт
        } else { // если еще не конец игры
            currentQuestionIndex += 1 // увеличиваем индекс вопроса
            
            if let nextQuestion = questionFactory.requestNextQuestion() {
                currentQuestion = nextQuestion
                let viewModel = convert(model: nextQuestion)
                
                show(quiz: viewModel)
            }
        }
    }
    
    private func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0 // сбрасываем переменную с количеством правильных ответов
            self.correctAnswers = 0 // заново показываем первый вопрос
            
            if let firstQuestion = self.questionFactory.requestNextQuestion() {
                self.currentQuestion = firstQuestion
                let viewModel = self.convert(model: firstQuestion)
                
                self.show(quiz: viewModel)
            }
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func buttonIsEnabledToogle() {
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
    
}

