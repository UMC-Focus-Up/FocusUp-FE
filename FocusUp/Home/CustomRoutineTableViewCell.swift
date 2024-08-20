//
//  RoutineTableViewCell.swift
//  FocusUp
//
//  Created by 김민지 on 8/20/24.
//

import UIKit

class CustomRoutineTableViewCell: UITableViewCell {
    var squareButton: UIButton!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSquareButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSquareButton()
    }
    

    private func setupSquareButton() {
        // squareButton을 생성하고 설정
        squareButton = UIButton(type: .custom)
        squareButton.translatesAutoresizingMaskIntoConstraints = false
         
        // 버튼 스타일 설정
        squareButton.layer.borderWidth = 1
        squareButton.layer.borderColor = UIColor(named: "BlueGray3")?.cgColor
        squareButton.layer.cornerRadius = 4
        squareButton.backgroundColor = UIColor.clear
         
        // 버튼을 셀의 내용 뷰에 추가
        contentView.addSubview(squareButton)
         
        // Auto Layout 제약 조건 설정
        NSLayoutConstraint.activate([
            squareButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            squareButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            squareButton.widthAnchor.constraint(equalToConstant: 24),
            squareButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        // 기본 셀 테두리 설정
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 4
        self.layer.borderColor = UIColor(named: "BlueGray3")?.cgColor
        self.backgroundColor = UIColor.clear

    }
    
    func configure(isSelected: Bool) {
        if isSelected {
            squareButton.setImage(UIImage(named: "check"), for: .normal)
            squareButton.layer.borderColor = UIColor(named: "Primary4")?.cgColor
            self.layer.borderColor = UIColor(named: "Primary4")?.cgColor
            self.layer.borderWidth = 2
        } else {
            squareButton.setImage(nil, for: .normal)
            squareButton.layer.borderColor = UIColor(named: "BlueGray3")?.cgColor
            self.layer.borderColor = UIColor.clear.cgColor
            self.layer.borderWidth = 0
        }
    }
}
