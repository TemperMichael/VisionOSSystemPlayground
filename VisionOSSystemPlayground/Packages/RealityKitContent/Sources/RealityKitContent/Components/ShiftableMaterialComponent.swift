//
//  ShiftableMaterialComponent.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 03.02.25.
//

import RealityKit

public struct ShiftableMaterialComponent: Component, Codable {
    public var isHit = false
    public var shouldRecoverShiftLevel = true
    public var shouldLockOnFullShift = false
    
    public var shiftLevel: Float = 0
    public var shiftStep: Float = 0.01
    public var maximumShiftLevel: Float = 1
}
