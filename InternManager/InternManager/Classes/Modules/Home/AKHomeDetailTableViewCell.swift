//
//  AKHomeDetailTableViewCell.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/22.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit

class AKHomeDetailTableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
        // Configure the view for the selected state
    }
    
}
