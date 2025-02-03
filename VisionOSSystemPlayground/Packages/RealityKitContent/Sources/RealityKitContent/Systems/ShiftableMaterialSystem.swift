//
//  ShiftableMaterialSystem.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 03.02.25.
//

import RealityKit

@MainActor
public struct ShiftableMaterialSystem: @preconcurrency System {
    
    public static let query = EntityQuery(where: .has(ShiftableMaterialComponent.self))
    
    public static var dependencies: [SystemDependency] {
        []
    }
    
    public init(scene: RealityKit.Scene) { }
    
    public func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            guard var shiftableMaterialComponent = entity.shiftableMaterialComponent else {
                continue
            }
            
            var shiftLevel = shiftableMaterialComponent.shiftLevel
            let maximumShiftLevel = shiftableMaterialComponent.maximumShiftLevel
            let shiftStep = shiftableMaterialComponent.shiftStep
            
            if shiftLevel == 1 && shiftableMaterialComponent.shouldLockOnFullShift {
                continue
            }

            if shiftableMaterialComponent.isHit {
                if shiftLevel < maximumShiftLevel {
                    shiftLevel += shiftStep
                } else if shiftLevel > maximumShiftLevel {
                    shiftLevel = maximumShiftLevel
                }
            } else if shiftableMaterialComponent.shouldRecoverShiftLevel {
                if shiftLevel > 0 {
                    shiftLevel -= shiftStep
                } else if shiftLevel < 0 {
                    shiftLevel = 0
                }
            }
            
            if var shaderMaterial = entity.modelComponent?.materials.first as? ShaderGraphMaterial {
                try? shaderMaterial.setParameter(name: "ShiftValue", value: .float(shiftLevel))
                entity.modelComponent?.materials[0] = shaderMaterial
            }
        
            shiftableMaterialComponent.shiftLevel = shiftLevel
            entity.shiftableMaterialComponent = shiftableMaterialComponent
        }
    }
}
