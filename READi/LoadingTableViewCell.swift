//
//  LoadingTableViewCell.swift
//  READi
//
//  Created by NobodyNada on 3/22/17.
//  Copyright © 2017 NobodyNada. All rights reserved.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
	}

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
