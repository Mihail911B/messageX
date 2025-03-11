//
//  ChatViewController.swift
//  messageX
//
//  Created by М Й on 03.03.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

struct Message {
    let senderId: String
    let recipientId: String
    let text: String
    let timestamp: Date
}

// MARK: - ChatViewController
class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let otherUser: AppUser
    private let conversationId: String
    private var messages: [Message] = []

    private let topBarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemGray6
        return view
    }()

    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Назад", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let userImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 20
        iv.image = UIImage(systemName: "person.circle")
        return iv
    }()

    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        return tv
    }()
    
    // Контейнер для ввода сообщения – теперь привязан к нижней части безопасной зоны (safeArea)
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Текстовое поле для ввода сообщения
    private let messageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Введите сообщение..."
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    // Кнопка отправки сообщения
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.tintColor = .purple
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Инициализация
    init(with user: AppUser) {
        self.otherUser = user
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            fatalError("Пользователь не авторизован")
        }
        let ids = [currentUserId, user.uid].sorted()
        self.conversationId = ids.joined(separator: "_")
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
    
    // MARK: - Жизненный цикл
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // Устанавливаем имя собеседника в центральной части верхней панели
        userNameLabel.text = otherUser.username
        
        setupViews()
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageCell")
        
        fetchMessages()
    }
    
    // MARK: - Setup UI
    private func setupViews() {
        // Добавляем верхнюю панель и её субвью
        view.addSubview(topBarView)
        topBarView.addSubview(backButton)
        topBarView.addSubview(userNameLabel)
        topBarView.addSubview(userImageView)
        
        // Добавляем таблицу сообщений и контейнер ввода
        view.addSubview(tableView)
        view.addSubview(inputContainerView)
        inputContainerView.addSubview(messageTextField)
        inputContainerView.addSubview(sendButton)
        
        // Ограничения для верхней панели
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarView.heightAnchor.constraint(equalToConstant: 60)
        ])

        NSLayoutConstraint.activate([
            backButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            userNameLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),
            userNameLabel.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            userImageView.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -8),
            userImageView.centerYAnchor.constraint(equalTo: topBarView.centerYAnchor),
            userImageView.widthAnchor.constraint(equalToConstant: 40),
            userImageView.heightAnchor.constraint(equalToConstant: 40)
        ])

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: topBarView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainerView.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            messageTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 8),
            messageTextField.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            messageTextField.heightAnchor.constraint(equalToConstant: 35)
        ])
        
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -8),
            sendButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @objc private func handleBack() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as? MessageTableViewCell else {
             return UITableViewCell()
         }
         let message = messages[indexPath.row]
         cell.messageLabel.text = message.text
         
         let isCurrentUser = message.senderId == Auth.auth().currentUser?.uid
         cell.bubbleView.backgroundColor = isCurrentUser ? UIColor.systemBlue : UIColor.systemGray4
         cell.messageLabel.textColor = isCurrentUser ? .white : .black
         
         if isCurrentUser {
             cell.leadingConstraint.isActive = false
             cell.trailingConstraint.isActive = true
         } else {
             cell.trailingConstraint.isActive = false
             cell.leadingConstraint.isActive = true
         }
         
         return cell
    }
    
    // MARK: - Отправка сообщения
    @objc private func handleSend() {
         guard let text = messageTextField.text, !text.isEmpty,
               let currentUserId = Auth.auth().currentUser?.uid else { return }
         
         let db = Firestore.firestore()
         let conversationRef = db.collection("conversations").document(conversationId)
         
         conversationRef.getDocument { documentSnapshot, error in
              if let error = error {
                   print("Ошибка проверки беседы: \(error.localizedDescription)")
                   return
              }
              
              if let document = documentSnapshot, !document.exists {
                   conversationRef.setData([
                        "participants": [currentUserId, self.otherUser.uid],
                        "lastMessage": text,
                        "timestamp": FieldValue.serverTimestamp()
                   ])
              } else {
                   conversationRef.updateData([
                        "lastMessage": text,
                        "timestamp": FieldValue.serverTimestamp()
                   ])
              }
              
              let messageData: [String: Any] = [
                   "senderId": currentUserId,
                   "recipientId": self.otherUser.uid,
                   "text": text,
                   "timestamp": FieldValue.serverTimestamp()
              ]
              
              conversationRef.collection("messages").addDocument(data: messageData) { error in
                   if let error = error {
                        print("Ошибка отправки сообщения: \(error.localizedDescription)")
                        return
                   }
                   DispatchQueue.main.async {
                        self.messageTextField.text = ""
                   }
              }
         }
    }
    
    // MARK: - Получение сообщений
    private func fetchMessages() {
         let db = Firestore.firestore()
         db.collection("conversations").document(conversationId)
              .collection("messages")
              .order(by: "timestamp", descending: false)
              .addSnapshotListener { snapshot, error in
                   if let error = error {
                        print("Ошибка получения сообщений: \(error.localizedDescription)")
                        return
                   }
                   guard let documents = snapshot?.documents else { return }
                   self.messages.removeAll()
                   for document in documents {
                        let data = document.data()
                        let senderId = data["senderId"] as? String ?? ""
                        let recipientId = data["recipientId"] as? String ?? ""
                        let text = data["text"] as? String ?? ""
                        var timestamp = Date()
                        if let ts = data["timestamp"] as? Timestamp {
                             timestamp = ts.dateValue()
                        }
                        let message = Message(senderId: senderId,
                                              recipientId: recipientId,
                                              text: text,
                                              timestamp: timestamp)
                        self.messages.append(message)
                   }
                   DispatchQueue.main.async {
                        self.tableView.reloadData()
                        if self.messages.count > 0 {
                             let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                             self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                   }
              }
    }
}
