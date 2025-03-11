//
//  MainMenuViewController.swift
//  messageX
//
//  Created by М Й on 03.03.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class MainMenuViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Menu"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowRadius = 4
        
        return view
    }()
    
    // Кнопка "Мессенджер" – слева
    private let messengerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Кнопка "Профиль" – справа
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Кнопка "Меню"
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        // Устанавливаем иконку и текст
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.setTitle("Menu", for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .purple
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: -5)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTitleLabel()
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupTitleLabel() {
        // Добавляем заголовок "Menu" сверху по центру
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupUI() {
        // Добавляем нижнюю панель (прямоугольник)
        view.addSubview(bottomContainerView)
        NSLayoutConstraint.activate([
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        // Добавляем кнопки в нижнюю панель
        bottomContainerView.addSubview(messengerButton)
        bottomContainerView.addSubview(menuButton)
        bottomContainerView.addSubview(profileButton)
        
        // Размещаем кнопку "Мессенджер" слева
        NSLayoutConstraint.activate([
            messengerButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 40),
            messengerButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            messengerButton.widthAnchor.constraint(equalToConstant: 40),
            messengerButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Размещаем кнопку "Меню" по центру
        NSLayoutConstraint.activate([
            menuButton.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor),
            menuButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 100),
            menuButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Размещаем кнопку "Профиль" справа
        NSLayoutConstraint.activate([
            profileButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -40),
            profileButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 40),
            profileButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        messengerButton.addTarget(self, action: #selector(messengerButtonTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
    }
    
    @objc private func messengerButtonTapped() {
        let messVC = UserSearchViewController()
        messVC.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        
        view.window?.layer.add(transition, forKey: kCATransition)
        present(messVC, animated: false, completion: nil)
    }
    
    @objc private func profileButtonTapped() {
        let profileVC = ProfileViewController()
        profileVC.modalPresentationStyle = .fullScreen
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        
        view.window?.layer.add(transition, forKey: kCATransition)
        present(profileVC, animated: false, completion: nil)
    }
}
