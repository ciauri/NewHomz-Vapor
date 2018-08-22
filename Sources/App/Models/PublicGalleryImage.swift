//
//  PublicGalleryImage.swift
//  App
//
//  Created by stephenciauri on 8/17/18.
//

import Foundation
import Vapor

struct PublicGalleryImage: Content {
    let url: String
    let caption: String
    let position: Int
}

extension DBGalleryImage {
    var toPublicImage: PublicGalleryImage {
        return PublicGalleryImage(url: photo, caption: caption, position: showOrder)
    }
}
