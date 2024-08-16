//
//  ContentViewController.swift
//  FocusUp
//
//  Created by 김서윤 on 7/24/24.
//

import UIKit
import Alamofire

class ContentViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    // 데이터 불러오기
    var myList = [MyThing]()
    let cellName = "MyThingCollectionViewCell"
    let cellReuseIdentifier = "itemCell"
    
    @IBOutlet var ThingsCollection: UICollectionView!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThingsCollection.delegate = self
        ThingsCollection.dataSource = self
        
        registerXib()
        titleLabel.font = UIFont.pretendardRegular(size: 18)
        
        // 상점 정보 불러오기
        fetchRoomItems()
    }
    
    // MARK: - 마이룸 조회 연동
    private func fetchRoomItems() {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        APIClient.getRequest(endpoint: "/api/item/myitem", token: token) { (result: Result<RoomResponse, AFError>) in
            switch result {
            case .success(let roomResponse):
                if roomResponse.isSuccess {
                    if let roomResult = roomResponse.result {
                        // 응답 데이터를 사용해 myList를 업데이트
                        self.myList = roomResult.itemList.map { item in
                            return MyThing(
                                id: item.id,
                                title: item.name,
                                category: item.type,
                                image: MyThing.getImageName(for: item.name, category: item.type)
                            )
                        }
                        
                        // 컬렉션 뷰를 리로드하여 데이터 반영
                        self.ThingsCollection.reloadData()
                    }
                } else {
                    print("Error: \(roomResponse.message)")
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func getImageName(for title: String) -> String {
        if let characterUI = CharacterUI.data.first(where: { $0.title == title }) {
            return characterUI.image
        }
        return "default_image" // 디폴트 이미지 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        myList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as?
                MyThingCollectionViewCell else {
                        return UICollectionViewCell()
                    }
            let target = myList[indexPath.row]

            let img = UIImage(named: "\(target.image).png")
            cell.itemImageView?.image = img
            cell.itemLabel?.text = target.title
            cell.categoryLabel?.text = target.category

            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 원하는 셀 크기를 반환합니다.
        return CGSize(width: 172, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24 // 행 간격
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        return numberOfItems == 1 ? 0 : 16 // 셀이 1개일 경우 간격을 0으로 설정
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let cellWidth: CGFloat = 172
        let totalWidth = collectionView.frame.width
        let numberOfItems = collectionView.numberOfItems(inSection: section)

        let leftInset: CGFloat
        if numberOfItems == 1 {
            // 셀이 1개일 경우, 셀을 왼쪽에 정렬하기 위해 오른쪽 여백을 전체 너비에서 셀 너비를 뺀 값으로 설정
            leftInset = 0
            let rightInset = totalWidth - cellWidth
            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: rightInset)
        } else {
            leftInset = max(0, (totalWidth - CGFloat(numberOfItems) * cellWidth - CGFloat(numberOfItems - 1) * 16) / 2)
            return UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: leftInset)
        }
    }
    
    // MARK: - 아이템 선택 연동
    private func selectItem(withId itemId: Int) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        let parameters = ItemRequest(itemId: itemId)
        
        APIClient.postRequest(endpoint: "/api/item/select", parameters: parameters, token: token) { (result: Result<ItemResponse, AFError>) in
            switch result {
            case .success(let itemResponse):
                if itemResponse.isSuccess {
                    NotificationCenter.default.post(name: .itemSelected, object: nil, userInfo: ["itemId": itemId])
                    self.showAlert(title: "성공", message: "아이템이 성공적으로 선택되었습니다.")
                } else {
                    self.showAlert(title: "실패", message: itemResponse.message)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self.showAlert(title: "오류", message: "네트워크 오류가 발생했습니다.")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        // "title"
        let fullText = title
        let attributedTitle = NSMutableAttributedString(string: fullText)
          
        // "title"에 Semibold 16px 적용
        let titleRange = (fullText as NSString).range(of: fullText)
        attributedTitle.addAttribute(.font, value: UIFont.pretendardSemibold(size: 16), range: titleRange)

        // UIAlertController 생성
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
          
        // NSAttributedString을 title에 설정
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        let confirm = UIAlertAction(title: "확인", style: .default) { action in
            //
        }
        confirm.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        alert.addAction(confirm)
        present(alert, animated: true, completion: nil)
    }
    
    private func registerXib() {
        let nibName = UINib(nibName: cellName, bundle: nil)
        ThingsCollection.register(nibName, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    // 셀 선택 시 호출되는 메서드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let target = myList[indexPath.row]
        didTapItem(withId: target.id)
    }
    
    func didTapItem(withId itemId: Int) {
        let target = myList.first { $0.id == itemId }
        // "title" 부분은 Semibold 16px, "을(를) 넣으시겠습니까?" 부분은 Medium 16px 폰트를 적용
        let fullText = "\(target?.title ?? "이 아이템")을(를) 넣으시겠습니까?"
        let attributedTitle = NSMutableAttributedString(string: fullText)
        
        // "title"에 Semibold 16px 적용
        let titleRange = (fullText as NSString).range(of: target?.title ?? "")
        attributedTitle.addAttribute(.font, value: UIFont.pretendardSemibold(size: 16), range: titleRange)
        
        // "을(를) 넣으시겠습니까?"에 Medium 16px 적용
        let messageRange = (fullText as NSString).range(of: "을(를) 넣으시겠습니까?")
        attributedTitle.addAttribute(.font, value: UIFont.pretendardMedium(size: 16), range: messageRange)
        
        // UIAlertController 생성
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        // NSAttributedString을 title에 설정
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        let cancel = UIAlertAction(title: "아니오", style: .default, handler: nil)
        cancel.setValue(UIColor(named: "BlueGray7"), forKey: "titleTextColor")
        
        let confirm = UIAlertAction(title: "네", style: .default) { action in
            self.selectItem(withId: itemId)
        }
        confirm.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
}

extension Notification.Name {
    static let itemSelected = Notification.Name("itemSelected")
}
