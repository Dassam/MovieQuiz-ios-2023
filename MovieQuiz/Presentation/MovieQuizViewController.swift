import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    
    private var currentQuestionIndex : Int = 0 // счетчика индекса вопроса
    private var correctAnswers : Int  = 0 // счетчика правильных ответов
    
    private let questions: [QuizQuestion] = [ // Мокап
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма \n больше чем 6?",
            correctAnswer: false)
    ] // Мок модель вопросов
    
    struct QuizQuestion {
        let image: String // строка с названием фильма
        let text: String // строка с вопросом о рейтинге фильма
        let correctAnswer: Bool // правильный ответ на вопрос
    }// модель каждого вопрса
    struct QuizStepViewModel {
        let image: UIImage // картинка с афишей фильма с типом UIImage
        let question: String // вопрос о рейтинге квиза
        let questionNumber: String // строка с порядковым номером этого вопроса
    } // модель для отображения вопроса на экране
    struct QuizResultsViewModel {
        let title: String // строка с заголовком алерта
        let text: String // строка с текстом о количестве набранных очков
        let buttonText: String // текст для кнопки алерта
    } //модель для финального алерта
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentQuestion = questions[currentQuestionIndex]
        show (quiz : convert ( model: currentQuestion ))
    } // запуск экрана
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) { // нажиматие на кнопку "Да"
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = true
        showAnswerResult( isCorrect: givenAnswer == currentQuestion.correctAnswer, sender: sender )
        
    }
    @IBAction private func noButtonClicked(_ sender: UIButton) {  //нажиматие на кнопку "Нет"
        let currentQuestion = questions[currentQuestionIndex]
        let givenAnswer = false
        showAnswerResult( isCorrect: givenAnswer == currentQuestion.correctAnswer, sender: sender )
        
    }
    
    private func convert( model: QuizQuestion ) -> QuizStepViewModel { // метод конвертации, возвращает вью модель для экрана вопроса
        let questionStep = QuizStepViewModel (
            image : UIImage(named: model.image) ?? UIImage(), // загружаем картинку или показываем пустую UIImage
            question : model.text, // текст вопроса
            questionNumber :  "\(currentQuestionIndex + 1)/\(questions.count)" ) // номер вопроса из заданного количества
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { // асинхронно на мейн потоке даем задержку в 1 секунду
            self.showNextQuestionOrResults() // загружаем следующий вопрос
            sender.isUserInteractionEnabled = true
            self.imageView.layer.borderWidth = 0 // убираем рамку
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 { // проверка что еще не дошли до последнего вопроса
            let resultModel = QuizResultsViewModel(title: "Этот раунд окончен!",
                                                   text: "Ваш результат: \(correctAnswers)/\(questions.count)",
                                                   buttonText: "Начать заново") // заполняем модель для алерта о конце игры
            showResult(quiz: resultModel) // вызывает алерт
        } else { // если еще не конец игры
            currentQuestionIndex += 1 // увеличиваем индекс вопроса
            
            let nextQuestion = questions[currentQuestionIndex] // загружаем модель следующего вопроса
            let viewModel = convert( model: nextQuestion )
            
            show( quiz: viewModel )
        }
    }
    
    private func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0 // сбрасываем переменную с количеством правильных ответов
            self.correctAnswers = 0 // заново показываем первый вопрос
            let firstQuestion = self.questions[self.currentQuestionIndex] // загружаем данные в модель вопроса
            let viewModel = self.convert( model: firstQuestion ) // конвертируем модель вопроса в модель для показа на экран
            self.show( quiz: viewModel )
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

