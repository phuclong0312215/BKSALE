//
//  cellRequest.swift
//  Aqua
//
//  Created by PHUCLONG on 1/23/18.
//  Copyright © 2018 PHUCLONG. All rights reserved.
//

import UIKit

class cellRequest: UITableViewCell {

    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbWorking: UILabel!
    @IBOutlet weak var lbWorkingOld: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
