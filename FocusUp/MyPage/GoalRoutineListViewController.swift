import UIKit

protocol RoutineDataDelegate: AnyObject {
    func didReceiveData(_ data: (String, [Int], String, String))
}

class GoalRoutineListViewController: UIViewController {
    // MARK: - property
    @IBOutlet weak var goalRoutineLabel2: UILabel!
    @IBOutlet weak var routineTableView: UITableView!
    
    var routineData: [(String, [Int], String, String)] = []
    
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
            return 1
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
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guard let goalRoutineEditVC = self.storyboard?.instantiateViewController(identifier: "GoalRoutineEditViewController") as? GoalRoutineEditViewController else { return }
            // 선택한 셀의 데이터 가져오기
            let selectedData = routineData[indexPath.row]
            // 데이터를 뷰컨트롤러에 전달
            goalRoutineEditVC.routineData = selectedData
            // 뷰컨트롤러로 이동
            self.navigationController?.pushViewController(goalRoutineEditVC, animated: true)
        } else {
            guard let GoalRoutineSettingVC = self.storyboard?.instantiateViewController(identifier: "GoalRoutineSettingViewController") else { return }
            self.navigationController?.pushViewController(GoalRoutineSettingVC, animated: true)
        }
    }
}

extension GoalRoutineListViewController: RoutineDataDelegate {
    func didReceiveData(_ data: (String, [Int], String, String)) {
        print("Received Data: \(data.0), \(data.1), \(data.2), \(data.3)")
        routineData.append(data)  // 배열에 데이터 추가
        routineTableView.reloadData()  // 테이블 뷰 리로드
    }
}
