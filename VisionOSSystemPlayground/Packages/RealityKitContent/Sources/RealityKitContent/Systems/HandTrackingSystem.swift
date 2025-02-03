//
//  HandTrackingSystem.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 03.02.25.
//

import Combine
import RealityKit

@MainActor
public struct HandTrackingSystem: @preconcurrency System {
    
    public static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    public static var dependencies: [SystemDependency] {
        []
    }
    
    private var subscriptions = [Cancellable]()

    public init(scene: RealityKit.Scene) {
        subscriptions.append(scene.subscribe(to: ComponentEvents.DidAdd.self, componentType: HandTrackingComponent.self, { event in
            guard event.entity.handTrackingRuntimeComponent == nil else { return }
            event.entity.components.set(HandTrackingRuntimeComponent())
        }))
    }
    
    public func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard let handTrackingComponent = entity.handTrackingComponent,
                  handTrackingComponent.isActive else {
                continue
            }
            
            detectHandGesture(for: entity)
            handleHandGesture(for: entity)
            handleHandMovement(for: entity)
        }
    }
    
    func detectHandGesture(for entity: Entity) {
        guard var handTrackingRuntimeComponent = entity.handTrackingRuntimeComponent,
              !handTrackingRuntimeComponent.jointTransforms.isEmpty else {
            return
        }
        handTrackingRuntimeComponent.currentHandGesture = .none
        
        let jointTransforms = handTrackingRuntimeComponent.jointTransforms
        
        // Simple solution for detecting a fist
        // Check additional fingers for more precise result
        if distance(jointTransforms[.middleFingerMetacarpal]!.columns.3.xyz,
                    jointTransforms[.middleFingerTip]!.columns.3.xyz) < 0.07 {
            handTrackingRuntimeComponent.currentHandGesture = .fist
        }
        
        if distance(jointTransforms[.middleFingerTip]!.columns.3.xyz ,jointTransforms[.thumbTip]!.columns.3.xyz) < 0.02 {
            handTrackingRuntimeComponent.currentHandGesture = .middleFingerTap
        }
        
        if distance(jointTransforms[.ringFingerTip]!.columns.3.xyz ,jointTransforms[.thumbTip]!.columns.3.xyz) < 0.02 {
            handTrackingRuntimeComponent.currentHandGesture = .ringFingerTap
        }
        
        entity.handTrackingRuntimeComponent = handTrackingRuntimeComponent
    }
    
    func handleHandGesture(for entity: Entity) {
        guard let handTrackingRuntimeComponent = entity.handTrackingRuntimeComponent else {
            return
        }
        
        let currentHandGesture = handTrackingRuntimeComponent.currentHandGesture
        
        switch currentHandGesture {
        case .none:
            break
        case .fist:
            break
        case .middleFingerTap:
            break
        case .ringFingerTap:
            break
        }
    }
    
    func handleHandMovement(for entity: Entity) {
        guard let handTrackingComponent = entity.handTrackingComponent,
              var handTrackingRuntimeComponent = entity.handTrackingRuntimeComponent,
              !handTrackingRuntimeComponent.jointTransforms.isEmpty else {
            return
        }
        
        // All interpolations show how you can smoothen movements
        // Feel free to adapt the interpolation factors to your needs
        
        let jointTransforms = handTrackingRuntimeComponent.jointTransforms
        
        // Use hand center position
        var middleFingerMetacarpalBase = jointTransforms[.middleFingerMetacarpal]!
        middleFingerMetacarpalBase.columns.3 = jointTransforms[.middleFingerKnuckle]!.columns.3
        
        let transform = Transform(matrix: middleFingerMetacarpalBase)
        
        // MARK: Position Handling
        if handTrackingComponent.isTrackingPosition {
            let lastEndPosition = handTrackingRuntimeComponent.lastEndPosition
            let interpolationFactor: Float = 0.75
            let interEnd = lastEndPosition + (middleFingerMetacarpalBase.position - lastEndPosition) * interpolationFactor
            
            handTrackingRuntimeComponent.lastEndPosition = interEnd
            entity.setPosition(interEnd, relativeTo: nil)
        }
        
        // MARK: Rotation Handling
        if handTrackingComponent.isTrackingRotation {
            let rotation = transform.rotation
            let lastEndRotation = handTrackingRuntimeComponent.lastEndRotation
            // Showcase: Adapt interpolation to specific scenarios
            // Like here where we slow down rotations for fists
            let interpolationFactorRotation: Float = handTrackingRuntimeComponent.currentHandGesture == .fist ? 0.01 : 0.1
            let interEndRotation = simd_slerp(lastEndRotation, rotation, interpolationFactorRotation)
            
            entity.setOrientation(interEndRotation, relativeTo: nil)
            handTrackingRuntimeComponent.lastEndRotation = interEndRotation
        }
        
        // MARK: Scale Handling
        if handTrackingComponent.isTrackingScale {
            // Showcase: Adapt scale to specific scenarios
            // Like here where we connect the scaling factor to a specifc finger distance / to a fist
            let knucklePos = Transform(matrix: jointTransforms[.middleFingerKnuckle]!).translation
            let metacarpalPos = Transform(matrix: jointTransforms[.middleFingerMetacarpal]!).translation
            let tipPos = Transform(matrix: jointTransforms[.middleFingerTip]!).translation
            
            let midpoint = (knucklePos - metacarpalPos) / 2 + metacarpalPos
            let distance = length(midpoint - tipPos)
            
            let scale = SIMD3<Float>(repeating: distance)
            let lastEndScale = handTrackingRuntimeComponent.lastEndScale
            let interpolationFactorScale: Float = 0.2
            let interEndScale = lastEndScale + (scale - lastEndScale) * interpolationFactorScale
            
            entity.setScale(interEndScale * 4, relativeTo: nil)
            handTrackingRuntimeComponent.lastEndScale = interEndScale
        }
                
        entity.handTrackingRuntimeComponent = handTrackingRuntimeComponent
    }
}
