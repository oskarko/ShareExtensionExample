//
//  CustomCell.swift
//  ShareExtensions
//
//  Created by Oscar Rodriguez Garrucho on 20/3/18.
//  Copyright © 2018 oscargarrucho.com. All rights reserved.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var textLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(text: String){
        
        textLbl.text = text
    }

}
