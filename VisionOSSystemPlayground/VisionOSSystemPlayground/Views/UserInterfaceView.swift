//
//  UserInterfaceView.swift
//  VisionOSSystemPlayground
//
//  Created by Tempuno e.U. on 03.02.25.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct UserInterfaceView: View {
    
    @Environment(ViewModel.self) var viewModel
    
    @State var buttons: [ButtonModel<AnyShapeStyle, AnyShapeStyle>] = []
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("\(viewModel.currentHandGesture[.left]?.name ?? "-")")
                    Spacer()
                    Text("\(viewModel.currentHandGesture[.right]?.name ?? "-")")
                }
                .padding([.leading, .trailing])
            }
            .frame(width: 1100, height: 300)

            ForEach(buttons) { button in
                Button(action: button.action) {
                    Text(button.title)
                        .frame(maxWidth: .infinity,
                               minHeight: 300,
                               maxHeight: .infinity)
                }
                .tint(button.tint)
                .background(button.background)
                .clipShape(RoundedRectangle(cornerRadius: .infinity))
                .glassBackgroundEffect(in: RoundedRectangle(cornerRadius: .infinity))
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .font(
            .system(
                size: 100,
                weight: .bold,
                design: .rounded
            )
        )
        .onAppear {
            setupButtons()
        }
    }
    
    func setupButtons() {
        buttons = [
            ButtonModel(title: "Reset", tint:
                            AnyShapeStyle(Color.red.opacity(0.5))) {
                Task {
                    if let scene = try? await Entity(named: immersiveSceneName,
                                                     in: realityKitContentBundle) {
                        viewModel.root.children
                            .filter { !$0.components.has(NonResettableComponent.self) }
                            .forEach { $0.removeFromParent() }
                        viewModel.root.addChild(scene)
                    }
                }
            }
        ]
    }
}

#Preview {
    UserInterfaceView()
        .environment(ViewModel())
}
