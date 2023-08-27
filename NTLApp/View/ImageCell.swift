//
//  ImageCell.swift
//  NTLApp
//
//  Created by Tripsdoc on 16/08/23.
//

import UIKit

class ImageCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var crossMarkView: CrossMark!
    override func awakeFromNib() {
        super.awakeFromNib()
        crossMarkView = CrossMark(frame: CGRect(x: frame.width-30, y: 5, width: 30, height: 30))
        crossMarkView.backgroundColor = UIColor.clear
        self.addSubview(crossMarkView)
    }
}
