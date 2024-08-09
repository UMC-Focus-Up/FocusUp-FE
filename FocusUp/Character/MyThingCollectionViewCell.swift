//
//  MyThingCollectionViewCell.swift
//  FocusUp
//
//  Created by 김서윤 on 8/9/24.
//

import UIKit

class MyThingCollectionViewCell: UICollectionViewCell {
    @IBOutlet var itemLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var itemImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        itemLabel.font = UIFont.pretendardMedium(size: 15)
        categoryLabel.font = UIFont.pretendardRegular(size: 12)
    }
}
