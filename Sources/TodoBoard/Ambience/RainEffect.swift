import SpriteKit

final class RainEffect: AmbienceScene {
    override func rebuildScene() {
        removeAllChildren()
        addChild(makeEmitter())
    }

    private func makeEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = CGFloat(90) * density
        emitter.particleLifetime = 4
        emitter.particleSpeed = 420
        emitter.particleSpeedRange = 120
        emitter.emissionAngle = -.pi / 2 + 0.12
        emitter.particleScale = 0.35
        emitter.particleScaleRange = 0.1
        emitter.particleAlpha = 0.45
        emitter.particleAlphaRange = 0.15
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = .init(red: 0.78, green: 0.88, blue: 1, alpha: 0.7)
        emitter.particleTexture = rainTexture()
        emitter.position = CGPoint(x: size.width / 2, y: size.height + 20)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        return emitter
    }
}
