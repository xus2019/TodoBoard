import SpriteKit

final class SakuraEffect: AmbienceScene {
    override func rebuildScene() {
        removeAllChildren()
        addChild(makeEmitter())
    }

    private func makeEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = CGFloat(24) * density
        emitter.particleLifetime = 9
        emitter.particleSpeed = 90
        emitter.particleSpeedRange = 35
        emitter.emissionAngle = -.pi / 2
        emitter.xAcceleration = 14
        emitter.particleScale = 0.45
        emitter.particleScaleRange = 0.15
        emitter.particleAlpha = 0.7
        emitter.particleAlphaRange = 0.15
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = .init(red: 1, green: 0.72, blue: 0.77, alpha: 0.85)
        emitter.particleRotationRange = .pi
        emitter.particleRotationSpeed = 0.35
        emitter.particleTexture = sakuraTexture()
        emitter.position = CGPoint(x: size.width / 2, y: size.height + 20)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        return emitter
    }
}
