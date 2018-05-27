//
//  cellDownloadTableViewCell.swift
//  Panasonic
//
//  Created by PHUCLONG on 8/2/16.
//  Copyright © 2016 PHUCLONG. All rights reserved.
//

import UIKit

class cellDownloadTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lbDescription: UILabel!
    
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
