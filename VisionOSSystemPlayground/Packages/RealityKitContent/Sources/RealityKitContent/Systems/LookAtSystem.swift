//
//  LookAtSystem.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 03.02.25.
//

import RealityKit

@MainActor
public class LookAtSystem: @preconcurrency System {

    public static let query = EntityQuery(where: .has(LookAtComponent.self))
    
    public static var dependencies: [SystemDependency] {
        []
    }

    required public init(scene: RealityKit.Scene) { }

    public func update(context: SceneUpdateContext) {
        context.scene.performQuery(Self.query).forEach { entity in
            guard let lookAtComponent = entity.lookAtComponent,
                  lookAtComponent.isActive else {
                return
            }
            
            entity.look(at: lookAtComponent.lookDestination,
                        from: entity.position(relativeTo: nil),
                        relativeTo: nil)
            
            entity.transform.rotation *= simd_quatf(angle: lookAtComponent.deferredRotationAngle,
                                                    axis: lookAtComponent.deferredRotationAxis)
        }
    }
}
