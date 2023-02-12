import UIKit
final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!

    private var currentQuestionIndex: Int = 1
    private var correctAnswers: Int = 0
    private var statistic: StatisticService?
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
        view.backgroundColor = .ypBlack
        activityIndicator.hidesWhenStopped = true
        setButtonsEnabled(false)
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        showLoadingIndicator()
        questionFactory?.loadData()
        statistic = StatisticServiceImplementation()
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else { return }
        hideLoadingIndicator()
        setButtonsEnabled(true)
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
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
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") {_ in
            self.questionFactory?.loadData()
        }
        alertPresenter?.showAlert(alertModel: model)
    }

    // MARK: - AlertPresenterDelegate

    func didPrepareAlert(alert: UIAlertController?) {
        guard let alert = alert else { return }
        DispatchQueue.main.async { () -> Void in
            self.present(alert, animated: true, completion: nil)
        }
    }

    private func showNextQuestionOrResults() {
        guard let statistic = statistic else { return }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0

        if currentQuestionIndex == questionsAmount {

            statistic.store(correct: correctAnswers, total: questionsAmount)

            let model = AlertModel(
                title: "Этот раунд окончен!",
                message: """
                Ваш результат \(correctAnswers)/\(questionsAmount)
                Количество сыгранных квизов: \(statistic.gamesCount)
                Рекорд: \(statistic.bestGame.correct)/\(statistic.bestGame.total) (\(statistic.bestGame.date.dateTimeString))
                Средняя точность: \(String(format: "%.2f", arguments: [statistic.totalAccuracy]))%
                """,
                buttonText: "Сыграть еще раз?",
                completion: { [weak self] _ in
                    guard let self = self else { return }
                    self.currentQuestionIndex = 1
                    self.correctAnswers = 0
                    self.questionFactory?.requestNextQuestion()
                })
            alertPresenter?.showAlert(alertModel: model)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex)/\(questionsAmount)")
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = UIColor.ypGreen.cgColor
            imageView.layer.cornerRadius = 20

            correctAnswers += 1
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
        guard let currentQuestion = currentQuestion else { return }
        showLoadingIndicator()
        setButtonsEnabled(false)
        showAnswerResult(isCorrect: !currentQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {}
    }

    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else { return }
        showLoadingIndicator()
        setButtonsEnabled(false)
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {}
    }

    private func setButtonsEnabled(_ isEnabled: Bool) {
        if isEnabled {
            yesButton.isEnabled = true
            noButton.isEnabled = true
        } else {
            yesButton.isEnabled = false
            noButton.isEnabled = false
        }
    }

    //MARK: - activityIndicator

    private func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }

    private func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }

    private func showNetworkError(message: String) {
//                hideLoadingIndicator()

        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать ещё раз",
            completion: { [weak self] _ in
                guard let self = self else { return }
                self.currentQuestionIndex = 1
                self.correctAnswers = 0
                self.questionFactory?.loadData()
            })
        alertPresenter?.showAlert(alertModel: model)
    }
}
