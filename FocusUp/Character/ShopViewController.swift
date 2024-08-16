//
//  ShopViewController.swift
//  FocusUp
//
//  Created by 김서윤 on 8/9/24.
//

import UIKit
import Alamofire

class ShopViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 데이터 불러오기
    var shopList = [ShopThing]()
    let cellName = "ShopCollectionViewCell"
    let cellReuseIdentifier = "shopCell"
    
    @IBOutlet var ShopCollection: UICollectionView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var fishNum: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ShopCollection.delegate = self
        ShopCollection.dataSource = self
        
        registerXib()
        titleLabel.font = UIFont.pretendardRegular(size: 18)
        fishNum.font = UIFont.pretendardMedium(size: 16)
        
        // 상점 정보 불러오기
        fetchShopItems()
    }
    
    // MARK: - 상점 조회 연동
    private func fetchShopItems() {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        APIClient.getRequest(endpoint: "/api/item/store", token: token) { (result: Result<ShopResponse, AFError>) in
            switch result {
            case .success(let shopResponse):
                if shopResponse.isSuccess {
                    if let shopResult = shopResponse.result {
                        self.fishNum.text = "\(shopResult.point)"
                        
                        // 응답 데이터를 사용해 shopList를 업데이트
                        self.shopList = shopResult.itemList.map { item in
                            return ShopThing(
                                id: item.id,
                                title: item.name,
                                category: item.type,
                                image: ShopThing.getImageName(for: item.name, category: item.type),
                                price: "\(item.price)"
                            )
                        }
                        
                        // 컬렉션 뷰를 리로드하여 데이터 반영
                        self.ShopCollection.reloadData()
                    }
                } else {
                    print("Error: \(shopResponse.message)")
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
        shopList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as?
                ShopCollectionViewCell else {
            return UICollectionViewCell()
        }
        let target = shopList[indexPath.row]
        
        let img = UIImage(named: "\(target.image).png")
        cell.itemImageView?.image = img
        cell.itemLabel?.text = target.title
        cell.categoryLabel?.text = target.category
        cell.priceLabel?.text = target.price
        
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
        return 16 // 셀 간의 간격
    }
    
    // MARK: - 아이템 구매 연동
    private func purchaseItem(withId itemId: Int) {
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {
            print("Error: No access token found.")
            return
        }
        
        let parameters = PurchaseRequest(itemId: itemId)
        
        APIClient.postRequest(endpoint: "/api/item/purchase", parameters: parameters, token: token) { (result: Result<PurchaseResponse, AFError>) in
            switch result {
            case .success(let purchaseResponse):
                if purchaseResponse.isSuccess {
                    self.fishNum.text = "\(purchaseResponse.result?.point ?? 0)"
                    NotificationCenter.default.post(name: .itemPurchased, object: nil)
                    self.showAlert(title: "성공", message: "아이템이 성공적으로 구매되었습니다.")
                } else {
                    self.showAlert(title: "구매 실패", message: purchaseResponse.message)
                }
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                self.showAlert(title: "오류", message: "네트워크 오류가 발생했습니다.")
            }
        }
    }

    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    private func registerXib() {
        let nibName = UINib(nibName: cellName, bundle: nil)
        ShopCollection.register(nibName, forCellWithReuseIdentifier: cellReuseIdentifier)
    }
    
    // 셀 선택 시 호출되는 메서드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let target = shopList[indexPath.row]
        didTapItem(withId: target.id)
    }
    
    func didTapItem(withId itemId: Int) {
        let target = shopList.first { $0.id == itemId }
        let fullText = "\(target?.title ?? "이 아이템")을(를) 구매하시겠습니까?"
        let attributedTitle = NSMutableAttributedString(string: fullText)
        
        // "title"에 Semibold 16px 적용
        let titleRange = (fullText as NSString).range(of: target?.title ?? "")
        attributedTitle.addAttribute(.font, value: UIFont.pretendardSemibold(size: 16), range: titleRange)
        
        // "을(를) 구매하시겠습니까?"에 Medium 16px 적용
        let messageRange = (fullText as NSString).range(of: "을(를) 구매하시겠습니까?")
        attributedTitle.addAttribute(.font, value: UIFont.pretendardMedium(size: 16), range: messageRange)
        
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        alert.setValue(attributedTitle, forKey: "attributedTitle")
        
        let cancel = UIAlertAction(title: "아니오", style: .default, handler: nil)
        cancel.setValue(UIColor(named: "BlueGray7"), forKey: "titleTextColor")
        
        let confirm = UIAlertAction(title: "네", style: .default) { action in
            self.purchaseItem(withId: itemId)
        }
        confirm.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
}

extension Notification.Name {
    static let itemPurchased = Notification.Name("itemPurchased")
}
