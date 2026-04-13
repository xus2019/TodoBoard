import SpriteKit

final class SnowEffect: AmbienceScene {
    override func rebuildScene() {
        removeAllChildren()
        addChild(makeEmitter())
    }

    private func makeEmitter() -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleBirthRate = CGFloat(45) * density
        emitter.particleLifetime = 10
        emitter.particleSpeed = 55
        emitter.particleSpeedRange = 20
        emitter.emissionAngle = -.pi / 2
        emitter.xAcceleration = 6
        emitter.particleScale = 0.35
        emitter.particleScaleRange = 0.15
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.2
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = .white
        emitter.particleTexture = snowTexture()
        emitter.position = CGPoint(x: size.width / 2, y: size.height + 20)
        emitter.particlePositionRange = CGVector(dx: size.width, dy: 0)
        return emitter
    }
}
