//
//  MessViewController.swift
//  messageX
//
//  Created by М Й on 03.03.2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

// Модель пользователя
struct AppUser {
    let uid: String
    let username: String
    let email: String
    let emoji: String
}


// Модель переписки (беседы)
struct Conversation {
    let id: String
    let participants: [String]
    let lastMessage: String
    let timestamp: Date

    // Метод для определения другого участника
    func otherUserId(currentUserId: String) -> String {
        return participants.first(where: { $0 != currentUserId }) ?? ""
    }
}

class UserSearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    private let topBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.white
        return view
    }()
    
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Поиск"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    // Таблица для отображения результатов поиска / переписок
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    // Нижняя панель
    private let bottomContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.3
        view.layer.shadowOffset = CGSize(width: 0, height: -3)
        view.layer.shadowRadius = 4
        return view
    }()
    
    // Кнопка "Меню" – слева
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Кнопка "Профиль" – справа
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.tintColor = .black
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // Кнопка "Мессенджер" – по центру (округлённая кнопка с иконкой и текстом "Chat")
    private let messengerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.setTitle("Chat", for: .normal)
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
    
    private var users: [AppUser] = []
    private var conversations: [Conversation] = []
    
    // Если в поисковой строке есть текст – режим поиска
    private var isSearching: Bool {
        guard let text = searchBar.text else { return false }
        return !text.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Переписки"
        setupViews()  // Добавляем верхнюю серую панель с searchBar и таблицу
        setupUI()     // Добавляем нижнюю панель с кнопками
        
        // Настраиваем кнопку "Найти" как правый аксессуар UISearchBar
        let searchButton = UIButton(type: .system)
        searchButton.setTitle("Найти", for: .normal)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        searchButton.sizeToFit()
        self.searchBar.searchTextField.rightView = searchButton
        self.searchBar.searchTextField.rightViewMode = .always

        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        tableView.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Очищаем строку поиска и загружаем переписки
        searchBar.text = ""
        loadConversations()
    }
    
    // MARK: - Setup Views
    private func setupViews() {
        // Добавляем верхнюю панель (серый контейнер) и помещаем в неё UISearchBar
        view.addSubview(topBarView)
        topBarView.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 44),

            searchBar.topAnchor.constraint(equalTo: topBarView.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -8),
            searchBar.bottomAnchor.constraint(equalTo: topBarView.bottomAnchor),
            
            tableView.topAnchor.constraint(equalTo: topBarView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    // MARK: - Setup UI (нижняя панель)
    private func setupUI() {
        // Нижняя панель
        view.addSubview(bottomContainerView)
        NSLayoutConstraint.activate([
            bottomContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 90)
        ])
        
        bottomContainerView.addSubview(messengerButton)
        bottomContainerView.addSubview(menuButton)
        bottomContainerView.addSubview(profileButton)
        
        NSLayoutConstraint.activate([
            messengerButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 40),
            messengerButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            messengerButton.widthAnchor.constraint(equalToConstant: 100),
            messengerButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            menuButton.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor),
            menuButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            menuButton.widthAnchor.constraint(equalToConstant: 40),
            menuButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        NSLayoutConstraint.activate([
            profileButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -40),
            profileButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            profileButton.widthAnchor.constraint(equalToConstant: 40),
            profileButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
    }
    
    @objc private func menuButtonTapped() {
        let messVC = MainMenuViewController()
        messVC.modalPresentationStyle = .fullScreen
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromRight
        view.window?.layer.add(transition, forKey: kCATransition)
        present(messVC, animated: false, completion: nil)
    }
    
    @objc private func profileButtonTapped() {
        let profileVC =  ProfileViewController()
        profileVC.modalPresentationStyle = .fullScreen
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = .push
        transition.subtype = .fromRight
        view.window?.layer.add(transition, forKey: kCATransition)
        present(profileVC, animated: false, completion: nil)
    }
    
    @objc private func searchButtonTapped() {
        if !isSearching {
            loadConversations()
            return
        }
        searchBar.resignFirstResponder()
        searchUser(byUsername: searchBar.text!)
    }
    
    // MARK: - Back Button Action (если используется)
    @objc private func backButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Поиск пользователя
    private func searchUser(byUsername username: String) {
        let db = Firestore.firestore()
        db.collection("users").whereField("username", isEqualTo: username)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Ошибка поиска: \(error.localizedDescription)")
                    return
                }
                self.users.removeAll()
                if let documents = snapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        if let retrievedUsername = data["username"] as? String,
                           let email = data["email"] as? String {
                            let emoji = data["emoji"] as? String ?? ""
                            let user = AppUser(uid: document.documentID, username: retrievedUsername, email: email, emoji: emoji)
                            if let currentUserId = Auth.auth().currentUser?.uid, currentUserId == user.uid {
                                continue
                            }
                            self.users.append(user)
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - Загрузка переписок
    private func loadConversations() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("conversations")
            .whereField("participants", arrayContains: currentUserId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Ошибка загрузки переписок: \(error.localizedDescription)")
                    return
                }
                self.conversations.removeAll()
                if let documents = snapshot?.documents {
                    for document in documents {
                        let data = document.data()
                        let participants = data["participants"] as? [String] ?? []
                        let lastMessage = data["lastMessage"] as? String ?? ""
                        let timestamp = (data["timestamp"] as? Timestamp)?.dateValue() ?? Date()
                        let conv = Conversation(id: document.documentID, participants: participants, lastMessage: lastMessage, timestamp: timestamp)
                        self.conversations.append(conv)
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !isSearching {
            loadConversations()
            return
        }
        searchBar.resignFirstResponder()
        searchUser(byUsername: searchBar.text!)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? users.count : conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        cell.imageView?.layer.cornerRadius = 25
        cell.imageView?.clipsToBounds = true
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.image = UIImage(systemName: "person.circle")
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        
        if isSearching {
            let user = users[indexPath.row]
            let displayName = user.username + (user.emoji.isEmpty ? "" : " " + user.emoji)
            cell.textLabel?.text = "Пользователь: \(displayName)"
        } else {
            let conv = conversations[indexPath.row]
            let currentUserId = Auth.auth().currentUser?.uid ?? ""
            let otherUid = conv.otherUserId(currentUserId: currentUserId)
            if let cachedDisplayName = self.participantUsernamesCache[otherUid] {
                cell.textLabel?.text = "\(cachedDisplayName)"
            } else {
                cell.textLabel?.text = " "
            }
            
            if let cachedAvatar = self.participantAvatarCache[otherUid] {
                cell.imageView?.image = cachedAvatar
            } else {
                let db = Firestore.firestore()
                db.collection("users").document(otherUid).getDocument { document, error in
                    if let error = error {
                        print("Ошибка получения пользователя: \(error.localizedDescription)")
                        return
                    }
                    if let document = document, document.exists,
                       let data = document.data() {
                        let username = data["username"] as? String ?? "Неизвестно"
                        let emoji = data["emoji"] as? String ?? ""
                        let displayName = username + (emoji.isEmpty ? "" : " " + emoji)
                        self.participantUsernamesCache[otherUid] = displayName
                        DispatchQueue.main.async {
                            if let updateCell = tableView.cellForRow(at: indexPath) {
                                updateCell.textLabel?.text = "\(displayName)"
                            }
                        }
                        if let avatarURLString = data["avatarURL"] as? String,
                           let avatarURL = URL(string: avatarURLString) {
                            URLSession.shared.dataTask(with: avatarURL) { data, response, error in
                                if let data = data, let image = UIImage(data: data) {
                                    self.participantAvatarCache[otherUid] = image
                                    DispatchQueue.main.async {
                                        if let updateCell = tableView.cellForRow(at: indexPath) {
                                            updateCell.imageView?.image = image
                                            updateCell.setNeedsLayout()
                                        }
                                    }
                                } else if let error = error {
                                    print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                                }
                            }.resume()
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        if isSearching {
            let selectedUser = users[indexPath.row]
            let ids = [currentUserId, selectedUser.uid].sorted()
            let conversationId = ids.joined(separator: "_")
            let db = Firestore.firestore()
            let conversationRef = db.collection("conversations").document(conversationId)
            
            conversationRef.getDocument { document, error in
                if let error = error {
                    print("Ошибка проверки беседы: \(error.localizedDescription)")
                    return
                }
                if let document = document, !document.exists {
                    conversationRef.setData([
                        "participants": [currentUserId, selectedUser.uid],
                        "lastMessage": "",
                        "timestamp": FieldValue.serverTimestamp()
                    ]) { error in
                        if let error = error {
                            print("Ошибка создания беседы: \(error.localizedDescription)")
                            return
                        }
                        DispatchQueue.main.async {
                            let chatVC = ChatViewController(with: selectedUser)
                            chatVC.modalPresentationStyle = .fullScreen
                            self.present(chatVC, animated: true, completion: nil)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        let chatVC = ChatViewController(with: selectedUser)
                        chatVC.modalPresentationStyle = .fullScreen
                        self.present(chatVC, animated: true, completion: nil)
                    }
                }
            }
        } else {
            let conv = conversations[indexPath.row]
            let otherUid = conv.otherUserId(currentUserId: currentUserId)
            let db = Firestore.firestore()
            db.collection("users").document(otherUid).getDocument { document, error in
                if let error = error {
                    print("Ошибка получения пользователя: \(error.localizedDescription)")
                    return
                }
                if let document = document, document.exists,
                   let data = document.data(),
                   let username = data["username"] as? String,
                   let email = data["email"] as? String {
                    let emoji = data["emoji"] as? String ?? ""
                    let otherUser = AppUser(uid: otherUid, username: username, email: email, emoji: emoji)
                    let chatVC = ChatViewController(with: otherUser)
                    chatVC.modalPresentationStyle = .fullScreen
                    self.present(chatVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    // Кеш для отображаемых имен и аватарок участников
    private var participantUsernamesCache: [String: String] = [:]
    private var participantAvatarCache: [String: UIImage] = [:]
}


