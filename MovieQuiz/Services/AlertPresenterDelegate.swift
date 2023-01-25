//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Сергей Денисенко on 23.12.2022.
//

import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func didPrepareAlert(alert: UIAlertController?)
}
