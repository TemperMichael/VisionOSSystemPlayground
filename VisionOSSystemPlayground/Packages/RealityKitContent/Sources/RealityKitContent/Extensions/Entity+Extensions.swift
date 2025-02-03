//
//  Entity+Extensions.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 03.02.25.
//

import RealityKit
import UIKit

public extension Entity {
    
    var collisionComponent: CollisionComponent? {
        get { components[CollisionComponent.self] }
        set { components[CollisionComponent.self] = newValue }
    }

    var gestureComponent: GestureComponent? {
        get { components[GestureComponent.self] }
        set { components[GestureComponent.self] = newValue }
    }
    
    var groundingShadowComponent: GroundingShadowComponent? {
        get { components[GroundingShadowComponent.self] }
        set { components[GroundingShadowComponent.self] = newValue }
    }
    
    var handTrackingComponent: HandTrackingComponent? {
        get { components[HandTrackingComponent.self] }
        set { components[HandTrackingComponent.self] = newValue }
    }
    
    var handTrackingRuntimeComponent: HandTrackingRuntimeComponent? {
        get { components[HandTrackingRuntimeComponent.self] }
        set { components[HandTrackingRuntimeComponent.self] = newValue }
    }
    
    var hoverEffectComponent: HoverEffectComponent? {
        get { components[HoverEffectComponent.self] }
        set { components[HoverEffectComponent.self] = newValue }
    }
    
    var inputTargetComponent: InputTargetComponent? {
        get { components[InputTargetComponent.self] }
        set { components[InputTargetComponent.self] = newValue }
    }
    
    var labelComponent: LabelComponent? {
        get { components[LabelComponent.self] }
        set { components[LabelComponent.self] = newValue }
    }
    
    var labelRuntimeComponent: LabelRuntimeComponent? {
        get { components[LabelRuntimeComponent.self] }
        set { components[LabelRuntimeComponent.self] = newValue }
    }
    
    var lookAtComponent: LookAtComponent? {
        get { components[LookAtComponent.self] }
        set { components[LookAtComponent.self] = newValue }
    }
    
    var modelComponent: ModelComponent? {
        // Entities other than spheres or cubes in RCP have their model for unknown reasons in the usdPrimitiveAxis child
        // Therefore, we check if this one exists
        get { components[ModelComponent.self] ?? findEntity(named: "usdPrimitiveAxis")?.components[ModelComponent.self] }
        set {
            if let entity = findEntity(named: "usdPrimitiveAxis") {
                entity.components[ModelComponent.self] = newValue
            } else {
                components[ModelComponent.self] = newValue
            }
        }
    }
    
    var opacityComponent: OpacityComponent? {
        get { components[OpacityComponent.self] }
        set { components[OpacityComponent.self] = newValue }
    }
    
    var particleEmitterComponent: ParticleEmitterComponent? {
        get { components[ParticleEmitterComponent.self] }
        set { components[ParticleEmitterComponent.self] = newValue }
    }
    
    var portalComponent: PortalComponent? {
        get { components[PortalComponent.self] }
        set { components[PortalComponent.self] = newValue }
    }
    
    var shiftableMaterialComponent: ShiftableMaterialComponent? {
        get { components[ShiftableMaterialComponent.self] }
        set { components[ShiftableMaterialComponent.self] = newValue }
    }
    
    /// Returns the position of the entity specified in the app's coordinate system. On
    /// iOS and macOS, which don't have a device native coordinate system, scene
    /// space is often referred to as "world space".
    var scenePosition: SIMD3<Float> {
        get { position(relativeTo: nil) }
        set { setPosition(newValue, relativeTo: nil) }
    }
    
    /// Returns the orientation of the entity specified in the app's coordinate system. On
    /// iOS and macOS, which don't have a device native coordinate system, scene
    /// space is often referred to as "world space".
    var sceneOrientation: simd_quatf {
        get { orientation(relativeTo: nil) }
        set { setOrientation(newValue, relativeTo: nil) }
    }
    
    func forEachDescendant<T: Component>(withComponent componentClass: T.Type, _ closure: (Entity, T) -> Void) {
        for child in children {
            if let component = child.components[componentClass] {
                closure(child, component)
            }
            child.forEachDescendant(withComponent: componentClass, closure)
        }
    }
    
    func forEachDescendant(_ closure: (Entity) -> Void) {
        for child in children {
            closure(child)
            child.forEachDescendant(closure)
        }
    }
}
