//
//  AttachmentsProvider.swift
//  VisionOSSystemPlayground
//
//  Created by Tempuno e.U. on 03.02.25.
//

import SwiftUI

@Observable
final class AttachmentsProvider {

    var attachments: [ObjectIdentifier: AnyView] = [:]

    var sortedTagViewPairs: [(tag: ObjectIdentifier, view: AnyView)] {
        attachments.map { key, value in
            (tag: key, view: value)
        }.sorted { $0.tag < $1.tag }
    }
}
