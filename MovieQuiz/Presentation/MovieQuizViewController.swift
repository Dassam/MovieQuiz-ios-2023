import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenterProtocol?
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        let transfrom = CGAffineTransform.init(scaleX: 2.5, y: 2.5)
        activityIndicator.transform = transfrom
        
        alertPresenter = AlertPresenter(delegate: self)
        activityIndicator.startAnimating()
    }
    
    // MARK: - ButtonsActionHandler
    
    @IBAction private func yesButtonClicked() {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked() {
        presenter.yesButtonClicked()
    }
    
    func switchButtonsState() {
        yesButton.isEnabled.toggle()
        noButton.isEnabled.toggle()
    }
    
    // MARK: - LoadingIndicatorHandler
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - FillingTheDataModels
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image // выгружаем картинку
        textLabel.text = step.question // выгружаем вопрос
        counterLabel.text = step.questionNumber // выгружаем текст вопроса
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 15
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func extinguishImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let networkError = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] _ in
                guard let self = self else { return }
                self.presenter.reloadGame()
                self.showLoadingIndicator()
            }
        alertPresenter?.showAlert(quiz: networkError)
    }
    
    func showResult(message: String) {
        let alertModel = AlertModel(
            title: "Этот раунд окончен",
            message: message,
            buttonText: "OK") { [weak self] _ in
                guard let self = self else { return }
                self.presenter.restartGame() }
        alertPresenter?.showAlert(quiz: alertModel)
    }
    
}
