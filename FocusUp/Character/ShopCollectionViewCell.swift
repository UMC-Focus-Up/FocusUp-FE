//
//  ShopCollectionViewCell.swift
//  FocusUp
//
//  Created by 김서윤 on 8/9/24.
//

import UIKit

class ShopCollectionViewCell: UICollectionViewCell {
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var itemImageView: UIImageView!
    @IBOutlet var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemLabel.font = UIFont.pretendardMedium(size: 15)
        categoryLabel.font = UIFont.pretendardRegular(size: 12)
        priceLabel.font = UIFont.pretendardMedium(size: 14)
    }

}
