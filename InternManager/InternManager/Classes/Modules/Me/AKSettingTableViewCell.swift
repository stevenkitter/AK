//
//  AKSettingTableViewCell.swift
//  InternManager
//
//  Created by hsgene_xu on 2017/9/21.
//  Copyright © 2017年 coderX. All rights reserved.
//

import UIKit

class AKSettingTableViewCell: UITableViewCell {

    @IBOutlet weak var ak_titleLabel: UILabel!
    
    @IBOutlet weak var ak_switch: UISwitch!
    
    var switched: ((_ sender: UISwitch)->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func switched(_ sender: UISwitch) {
        switched?(sender)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
