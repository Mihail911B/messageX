//
//  EmojiPickerViewController.swift
//  messageX
//
//  Created by М Й on 05.03.2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

import UIKit

class EmojiPickerViewController: UIViewController {

    var onEmojiSelected: ((String?) -> Void)?

    private var emojiStrings: [String] = ["😀", "😂", "🥰", "😎", "👍"]
    
    private lazy var tableView: UITableView = {
       let tv = UITableView(frame: .zero, style: .insetGrouped)
       tv.translatesAutoresizingMaskIntoConstraints = false
       tv.dataSource = self
       tv.delegate = self
       tv.register(UITableViewCell.self, forCellReuseIdentifier: "EmojiCell")
       tv.rowHeight = 60
       tv.backgroundColor = .clear
       return tv
    }()
    
    override func viewDidLoad() {
       super.viewDidLoad()
       title = "Выберите смайлик"
       view.backgroundColor = UIColor.systemGroupedBackground
       view.addSubview(tableView)
       
       NSLayoutConstraint.activate([
          tableView.topAnchor.constraint(equalTo: view.topAnchor),
          tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
          tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
       ])
    }
}

extension EmojiPickerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emojiStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmojiCell", for: indexPath)
        cell.textLabel?.text = emojiStrings[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 32)
        cell.textLabel?.textAlignment = .center
        cell.backgroundColor = .white
        cell.contentView.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.selectionStyle = .gray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedEmoji = emojiStrings[indexPath.row]
        onEmojiSelected?(selectedEmoji)
        
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            emojiStrings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}


