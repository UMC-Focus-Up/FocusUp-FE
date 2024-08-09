//
//  ShopViewController.swift
//  FocusUp
//
//  Created by 김서윤 on 8/9/24.
//

import UIKit

class ShopViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    // 데이터 불러오기
    let shopList = ShopThing.data
    let cellName = "ShopCollectionViewCell"
    let cellReuseIdentifier = "shopCell"
    
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
    
    private func registerXib() {
        let nibName = UINib(nibName: cellName, bundle: nil)
        ShopCollection.register(nibName, forCellWithReuseIdentifier: cellReuseIdentifier)
    }

    @IBOutlet var ShopCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ShopCollection.delegate = self
        ShopCollection.dataSource = self
        
        registerXib()
    }

    // 셀 선택 시 호출되는 메서드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let target = shopList[indexPath.row]
        didTapItem(withTitle: target.title)
    }
    
    func didTapItem(withTitle title: String) {
        let alert = UIAlertController(title: "\(title)을(를) 구매하시겠습니까?", message: "", preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "아니오", style: .default, handler: nil)
        cancel.setValue(UIColor(named: "BlueGray7"), forKey: "titleTextColor")
        
        let confirm = UIAlertAction(title: "네", style: .default) { action in
            print("\(title) 추가")
        }
        confirm.setValue(UIColor(named: "Primary4"), forKey: "titleTextColor")
        
        alert.addAction(cancel)
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
}
