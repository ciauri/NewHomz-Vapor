//
//  Image.swift
//  xmlxml
//
//  Created by stephenciauri on 8/11/18.
//

import Foundation
import SWXMLHash

struct BDXImage: Codable {
    let url: URL
    let position: Int
    let title: String?
    let caption: String?
    let isPreferred: Bool
}

extension BDXImage {
    init?(withIndexer xml: XMLIndexer) {
        guard let url = xml.element?.text.toURL,
            let position = xml.element?.attribute(by: "SequencePosition")?.text.toInt else {
                return nil
        }
        self.url = url
        self.position = position
        title = xml.element?.attribute(by: "Title")?.text
        caption = xml.element?.attribute(by: "Caption")?.text
        isPreferred = xml.element?.attribute(by: "IsPreferredSubImage")?.text.toInt ?? 0 > 0
    }
}
