//
//  cellMenuTableViewCell.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/1/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class cellMenuTableViewCell: UITableViewCell {

    @IBOutlet weak var imgMenu: UIImageView!
    @IBOutlet weak var lbMenu: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
