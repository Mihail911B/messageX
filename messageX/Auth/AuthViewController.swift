//
//  AuthViewController.swift
//  messageX
//
//  Created by М Й on 03.03.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class AuthViewController: UIViewController {

    // Сегментированный контрол для выбора между входом и регистрацией
    private let segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Вход", "Регистрация"])
        control.selectedSegmentIndex = 0
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()

    // Текстовое поле для ввода email
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // Текстовое поле для ввода username
    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // Текстовое поле для ввода пароля
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Пароль"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // Кнопка для выполнения входа или регистрации
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Войти", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.shadowColor = UIColor.purple.cgColor
        button.layer.shadowOpacity = 0.5
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowRadius = 4
        return button
    }()
    
    // Кнопка для восстановления пароля
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Восстановить пароль", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Хранение высотного ограничения для forgotPasswordButton, которое обновляется в зависимости от режима
    private var forgotPasswordButtonHeightConstraint: NSLayoutConstraint?

    // Метка для отображения ошибок
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // Дополнительные нижние метки
    private let projectLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Проект сделан пользователем Mihail911B"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()
    
    private let telegramLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Телеграмм для связи: @cink911"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    // StackView для группировки текстовых полей
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 15
        stack.alignment = .fill
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Жизненный цикл VC

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupViews()
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        actionButton.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        forgotPasswordButton.addTarget(self, action: #selector(handleForgotPassword), for: .touchUpInside)
        usernameTextField.isHidden = true
    }
    
    // Если пользователь уже вошёл, пропускаем экран аутентификации
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            transitionToMainMenu()
        }
    }

    private func setupViews() {
        view.addSubview(segmentedControl)
        view.addSubview(stackView)
        view.addSubview(actionButton)
        view.addSubview(forgotPasswordButton)
        view.addSubview(errorLabel)
        view.addSubview(projectLabel)
        view.addSubview(telegramLabel)
        
        stackView.addArrangedSubview(emailTextField)
        stackView.addArrangedSubview(usernameTextField)
        stackView.addArrangedSubview(passwordTextField)
        
        NSLayoutConstraint.activate([

            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            

            stackView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            

            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            usernameTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
 
            actionButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 50),
            
            forgotPasswordButton.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 10),
            forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            errorLabel.topAnchor.constraint(equalTo: forgotPasswordButton.bottomAnchor, constant: 10),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            projectLabel.bottomAnchor.constraint(equalTo: telegramLabel.topAnchor, constant: -4),
            projectLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            projectLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            telegramLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            telegramLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            telegramLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        forgotPasswordButtonHeightConstraint = forgotPasswordButton.heightAnchor.constraint(equalToConstant: 30)
        forgotPasswordButtonHeightConstraint?.isActive = true
    }

    // Обработка изменения режима (вход/регистрация)
    @objc private func segmentedControlChanged() {
        emailTextField.text = ""
        usernameTextField.text = ""
        passwordTextField.text = ""
        errorLabel.text = ""
        errorLabel.isHidden = true
        
        if segmentedControl.selectedSegmentIndex == 0 {
            actionButton.setTitle("Войти", for: .normal)
            usernameTextField.isHidden = true
            forgotPasswordButton.isHidden = false
            forgotPasswordButtonHeightConstraint?.constant = 30
        } else {
            actionButton.setTitle("Зарегистрироваться", for: .normal)
            usernameTextField.isHidden = false
            forgotPasswordButton.isHidden = true
            forgotPasswordButtonHeightConstraint?.constant = 0
        }
    }
    
    // Обработка нажатия на кнопку Вход/Регистрация
    @objc private func handleAction() {
        if segmentedControl.selectedSegmentIndex == 0 {
            guard let email = emailTextField.text, !email.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                showError("Пожалуйста, заполните Email и пароль")
                return
            }
            errorLabel.isHidden = true
            
            // Вход через Firebase Auth
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self else { return }
                if let error = error {
                    self.showError("Ошибка входа: \(error.localizedDescription)")
                    return
                }
                print("Пользователь вошёл: \(result?.user.uid ?? "")")
                self.showAlert(title: "Успех", message: "Вы успешно вошли в систему!") {
                    self.transitionToMainMenu()
                }
            }
        } else {
            guard let email = emailTextField.text, !email.isEmpty,
                  let username = usernameTextField.text, !username.isEmpty,
                  let password = passwordTextField.text, !password.isEmpty else {
                showError("Пожалуйста, заполните Email, Username и пароль")
                return
            }
            errorLabel.isHidden = true
            
            // Регистрация через Firebase Auth
            Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
                guard let self = self else { return }
                if let error = error {
                    self.showError("Ошибка регистрации: \(error.localizedDescription)")
                    return
                }
                guard let user = result?.user else { return }
                // Сохранение дополнительных данных (username и email) в Firestore
                let db = Firestore.firestore()
                let userData: [String: Any] = [
                    "email": email,
                    "username": username,
                    "createdAt": FieldValue.serverTimestamp()
                ]
                db.collection("users").document(user.uid).setData(userData) { error in
                    if let error = error {
                        self.showError("Ошибка сохранения профиля: \(error.localizedDescription)")
                        return
                    }
                    print("Профиль успешно сохранён в Firestore")
                    self.showAlert(title: "Успех", message: "Вы успешно зарегистрировались!") {
                        self.transitionToMainMenu()
                    }
                }
            }
        }
    }
    
    // Обработка восстановления пароля
    @objc private func handleForgotPassword() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showError("Пожалуйста, введите email для восстановления пароля")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.showError("Ошибка восстановления пароля: \(error.localizedDescription)")
                return
            }
            
            // Если сессия активна, выходим из аккаунта на данном устройстве
            do {
                try Auth.auth().signOut()
            } catch {
                print("Ошибка при выходе: \(error.localizedDescription)")
            }
            
            self.showAlert(
                title: "Восстановление пароля",
                message: "Инструкция по восстановлению пароля отправлена на ваш email. Вы были разлогинены для безопасности."
            )
        }
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
    }
    

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
              completion?()
         }))
         present(alert, animated: true, completion: nil)
    }
    
    // Переход в главное меню
    private func transitionToMainMenu() {
         let mainMenuVC = MainMenuViewController()
         mainMenuVC.modalPresentationStyle = .fullScreen
         present(mainMenuVC, animated: true, completion: nil)
    }
}
