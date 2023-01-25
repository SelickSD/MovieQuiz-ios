//
//  StatisticServiceImplementation.swift
//  MovieQuiz
//
//  Created by Сергей Денисенко on 27.12.2022.
//

import Foundation

final class StatisticServiceImplementation: StatisticService {

    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }

    private let userDefaults = UserDefaults.standard

    // MARK: - результат текущей игры
    var correctAnswers: Int {
        get {
            return userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }

    // MARK: средняя точность правильных ответов за все игры в процентах
    var totalAccuracy: Double {
        get {
            userDefaults.double(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }

    // MARK:  количество завершённых игр
    var gamesCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    // MARK: информацию о лучшей попытке
    var bestGame: GameRecord {
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
                  let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }

    func store(correct count: Int, total amount: Int) {

        let newRecord = GameRecord(correct: count, total: amount, date: Date())
        newRecord > bestGame ? self.bestGame = newRecord : nil
        correctAnswers += count
        gamesCount += 1
        totalAccuracy = calculateTotalAccuracy()
    }

    private func calculateTotalAccuracy() -> Double {
        guard gamesCount != 0 else { return 0.0 }
        return Double(correctAnswers * 100) / Double(gamesCount * 10)
    }
}

