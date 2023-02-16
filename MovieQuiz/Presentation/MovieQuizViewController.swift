import UIKit
final class MovieQuizViewController: UIViewController, AlertPresenterDelegate, MovieQuizViewControllerProtocol {

    // MARK: - IBOutlet
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    // MARK: - Private Properties
    private var presenter: MovieQuizPresenter!
    private var alertPresenter: AlertPresenterProtocol?

    // MARK: - Initializers
    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = MovieQuizPresenter(viewController: self)
        presenter.viewController = self
        alertPresenter = AlertPresenter(delegate: self)

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        view.backgroundColor = .ypBlack
        activityIndicator.hidesWhenStopped = true

        setButtonsEnabled(false)
    }

    // MARK: - Public methods
    func didPrepareAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        DispatchQueue.main.async { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showAlert(alertModel: AlertModel?) {
        alertPresenter?.showAlert(alertModel: alertModel)
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

    func setButtonsEnabled(_ isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    func showNetworkError(message: String) {
        presenter.showNetworkError(message: message)
    }

    // MARK: - IBAction
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }

    // MARK: - Private Methods
    private func showNextQuestionOrResults() {
        presenter.showNextQuestionOrResults()
    }
}
