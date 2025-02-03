//
//  LookAtComponent.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 03.02.25.
//

import RealityKit

// Native BillboardComponent breaks SwiftUI attachment input (FB16425912) - use this one instead
public struct LookAtComponent: Component {
    public var isActive: Bool
    public var lookDestination: SIMD3<Float>
    public var deferredRotationAngle: Float
    public var deferredRotationAxis: SIMD3<Float>

    public init(
        isActive: Bool = true,
        lookDestination: SIMD3<Float> = .one,
        deferredRotationAngle: Float = .pi,
        deferredRotationAxis: SIMD3<Float> = [0, 1, 0]
    ) {
        self.isActive = isActive
        self.lookDestination = lookDestination
        self.deferredRotationAngle = deferredRotationAngle
        self.deferredRotationAxis = deferredRotationAxis
    }
}
