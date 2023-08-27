//
//  ContainerCell.swift
//  NTLApp
//
//  Created by Tripsdoc on 11/08/23.
//

import UIKit

class ContainerCell: UITableViewCell {

    @IBOutlet weak var layerCell: UIView!
    @IBOutlet weak var containerNumber: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.backgroundColor = UIColor.clear
        layerCell.layer.cornerRadius = 15
        layerCell.clipsToBounds = true
        layerCell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMaxYCorner]
        // Configure the view for the selected state
    }

}
