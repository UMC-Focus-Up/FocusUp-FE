import UIKit

class GoalRoutineTableViewCell: UITableViewCell {
    // MARK: - Property
    @IBOutlet weak var routineView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var routineButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setAttribute()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Function
    func setAttribute() {
        routineView.layer.cornerRadius = 8
        routineView.layer.borderWidth = 1
        routineView.layer.borderColor = UIColor.blueGray3.cgColor
        
        titleLabel.font = UIFont(name: "Pretendard-Medium", size: 15)
    }

}
