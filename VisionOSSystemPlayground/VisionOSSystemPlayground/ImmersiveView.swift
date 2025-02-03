//
//  ImmersiveView.swift
//  VisionOSSystemPlayground
//
//  Created by Tempuno e.U. on 03.02.25.
//

import ARKit
import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    
    @State private var subscriptions = [EventSubscription]()
    @State private var attachmentsProvider = AttachmentsProvider()

    @Environment(\.realityKitScene) var scene
    @Environment(ViewModel.self) var viewModel
    
    var body: some View {
        RealityView { content, attachments in
            if let scene = try? await Entity(named: immersiveSceneName,
                                             in: realityKitContentBundle) {
                viewModel.root.position = [0, 1.5, -2]
                viewModel.root.addChild(scene)
                content.add(viewModel.root)
            }
            
            if let ui = attachments.entity(for: "UI") {
                ui.components.set(NonResettableComponent())
                ui.components.set(LookAtComponent())
                ui.position.y -= 1
                viewModel.root.addChild(ui)
            }
            
            subscriptions.append(content.subscribe(to: SceneEvents.Update.self) { update in
                if viewModel.worldTrackingProvider.state == .running,
                   let pose = viewModel.worldTrackingProvider.queryDeviceAnchor(atTimestamp: CACurrentMediaTime()) {
                    update.scene.performQuery(LookAtSystem.query).forEach { entity in
                        let destination = Transform(matrix: pose.originFromAnchorTransform).translation
                        entity.lookAtComponent?.lookDestination = destination
                    }
                }
            })
            
            subscriptions.append(content.subscribe(to: ComponentEvents.DidAdd.self, componentType: LabelComponent.self, { event in
                createLabel(for: event.entity)
                event.entity.components.set(HoverEffectComponent())
            }))
            
            subscriptions.append(content.subscribe(to: ComponentEvents.DidAdd.self, componentType: HandTrackingComponent.self, { event in
#if !targetEnvironment(simulator)
                let key = "Default"
                viewModel.handSelectionId = key
                
                let isPresetRight = event.entity.handTrackingComponent!.presetChirality == .right
                let chirality: HandAnchor.Chirality = isPresetRight ? .right : .left
                if viewModel.handEntities[key] == nil {
                    viewModel.handEntities[key] = [:]
                }
                viewModel.handEntities[key]?[chirality] = event.entity
#else
                event.entity.components.set(InputTargetComponent())
                event.entity.components.set(GestureComponent(pivotOnDrag: false,
                                                             preserveOrientationOnPivotDrag: false))
#endif
            }))
        } update: { content, attachments in
            viewModel.root.scene?.performQuery(EntityQuery(where: .has(LabelComponent.self))).forEach { entity in
                guard let labelRunTimeComponent = entity.labelRuntimeComponent,
                      let labelEntity = attachments.entity(for: labelRunTimeComponent.attachmentTag),
                      labelEntity.parent == nil else {
                    return
                }

                // Native BillboardComponent breaks SwiftUI attachment input (FB16425912) - use this one instead
                labelEntity.components.set(LookAtComponent())
                
                entity.addChild(labelEntity)
                labelEntity.setPosition([0.0, -0.2, 0.0], relativeTo: entity)
            }
        } attachments: {
            Attachment(id: "UI") {
                UserInterfaceView()
                    .environment(viewModel)
            }
            
            ForEach(attachmentsProvider.sortedTagViewPairs, id: \.tag) { pair in
                Attachment(id: pair.tag) {
                    pair.view
                }
            }
        }
        .installGestures()
        .task {
            await viewModel.startProviders()
        }
        .task {
            await viewModel.processHandUpdates()
        }
        // Combine DragGesture with zero minimumDistance to trigger onChanged event for LongPressGesture
        .simultaneousGesture(DragGesture(minimumDistance: 0).targetedToAnyEntity()
            .simultaneously(with: LongPressGesture(minimumDuration: 0).targetedToAnyEntity())
            .onChanged { value in
                if let entity = value.second?.entity {
                    handleInput(for: entity, with: .longPressChanged)
                }
            }
            .onEnded { value in
                if let entity = value.second?.entity {
                    handleInput(for: entity, with: .longPressEnded)
                }
            }
        )
    }
    
    // Causes the error log "Initializing hosting entity without a context", but can be ignored:
    // https://developer.apple.com/forums/thread/756766?answerId=822910022#822910022
    private func createLabel(for entity: Entity) {
        guard let labelComponent = entity.labelComponent,
              !labelComponent.text.isEmpty else {
            return
        }
        
        let tag: ObjectIdentifier = entity.id
                
        let view = Text(labelComponent.text)
            .font(.system(size: 64, weight: .bold, design: .rounded))
            .multilineTextAlignment(.center)
            .frame(width: 600, height: 200)
            .padding()
            .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: .infinity))
            .tag(tag)
        
        entity.labelRuntimeComponent = LabelRuntimeComponent(attachmentTag: tag)
                
        attachmentsProvider.attachments[entity.id] = AnyView(view)
    }
    
    private func handleInput(for entity: Entity, with gestureState: GestureState) {
        entity.shiftableMaterialComponent?.isHit = gestureState == .longPressChanged
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(ViewModel())
}
