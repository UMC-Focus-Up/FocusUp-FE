//
//  GoalRoutineAddTableViewCell.swift
//  FocusUp
//
//  Created by 김미주 on 07/08/2024.
//

import UIKit

class GoalRoutineAddTableViewCell: UITableViewCell {
    // MARK: - Property
    @IBOutlet weak var routineAddView: UIView!
    @IBOutlet weak var routineAddLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setAttribute()
        
    }
    
    // MARK: - Function
    func setAttribute() {
        routineAddView.layer.cornerRadius = 8
        routineAddView.layer.borderWidth = 1
        routineAddView.layer.borderColor = UIColor.blueGray3.cgColor
        
        routineAddLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
    }
}
