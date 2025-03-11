//
//  Untitled.swift
//  messageX
//
//  Created by М Й on 05.03.2025.
//
import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

// MARK: - EditProfileViewController

class EditProfileViewController: UIViewController {

    // Добавляем новый пункт «Удалить смайлик» в массив функций
    private let functionItems = ["Изменить имя", "Изменить почту", "Добавить смайлик", "Удалить смайлик", "Назад"]

    private lazy var functionsTableView: UITableView = {
         let tableView = UITableView(frame: .zero, style: .plain)
         tableView.translatesAutoresizingMaskIntoConstraints = false
         tableView.register(ProfileFunctionCell.self, forCellReuseIdentifier: "ProfileFunctionCell")
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
         tableView.rowHeight = 35
         return tableView
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

    private let nameLabel: UILabel = {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.textAlignment = .center
         label.text = "(Загрузка имени...)"
         label.textColor = .label
         return label
    }()

    private var baseName: String?

    private var currentEmoji: String = ""
    
    override func viewDidLoad() {
         super.viewDidLoad()
         view.backgroundColor = .white
         title = "Редактировать профиль"
         
         setupUI()
         loadUserData()
    }
    
    private func setupUI() {
         view.addSubview(avatarImageView)
         view.addSubview(nameLabel)
         view.addSubview(functionsTableView)
         
         NSLayoutConstraint.activate([
              avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
              avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              avatarImageView.widthAnchor.constraint(equalToConstant: 100),
              avatarImageView.heightAnchor.constraint(equalToConstant: 100),
              
              nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 10),
              nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
              nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
              
              functionsTableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 20),
              functionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
              functionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
              functionsTableView.heightAnchor.constraint(equalToConstant: 175)
         ])
         
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAvatarTapped))
         avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    private func loadUserData() {
         guard let currentUser = Auth.auth().currentUser else {
              nameLabel.text = "Профиль (неизвестный пользователь)"
              return
         }
         if let localImage = loadImageFromDocuments(fileName: "\(currentUser.uid)_avatar.jpg") {
              avatarImageView.image = localImage
         }
         
         let db = Firestore.firestore()
         let userRef = db.collection("users").document(currentUser.uid)
         userRef.getDocument { [weak self] document, error in
              guard let self = self else { return }
              if let error = error {
                   DispatchQueue.main.async { self.nameLabel.text = "Ошибка загрузки имени" }
                   print("Ошибка получения документа: \(error.localizedDescription)")
                   return
              }
              if let document = document, document.exists {
                   let data = document.data()
                   let username = data?["username"] as? String ?? "Имя не установлено"
                   // Читаем отдельно поле emoji, если оно существует
                   let emoji = data?["emoji"] as? String ?? ""
                   self.currentEmoji = emoji
                   let displayName = username + (emoji.isEmpty ? "" : " " + emoji)
                   DispatchQueue.main.async {
                        self.nameLabel.text = displayName
                   }
                   self.baseName = username
                   if let avatarURLString = data?["avatarURL"] as? String,
                      let avatarURL = URL(string: avatarURLString) {
                        self.downloadImage(from: avatarURL)
                   }
              } else {
                   DispatchQueue.main.async {
                        self.nameLabel.text = "Профиль (неизвестный пользователь)"
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
    
    // функция для удаления смайлика
    @objc private func removeEmoji() {
         guard let currentUser = Auth.auth().currentUser else {
              print("Ошибка: пользователь не авторизован")
              return
         }
         Firestore.firestore().collection("users").document(currentUser.uid).updateData(["emoji": ""]) { error in
              if let error = error {
                   print("Ошибка удаления смайлика: \(error.localizedDescription)")
              } else {
                   DispatchQueue.main.async {
                       self.nameLabel.text = self.baseName
                   }
                   self.currentEmoji = ""
                   print("Смайлик успешно удалён!")
              }
         }
    }
}

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let selectedImage = (info[.editedImage] as? UIImage) ??
                                  (info[.originalImage] as? UIImage) else {
            print("Ошибка: изображение не выбрано")
            picker.dismiss(animated: true, completion: nil)
            return
        }

        avatarImageView.image = selectedImage

        guard let currentUser = Auth.auth().currentUser else {
            print("Ошибка: пользователь не авторизован")
            picker.dismiss(animated: true, completion: nil)
            return
        }
  
        saveImageToDocuments(image: selectedImage, fileName: "\(currentUser.uid)_avatar.jpg")

        let storageRef = Storage.storage().reference().child("avatars/\(currentUser.uid).jpg")

        guard let imageData = selectedImage.jpegData(compressionQuality: 0.5) else {
            print("Ошибка: не удалось получить данные изображения")
            picker.dismiss(animated: true, completion: nil)
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        print("Начало загрузки изображения в Storage...")
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                print("Ошибка загрузки аватарки: \(error.localizedDescription)")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            
            print("Изображение загружено, получаем downloadURL...")
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Ошибка получения URL: \(error.localizedDescription)")
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
                
                guard let downloadURL = url else {
                    print("Ошибка: downloadURL не получен")
                    picker.dismiss(animated: true, completion: nil)
                    return
                }
                
                print("Получен downloadURL: \(downloadURL.absoluteString)")

                let db = Firestore.firestore()
                let updatedProfile: [String: Any] = [
                    "avatarURL": downloadURL.absoluteString,
                    "username": self.baseName ?? "Имя не задано",
                    "emoji": self.currentEmoji
                ]
                
                db.collection("users").document(currentUser.uid)
                    .setData(updatedProfile, merge: true) { error in
                        if let error = error {
                            print("Ошибка установки данных в Firestore: \(error.localizedDescription)")
                        } else {
                            print("Профиль успешно обновлён! Аватарка, никнейм и emoji сохранены.")
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


extension EditProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return functionItems.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileFunctionCell",
                                                        for: indexPath) as? ProfileFunctionCell else {
              return UITableViewCell()
         }
         
         switch indexPath.row {
         case 0:
              cell.iconImageView.image = UIImage(systemName: "pencil")
              cell.functionLabel.text = "Изменить имя"
         case 1:
              cell.iconImageView.image = UIImage(systemName: "envelope")
              cell.functionLabel.text = "Изменить почту"
         case 2:
              cell.iconImageView.image = UIImage(systemName: "face.smiling")
              cell.functionLabel.text = "Добавить смайлик"
         case 3:
              cell.iconImageView.image = UIImage(systemName: "trash")
              cell.functionLabel.text = "Удалить смайлик"
         case 4:
              cell.iconImageView.image = UIImage(systemName: "arrow.left")
              cell.functionLabel.text = "Назад"
         default:
              break
         }
         cell.selectionStyle = .none
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         switch indexPath.row {
         case 0:
              changeName()
         case 1:
              changeEmail()
         case 2:
              addEmojiToNickname()
         case 3:
              removeEmoji()
         case 4:
              if let nav = self.navigationController {
                  nav.popViewController(animated: true)
              } else {
                  self.dismiss(animated: true, completion: nil)
              }
         default:
              break
         }
         tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc private func changeName() {
         let alert = UIAlertController(title: "Изменить имя",
                                       message: "Введите новое имя", preferredStyle: .alert)
         alert.addTextField { textField in
              textField.placeholder = "Новое имя"
         }
         alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
         alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { _ in
              if let newName = alert.textFields?.first?.text, !newName.isEmpty,
                 let currentUser = Auth.auth().currentUser {
                  Firestore.firestore().collection("users")
                      .document(currentUser.uid)
                      .updateData(["username": newName]) { error in
                           if let error = error {
                                print("Ошибка обновления имени: \(error.localizedDescription)")
                           } else {
                                DispatchQueue.main.async {
                                     self.nameLabel.text = newName + (self.currentEmoji.isEmpty ? "" : " " + self.currentEmoji)
                                }
                                self.baseName = newName
                                print("Имя успешно обновлено!")
                           }
                      }
              }
         }))
         present(alert, animated: true, completion: nil)
    }
    
    @objc private func changeEmail() {
         let alert = UIAlertController(title: "Изменить почту",
                                       message: "Введите новый email", preferredStyle: .alert)
         alert.addTextField { textField in
              textField.placeholder = "Новый email"
              textField.keyboardType = .emailAddress
         }
         alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
         alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { _ in
              if let newEmail = alert.textFields?.first?.text, !newEmail.isEmpty,
                 let currentUser = Auth.auth().currentUser {
                  currentUser.updateEmail(to: newEmail) { error in
                       if let error = error {
                            print("Ошибка обновления почты: \(error.localizedDescription)")
                       } else {
                            Firestore.firestore().collection("users")
                                .document(currentUser.uid)
                                .updateData(["email": newEmail]) { error in
                                     if let error = error {
                                          print("Ошибка обновления email: \(error.localizedDescription)")
                                     } else {
                                          print("Почта успешно обновлена!")
                                     }
                                }
                       }
                  }
              }
         }))
         present(alert, animated: true, completion: nil)
    }
    
    private func addEmojiToNickname() {
         let emojiPicker = EmojiPickerViewController()
         emojiPicker.onEmojiSelected = { [weak self] selectedEmoji in
              guard let self = self, let currentUser = Auth.auth().currentUser else { return }
              if let emoji = selectedEmoji {
                  Firestore.firestore().collection("users")
                      .document(currentUser.uid)
                      .updateData(["emoji": emoji]) { error in
                          if let error = error {
                              print("Ошибка сохранения смайлика: \(error.localizedDescription)")
                          } else {
                              DispatchQueue.main.async {
                                  let displayName = (self.baseName ?? self.nameLabel.text ?? "") + " " + emoji
                                  self.nameLabel.text = displayName
                              }
                              self.currentEmoji = emoji
                              print("Смайлик успешно сохранён!")
                          }
                      }
              }
         }
         if let nav = self.navigationController {
              nav.pushViewController(emojiPicker, animated: true)
         } else {
              self.present(emojiPicker, animated: true, completion: nil)
         }
    }
}

class ProfileFunctionCell: UITableViewCell {
    let iconImageView: UIImageView = {
         let iv = UIImageView()
         iv.translatesAutoresizingMaskIntoConstraints = false
         iv.contentMode = .scaleAspectFit
         iv.tintColor = .purple
         return iv
    }()

    let functionLabel: UILabel = {
         let label = UILabel()
         label.translatesAutoresizingMaskIntoConstraints = false
         label.textColor = .black
         label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
         label.textAlignment = .left
         return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
         super.init(style: style, reuseIdentifier: reuseIdentifier)
         backgroundColor = .clear
         contentView.addSubview(iconImageView)
         contentView.addSubview(functionLabel)
         NSLayoutConstraint.activate([
             iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
             iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
             iconImageView.widthAnchor.constraint(equalToConstant: 20),
             iconImageView.heightAnchor.constraint(equalToConstant: 20),

             functionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
             functionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
             functionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
         ])
    }
    
    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
}

