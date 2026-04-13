import SpriteKit

final class StardustEffect: AmbienceScene {
    override func rebuildScene() {
        removeAllChildren()
        guard size.width > 0, size.height > 0 else { return }
        let count = max(1, Int(32.0 * density))
        (0..<count).forEach { _ in
            let node = SKShapeNode(circleOfRadius: CGFloat.random(in: 1.5...3.5))
            node.fillColor = .init(red: 0.88, green: 0.91, blue: 1, alpha: CGFloat.random(in: 0.35...0.7))
            node.strokeColor = .clear
            node.glowWidth = 2
            node.position = CGPoint(x: .random(in: 0...size.width), y: .random(in: 0...size.height))
            let move = SKAction.moveBy(x: .random(in: -60...60), y: .random(in: -20...20), duration: .random(in: 8...14))
            let twinkle = SKAction.sequence([
                .fadeAlpha(to: 0.15, duration: 1.8),
                .fadeAlpha(to: 0.7, duration: 1.8),
            ])
            node.run(.repeatForever(.sequence([move, move.reversed()])))
            node.run(.repeatForever(twinkle))
            addChild(node)
        }
    }
}
