//
//  HandGesture.swift
//  RealityKitContent
//
//  Created by Tempuno e.U. on 31.01.25.
//

public enum HandGesture {
    case none
    case fist
    case middleFingerTap
    case ringFingerTap
    
    public var name: String {
        switch self {
        case .none:
            return "None"
        case .fist:
            return "Fist"
        case .middleFingerTap:
            return "Middle Tap"
        case .ringFingerTap:
            return "Ring Tap"
        }
    }
}
