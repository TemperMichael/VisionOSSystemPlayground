//
//  HandTrackingComponent.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 03.02.25.
//

import ARKit
import RealityKit
import UIKit

public struct HandTrackingComponent: Codable, Component {
    public var isActive: Bool = false
    public var presetChirality: HandChirality = .right
    public var isTrackingPosition: Bool = true
    public var isTrackingRotation: Bool = true
    public var isTrackingScale: Bool = true
}

public struct HandTrackingRuntimeComponent: Component {
    public var jointTransforms: [HandSkeleton.JointName: float4x4] = .init()
    public var lastEndPosition: SIMD3<Float> = .zero
    public var lastEndRotation: simd_quatf = .init()
    public var lastEndScale: SIMD3<Float> = .zero
    public var chirality: HandAnchor.Chirality = .right
    public var currentHandGesture: HandGesture = .none
    
    public init(
        lastEndPosition: SIMD3<Float> = .zero,
        lastEndRotation: simd_quatf = .init(),
        lastEndScale: SIMD3<Float> = .zero,
        chirality: HandAnchor.Chirality = .right
    ) {
        self.lastEndPosition = lastEndPosition
        self.lastEndRotation = lastEndRotation
        self.lastEndScale = lastEndScale
        self.chirality = chirality
    }
}
