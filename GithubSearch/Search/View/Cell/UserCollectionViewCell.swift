//
//  UserCollectionViewCell.swift
//  GithubSearch
//
//  Created by George Liu on 2020/7/8.
//  Copyright © 2020 George Liu. All rights reserved.
//

import UIKit
import Kingfisher

class UserCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var userPicImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!

    func configure(name: String, picURLStr: String) {
        userNameLabel.text = name

        userPicImageView.kf.setImage(
            with: URL(string: picURLStr),
            placeholder: UIImage(named: "default_user")
        )
    }
}
