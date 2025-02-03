//
//  LabelComponent.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 03.02.25.
//

import RealityKit

public struct LabelComponent: Component, Codable {
    public var text: String = ""
}

public struct LabelRuntimeComponent: Component {
    public var attachmentTag: ObjectIdentifier
    
    public init(attachmentTag: ObjectIdentifier) {
        self.attachmentTag = attachmentTag
    }
}
