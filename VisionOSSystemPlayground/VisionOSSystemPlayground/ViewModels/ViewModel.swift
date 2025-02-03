//
//  ViewModel.swift
//  VisionOSSystemPlayground
//
//  Created by Tempuno e.U. on 03.02.25.
//

import ARKit
import SwiftUI
import RealityKit
import RealityKitContent

@Observable
@MainActor
final class ViewModel {
    var root = Entity()
    
    var handEntities: [String: [HandAnchor.Chirality: Entity]] = [:]
    var currentHandGesture: [HandAnchor.Chirality: HandGesture] = [:]
    var handSelectionId: String = ""
    
    let arkitSession = ARKitSession()
    let handTracking = HandTrackingProvider()
    let worldTrackingProvider = WorldTrackingProvider()
    
    var isReadyToRun: Bool {
#if targetEnvironment(simulator)
        worldTrackingProvider.state == .initialized
#else
        handTracking.state == .initialized && worldTrackingProvider.state == .initialized
#endif
    }
    
    var dataProvidersAreSupported: Bool {
#if targetEnvironment(simulator)
        WorldTrackingProvider.isSupported
#else
        HandTrackingProvider.isSupported && WorldTrackingProvider.isSupported
#endif
    }
    
    func startProviders() async {
        do {
            if dataProvidersAreSupported && isReadyToRun {
#if targetEnvironment(simulator)
                try await arkitSession.run([worldTrackingProvider])
#else
                try await arkitSession.run([handTracking, worldTrackingProvider])
#endif
            }
        } catch {
            logger.error("Failed to start session: \(error)")
        }
    }
    
    func processHandUpdates() async {
        for await update in handTracking.anchorUpdates {
            let handAnchor = update.anchor
            let chirality = handAnchor.chirality
            guard let skeleton = handAnchor.handSkeleton else { continue }
            
            let joints = HandSkeleton.JointName.allCases
            
            guard joints.allSatisfy({ skeleton.joint($0).isTracked }) else { continue }
            let originTransform = handAnchor.originFromAnchorTransform

            let jointTransforms = joints.reduce(into: [HandSkeleton.JointName: float4x4]()) {
                $0[$1] = originTransform * skeleton.joint($1).anchorFromJointTransform
            }
            
            if let handEntity = handEntities[handSelectionId]?[chirality],
               var handTrackingRuntimeComponent = handEntity.handTrackingRuntimeComponent {
                handTrackingRuntimeComponent.jointTransforms = jointTransforms
                handTrackingRuntimeComponent.chirality = chirality
                
                // To update the UI we also need to update a value in the viewmodel
                currentHandGesture[chirality] = handTrackingRuntimeComponent.currentHandGesture
                
                handEntity.handTrackingRuntimeComponent = handTrackingRuntimeComponent
            }
        }
    }
}
