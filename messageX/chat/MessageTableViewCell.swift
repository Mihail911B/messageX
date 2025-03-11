//
//  MessageTableViewCell.swift
//  messageX
//
//  Created by М Й on 03.03.2025.
//
import UIKit



// MARK: - Кастомная ячейка для отображения сообщения (баббл)
class MessageTableViewCell: UITableViewCell {
    let bubbleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // Эти ограничения будут активироваться/деактивироваться для выравнивания
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        
        // Ограничения для messageLabel внутри bubbleView (отступы)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10),
            messageLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 10),
            messageLabel.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10)
        ])
        let topConstraint = bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5)
        let bottomConstraint = bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5)
        topConstraint.priority = .defaultHigh
        bottomConstraint.priority = .defaultHigh
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        
        NSLayoutConstraint.activate([
            topConstraint,
            bottomConstraint,
            leadingConstraint,  // активируется для входящих сообщений
            trailingConstraint  // активируется для исходящих сообщений
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) не реализован")
    }
}
