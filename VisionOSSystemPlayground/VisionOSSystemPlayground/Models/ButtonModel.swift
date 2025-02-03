//
//  ButtonModel.swift
//  VisionOSSystemPlayground
//
//  Created by Tempuno e.U. on 03.02.25.
//

import SwiftUI

struct ButtonModel<S: ShapeStyle, T: ShapeStyle>: Identifiable {
    let id = UUID()
    let title: String
    let background: S
    let tint: T
    let action: () -> Void
    
    init(
        title: String,
        background: S = AnyShapeStyle(Material.regularMaterial),
        tint: T = AnyShapeStyle(Color.clear),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.action = action
        self.background = background
        self.tint = tint
    }
}
