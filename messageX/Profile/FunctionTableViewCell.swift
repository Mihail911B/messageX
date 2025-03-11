////
////  FunctionTableViewCell.swift
////  messageX
////
////  Created by М Й on 05.03.2025.
////
//
import UIKit

class FunctionTableViewCell: UITableViewCell {

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

             functionLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 10),
             functionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
             functionLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
         ])
    }
    
    required init?(coder: NSCoder) {
         fatalError("init(coder:) has not been implemented")
    }
}
