import UIKit
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private let presenter = MovieQuizPresenter()
    var statistic: StatisticService?
    var questionFactory: QuestionFactoryProtocol?
    var alertPresenter: AlertPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        view.backgroundColor = .ypBlack
        activityIndicator.hidesWhenStopped = true
        presenter.viewController = self
        setButtonsEnabled(false)
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        statistic = StatisticServiceImplementation()
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        presenter.didReceiveNextQuestion(question: question)
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {

        switch error {
        case NetworkError.codeError:
            showNetworkError(message: error.localizedDescription)
        case NetworkError.loadImageError:
            showImageLoaderError(message: error.localizedDescription)
        default:
            break
        }
    }

    private func showImageLoaderError(message: String) {
        presenter.showImageLoaderError(message: message)
    }

    // MARK: - AlertPresenterDelegate

    func didPrepareAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        DispatchQueue.main.async { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func showNextQuestionOrResults() {
        presenter.showNextQuestionOrResults()
    }

    func setupImage() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
    }

    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            imageView.layer.cornerRadius = 20

            presenter.increaseCorrectAnswers()
        } else {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypRed.cgColor
            imageView.layer.cornerRadius = 20
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
        }
    }

    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

    //MARK: - activityIndicator

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
        presenter.showNetworkError(message: message)
    }
}
