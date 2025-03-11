import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// Основной контроллер профиля
class ProfileViewController: UIViewController {

    private let functionItems = ["Редактировать профиль", "Выйти из профиля", "Дисклеймер", "Поддержка"]
    
    // Таблица с функциями
    private lazy var functionsTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(FunctionTableViewCell.self, forCellReuseIdentifier: "FunctionCell")
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = false
        tableView.layer.shadowColor = UIColor.black.cgColor
        tableView.layer.shadowOpacity = 0.3
        tableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        tableView.layer.shadowRadius = 4
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        return tableView
    }()
    
    // Нижняя панель с кнопками навигации
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
    
    private let messengerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.tintColor = .label
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "person.circle"), for: .normal)
        button.setTitle("Profile", for: .normal)
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
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.circle")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Профиль"
        
        setupUI()
        setupProfileHeader()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupUI() {
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
            messengerButton.widthAnchor.constraint(equalToConstant: 40),
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
            profileButton.widthAnchor.constraint(equalToConstant: 100),
            profileButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        messengerButton.addTarget(self, action: #selector(messengerButtonTapped), for: .touchUpInside)
        menuButton.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
    }
    
    @objc private func menuButtonTapped() {
        let messVC = MainMenuViewController()
        messVC.modalPresentationStyle = .fullScreen
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        
        view.window?.layer.add(transition, forKey: kCATransition)
        present(messVC, animated: false, completion: nil)
    }
    
    @objc private func messengerButtonTapped() {
        let profileVC = UserSearchViewController()
        profileVC.modalPresentationStyle = .fullScreen
        
        let transition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        
        view.window?.layer.add(transition, forKey: kCATransition)
        present(profileVC, animated: false, completion: nil)
    }
    
    // Установка заголовка профиля и настройка таблицы
    private func setupProfileHeader() {
        let topContainer = UIView()
        topContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topContainer)
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topContainer.heightAnchor.constraint(equalToConstant: 360)
        ])
        
        topContainer.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            avatarImageView.topAnchor.constraint(equalTo: topContainer.topAnchor, constant: 20),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.textAlignment = .center
        nameLabel.text = "(Загрузка имени...)"
        nameLabel.textColor = .label
        topContainer.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: topContainer.centerXAnchor),
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10)
        ])
        
        topContainer.addSubview(functionsTableView)
        let cellHeight: CGFloat = 45
        NSLayoutConstraint.activate([
            functionsTableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
            functionsTableView.leadingAnchor.constraint(equalTo: topContainer.leadingAnchor, constant: 15),
            functionsTableView.trailingAnchor.constraint(equalTo: topContainer.trailingAnchor, constant: -15),
            functionsTableView.heightAnchor.constraint(equalToConstant: CGFloat(functionItems.count) * cellHeight)
        ])
        if let currentUser = Auth.auth().currentUser,
           let localImage = loadImageFromDocuments(fileName: "\(currentUser.uid)_avatar.jpg") {
            avatarImageView.image = localImage
        }
        
        guard let currentUser = Auth.auth().currentUser else {
            nameLabel.text = "Профиль (неизвестный пользователь)"
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        userRef.getDocument { document, error in
            if let error = error {
                DispatchQueue.main.async { nameLabel.text = "Ошибка загрузки имени" }
                print("Ошибка получения документа: \(error.localizedDescription)")
                return
            }
            if let document = document, document.exists {
                let data = document.data()
                let username = data?["username"] as? String ?? "Имя не установлено"
                let emoji = data?["emoji"] as? String ?? ""
                let displayName = username + (emoji.isEmpty ? "" : " " + emoji)
                DispatchQueue.main.async {
                    nameLabel.text = displayName
                }
                if let avatarURLString = data?["avatarURL"] as? String,
                   let avatarURL = URL(string: avatarURLString) {
                    self.downloadImage(from: avatarURL)
                }
            } else {
                DispatchQueue.main.async {
                    nameLabel.text = "Профиль (неизвестный пользователь)"
                }
            }
        }
    }

    
    private func downloadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image
                    if let currentUser = Auth.auth().currentUser {
                        self?.saveImageToDocuments(image: image, fileName: "\(currentUser.uid)_avatar.jpg")
                    }
                }
            }
        }.resume()
    }
    
    @objc private func handleAvatarTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func saveImageToDocuments(image: UIImage, fileName: String) {
        if let data = image.jpegData(compressionQuality: 1.0) {
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            do {
                try data.write(to: url)
                print("Изображение сохранено локально по адресу: \(url)")
            } catch {
                print("Ошибка сохранения изображения: \(error.localizedDescription)")
            }
        }
    }
    
    private func loadImageFromDocuments(fileName: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(fileName)
        if let data = try? Data(contentsOf: url) {
            return UIImage(data: data)
        }
        return nil
    }
    
    // Метод для выхода из аккаунта
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Выйти из аккаунта",
                                      message: "Вы уверены, что хотите выйти?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { _ in
            do {
                try Auth.auth().signOut()
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let delegate = windowScene.delegate as? SceneDelegate,
                   let window = delegate.window {
                    let loginVC = AuthViewController()
                    window.rootViewController = loginVC
                    window.makeKeyAndVisible()
                }
            } catch let error {
                print("Ошибка выхода: \(error.localizedDescription)")
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    // Метод для открытия экрана дисклеймера
    @objc private func disclaimerButtonTapped() {
        let disclaimerVC = DisclaimerViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(disclaimerVC, animated: true)
        } else {
            disclaimerVC.modalPresentationStyle = .fullScreen
            present(disclaimerVC, animated: true, completion: nil)
        }
    }
    
    // Метод для открытия экрана поддержки
    @objc private func supportButtonTapped() {
        let supportVC = SupportViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(supportVC, animated: true)
        } else {
            supportVC.modalPresentationStyle = .fullScreen
            present(supportVC, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate (ProfileViewController)
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        // Получаем выбранное изображение (отредактированное или оригинальное)
        guard let selectedImage = (info[.editedImage] as? UIImage) ??
                                  (info[.originalImage] as? UIImage) else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        avatarImageView.image = selectedImage
        
        guard let currentUser = Auth.auth().currentUser else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        saveImageToDocuments(image: selectedImage, fileName: "\(currentUser.uid)_avatar.jpg")
        
        let storageRef = Storage.storage().reference().child("avatars/\(currentUser.uid).jpg")
        guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Ошибка получения URL: \(error.localizedDescription)")
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
                
                guard let downloadURL = url else {
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
                
                let db = Firestore.firestore()
                db.collection("users").document(currentUser.uid)
                    .setData(["avatarURL": downloadURL.absoluteString], merge: true) { error in
                        if let error = error {
                            print("Ошибка установки данных: \(error.localizedDescription)")
                        } else {
                            print("Аватарка успешно сохранена!")
                        }
                        picker.dismiss(animated: true, completion: nil)
                    }
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UITableViewDataSource & UITableViewDelegate (ProfileViewController)
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return functionItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FunctionCell",
                                                       for: indexPath) as? FunctionTableViewCell else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            cell.iconImageView.image = UIImage(systemName: "pencil")
            cell.functionLabel.text = "Редактировать профиль"
        case 1:
            cell.iconImageView.image = UIImage(systemName: "arrow.backward.circle")
            cell.functionLabel.text = "Выйти из профиля"
        case 2:
            cell.iconImageView.image = UIImage(systemName: "doc.text")
            cell.functionLabel.text = "Дисклеймер"
        case 3:

            cell.iconImageView.image = UIImage(systemName: "headphones")
            cell.functionLabel.text = "Поддержка"
        default:
            break
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            changeNameButtonTapped()
        case 1:
            logoutButtonTapped()
        case 2:
            disclaimerButtonTapped()
        case 3:
            supportButtonTapped()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func changeNameButtonTapped() {
        let editProfileVC = EditProfileViewController()
        if let navigationController = self.navigationController {
            navigationController.pushViewController(editProfileVC, animated: true)
        } else {
            editProfileVC.modalPresentationStyle = .fullScreen
            present(editProfileVC, animated: true, completion: nil)
        }
    }
}


