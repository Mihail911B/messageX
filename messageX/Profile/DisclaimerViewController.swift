//
//  DisclaimerViewController.swift
//  messageX
//
//  Created by М Й on 06.03.2025.
//

//
//  DisclaimerViewController.swift
//  messageX
//
//  Created by М Й on 06.03.2025.
//

import UIKit

class DisclaimerViewController: UIViewController {

    private let disclaimerText: String = """
    Данный мессенджер разработан исключительно как демонстрационный проект для портфолио. Проект находится в стадии разработки, поэтому его функциональность может быть не до конца реализована, а интерфейс и работа приложения — нестабильными. Обратите внимание на следующие моменты:

    • Проект предназначен для демонстрации идей и решений, а не для полноценного коммерческого или производственного использования.
    • Возможны временные ошибки, недоработки и изменения в функционале, поскольку разработка продолжается.
    • Мы приветствуем отзывы и предложения, которые помогут улучшить продукт в будущем. Приветствуются все обращения к создателю данного проекта, связь по кнопке "Поддержка"

    Благодарим за понимание и ваше внимание к проекту!
    
    Version 1.0
    """

    // Контейнер для отображения информации с закруглёнными углами и тенью
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.purple.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()

    // Метка для текста дисклеймера
    private let textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()

    // Кнопка для возврата к предыдущему экрану
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Назад", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        button.backgroundColor = UIColor.systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Жизненный цикл

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Дисклеймер"
        textLabel.text = disclaimerText
        setupUI()
    }

    // MARK: - Настройка UI

    private func setupUI() {
        // Добавляем контейнер и кнопку на основное представление
        view.addSubview(containerView)
        view.addSubview(backButton)
        // В контейнер добавляем метку с информацией
        containerView.addSubview(textLabel)
        
        setupConstraints()
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([

            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -150),

            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            textLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),


            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 200),
            backButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Обработчики событий

    @objc private func backTapped() {
        if let navController = navigationController {
            navController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

