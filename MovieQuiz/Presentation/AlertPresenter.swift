//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Сергей Денисенко on 23.12.2022.
//

import UIKit

class AlertPresenter {

    func showAlert(model: AlertModel) {


        let alert = UIAlertController(title: model.title,
                                      message: model.message,
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: model.buttonText, style: .default, handler: { [weak self] _ in

            guard let self = self else { return }

            self.currentQuestionIndex = 1
            self.correctAnswers = 0
            self.questionFactory?.requestNextQuestion()
        })
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)

    }
}
