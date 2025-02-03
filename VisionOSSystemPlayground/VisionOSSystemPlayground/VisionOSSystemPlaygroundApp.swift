//
//  VisionOSSystemPlaygroundApp.swift
//  VisionOSSystemPlayground
//
//  Created by Tempuno e.U. on 03.02.25.
//

import OSLog
import SwiftUI
import RealityKitContent

@MainActor
let logger = Logger(subsystem: "com.tempuno.VisionOSSystemPlayground", category: "general")

@main
struct LaserSystemApp: App {
    
    @State var viewModel = ViewModel()
    
    @Environment(\.openWindow) var openWindow
    
    init() {
        registerComponentsAndSystems()
    }
    
    var body: some Scene {
        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
                .environment(viewModel)
                .upperLimbVisibility(.visible)
            //                .onAppear {
            //                    openWindow(id: "UI")
            //                }
        }
        
        // If needed use UserInterfaceView as native vision window
        //        WindowGroup(id: "UI") {
        //            UserInterfaceView(viewModel: viewModel)
        //                .environment(viewModel)
        //        }
        //        .defaultSize(width: 1, height: 0.75, depth: 1, in: .meters)
        //        .windowStyle(.plain)
        //        .defaultWindowPlacement { content, context in
        //            return WindowPlacement(.utilityPanel)
        //        }
    }
    
    func registerComponentsAndSystems() {
        GestureComponent.registerComponent()
        HandTrackingComponent.registerComponent()
        HandTrackingRuntimeComponent.registerComponent()
        LabelComponent.registerComponent()
        LabelRuntimeComponent.registerComponent()
        LookAtComponent.registerComponent()
        NonResettableComponent.registerComponent()
        ShiftableMaterialComponent.registerComponent()
        
        HandTrackingSystem.registerSystem()
        LookAtSystem.registerSystem()
        ShiftableMaterialSystem.registerSystem()
    }
}

