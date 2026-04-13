import SpriteKit
import SwiftUI

struct AmbienceBackgroundView: View {
    @ObservedObject var themeManager: ThemeManager
    @State private var scene: AmbienceScene?
    @State private var renderedEffect: AmbienceEffect = .none

    private var effect: AmbienceEffect { themeManager.ambience }
    private var density: CGFloat { CGFloat(themeManager.ambienceDensity) }

    var body: some View {
        GeometryReader { proxy in
            Group {
                if effect == .none {
                    EmptyView()
                } else if let scene {
                    SpriteView(scene: scene, options: [.allowsTransparency])
                        .id(renderedEffect)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                        .transition(.opacity)
                } else {
                    EmptyView()
                }
            }
            .onAppear {
                updateScene(size: proxy.size, animated: false)
            }
            .onChange(of: effect) { _, _ in
                updateScene(size: proxy.size, animated: true)
            }
            .onChange(of: density) { _, newDensity in
                scene?.updateDensity(newDensity)
            }
            .onChange(of: proxy.size) { _, newSize in
                updateScene(size: newSize, animated: false)
            }
        }
    }

    private func scene(for effect: AmbienceEffect, size: CGSize) -> AmbienceScene {
        let s: AmbienceScene = switch effect {
        case .none:
            AmbienceScene(size: size)
        case .rain:
            RainEffect(size: size)
        case .snow:
            SnowEffect(size: size)
        case .firefly:
            FireflyEffect(size: size)
        case .sakura:
            SakuraEffect(size: size)
        case .stardust:
            StardustEffect(size: size)
        }
        s.density = density
        return s
    }

    private func updateScene(size: CGSize, animated: Bool) {
        guard effect != .none else {
            let updates = {
                scene = nil
                renderedEffect = .none
            }
            if animated {
                withAnimation(.easeInOut(duration: 0.5), updates)
            } else {
                updates()
            }
            return
        }
        let updates = {
            if renderedEffect != effect || scene == nil {
                scene = scene(for: effect, size: size)
                renderedEffect = effect
            } else {
                scene?.size = size
            }
        }
        if animated {
            withAnimation(.easeInOut(duration: 0.5), updates)
        } else {
            updates()
        }
    }
}
