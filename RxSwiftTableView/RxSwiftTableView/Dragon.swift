//
//  Dragon.swift
//  RxSwiftTableView
//
//  Created by Anatoly Ryavkin on 01.04.2020.
//  Copyright © 2020 AnatolyRyavkin. All rights reserved.
//

import Foundation
import UIKit

struct Dragon {
    let name: String
    let flickrID: String
    let image: UIImage?

    init(name: String, flickerID: String) {
        self.name = name
        self.flickrID = flickerID
        self.image = UIImage(named: self.flickrID)
    }
}

extension Dragon: CustomStringConvertible{
    var description: String {
        return "\(name): flickr.com/\(flickrID)"
    }
}
