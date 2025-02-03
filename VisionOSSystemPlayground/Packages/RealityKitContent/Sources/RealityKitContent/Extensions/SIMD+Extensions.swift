//
//  SIMD+Extensions.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 03.02.25.
//

import RealityKit

public extension SIMD4 {
    
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}

public extension simd_float4x4 {

    var forwardVector: SIMD3<Float> { SIMD3<Float>(-columns.2.x, -columns.2.y, -columns.2.z) }
    var position: SIMD3<Float> { SIMD3<Float>(columns.3.x, columns.3.y, columns.3.z) }
    
    var right: SIMD3<Float> { columns.0.xyz }
    var up: SIMD3<Float> { columns.1.xyz }
    var forward: SIMD3<Float> { columns.2.xyz }
}
