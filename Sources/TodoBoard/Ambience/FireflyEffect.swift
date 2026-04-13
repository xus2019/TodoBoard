import SpriteKit

final class FireflyEffect: AmbienceScene {
    override func rebuildScene() {
        removeAllChildren()
        guard size.width > 0, size.height > 0 else { return }
        let count = max(1, Int(18.0 * density))
        (0..<count).forEach { _ in
            let node = SKShapeNode(circleOfRadius: CGFloat.random(in: 3...6))
            node.fillColor = .init(red: 1, green: 0.84, blue: 0, alpha: CGFloat.random(in: 0.4...0.8))
            node.strokeColor = .clear
            node.glowWidth = 3
            node.position = CGPoint(x: .random(in: 0...size.width), y: .random(in: 0...size.height))
            let move = SKAction.moveBy(x: .random(in: -80...80), y: .random(in: -40...40), duration: .random(in: 3...6))
            let fade = SKAction.sequence([
                .fadeAlpha(to: 0.2, duration: 1.5),
                .fadeAlpha(to: 0.9, duration: 1.5),
            ])
            node.run(.repeatForever(.sequence([move, move.reversed()])))
            node.run(.repeatForever(fade))
            addChild(node)
        }
    }
}
