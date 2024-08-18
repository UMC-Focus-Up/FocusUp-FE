import UIKit
import Alamofire

class GoalRoutineListViewController: UIViewController {
    // MARK: - property
    @IBOutlet weak var goalRoutineLabel2: UILabel!
    @IBOutlet weak var routineTableView: UITableView!
    
    var routineData: [(String, [Int], String, String, Int64, String)] = [] // 타입 수정
    var isAddMode: Bool = true       // 추가 모드 여부 (HomeVC에서 추가모드는 포함 X)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableView
        routineTableView.delegate = self
        routineTableView.dataSource = self
        let listNib = UINib(nibName: "GoalRoutineTableViewCell", bundle: nil)
        routineTableView.register(listNib, forCellReuseIdentifier: "GoalRoutineTableViewCell")
        let addNib = UINib(nibName: "GoalRoutineAddTableViewCell", bundle: nil)
        routineTableView.register(addNib, forCellReuseIdentifier: "GoalRoutineAddTableViewCell")
        routineTableView.separatorStyle = .none

        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.navigationBar.topItem?.title = ""
        self.title = "목표 루틴 리스트"
        
        self.goalRoutineLabel2.font = UIFont(name: "Pretendard-Medium", size: 15)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        routineData = RoutineDataModel.shared.routineData
        routineTableView.reloadData()
        
        if let customFont = UIFont(name: "Pretendard-Regular", size: 18) {
            let textAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: customFont
            ]
            self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        } else {
            print("커스텀 폰트를 로드할 수 없습니다.")
        }
        
        let backButton = UIImage(named: "arrow_left")
        let leftBarButton: UIBarButtonItem = UIBarButtonItem(image: backButton, style: .plain, target: self, action: #selector(completeButtonDidTap))
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    // MARK: - action
    @objc func completeButtonDidTap(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showEditViewController(forRoutineAt index: Int) {
        let editVC = storyboard?.instantiateViewController(withIdentifier: "GoalRoutineEditViewController") as! GoalRoutineEditViewController
        editVC.delegate = self  // 델리게이트 설정
        editVC.routineIndex = index
        navigationController?.pushViewController(editVC, animated: true)
    }

}

// MARK: - extension
extension GoalRoutineListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return routineData.count
        } else {
            return isAddMode ? 1 : 0        // AddCell이 필요할 때만 1로 설정
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = routineTableView.dequeueReusableCell(withIdentifier: "GoalRoutineTableViewCell", for: indexPath) as? GoalRoutineTableViewCell else { return UITableViewCell() }
            let data = routineData[indexPath.row]
            cell.titleLabel.text = data.0
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = routineTableView.dequeueReusableCell(withIdentifier: "GoalRoutineAddTableViewCell", for: indexPath) as? GoalRoutineAddTableViewCell else { return UITableViewCell() }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 56
        } else {
            return isAddMode ? 50 : 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let editVC = storyboard?.instantiateViewController(withIdentifier: "GoalRoutineEditViewController") as! GoalRoutineEditViewController
            editVC.delegate = self
            editVC.routineIndex = indexPath.row
            editVC.routineData = routineData[indexPath.row] // 여기서도 수정된 타입으로 전달
            navigationController?.pushViewController(editVC, animated: true)
        } else {
            guard let GoalRoutineSettingVC = self.storyboard?.instantiateViewController(identifier: "GoalRoutineSettingViewController") else { return }
            self.navigationController?.pushViewController(GoalRoutineSettingVC, animated: true)
        }
    }
}


extension GoalRoutineListViewController: RoutineDataDelegate, RoutineDeleteDelegate {
    func didReceiveData(_ data: (String, [Int], String, String, Int64, String)) { // 타입 수정
        RoutineDataModel.shared.addRoutine(data)
        routineData = RoutineDataModel.shared.routineData
        routineTableView.reloadData()
    }
    
    func didDeleteRoutine(at index: Int) {
        RoutineDataModel.shared.deleteRoutine(at: index)
        routineData = RoutineDataModel.shared.routineData
        routineTableView.reloadData()
    }
}
