//
//  SupportViewController.swift
//  messageX
//
//  Created by М Й on 06.03.2025.
//

//
//  SupportViewController.swift
//  messageX
//
//  Created by М Й on 06.03.2025.
//

import UIKit

// MARK: - SupportViewController


class SupportViewController: UIViewController {
    
    // MARK: - UI Элементы
    
    /// Заголовок экрана поддержки
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Поддержка"
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textAlignment = .center
        return label
    }()
    
    /// Описание или инструкция для пользователей
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Как мы можем помочь вам сегодня?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    /// Кнопка для обращения в поддержку
    private let contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Обратиться в поддержку", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.backgroundColor = UIColor.purple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(contactButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // Кнопка для возврата на предыдущий экран
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Назад", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.backgroundColor = UIColor.systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Жизненный цикл контроллера
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    // MARK: - Setup UI
    
    // Добавление и настройка UI элементов на основном представлении
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(contactButton)
        view.addSubview(backButton)
        setupConstraints()
    }
    
    /// Настраиваем автолейаут для UI элементов
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            contactButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 40),
            contactButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contactButton.widthAnchor.constraint(equalToConstant: 250),
            contactButton.heightAnchor.constraint(equalToConstant: 50),

            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 250),
            backButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Обработчики нажатий

    @objc private func contactButtonTapped() {
        if let url = URL(string: "https://t.me/cink911") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            let alert = UIAlertController(title: "Ошибка",
                                          message: "Невозможно открыть ссылку.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }

    @objc private func backButtonTapped() {
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}
