import AppKit
import SpriteKit

class AmbienceScene: SKScene {
    var density: CGFloat = 1.0

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    final override func didMove(to view: SKView) {
        backgroundColor = .clear
        rebuildScene()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard oldSize != size else { return }
        rebuildScene()
    }

    func rebuildScene() {}

    func updateDensity(_ newDensity: CGFloat) {
        density = newDensity
        rebuildScene()
    }

    func makeTexture(size: CGSize, draw: (NSRect) -> Void) -> SKTexture {
        let image = NSImage(size: size)
        image.lockFocus()
        NSColor.clear.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: size)).fill()
        draw(NSRect(origin: .zero, size: size))
        image.unlockFocus()
        return SKTexture(image: image)
    }

    func rainTexture() -> SKTexture {
        makeTexture(size: CGSize(width: 4, height: 22)) { _ in
            NSColor(calibratedRed: 0.75, green: 0.85, blue: 1, alpha: 0.6).setFill()
            NSBezierPath(roundedRect: NSRect(x: 0.5, y: 0, width: 3, height: 22), xRadius: 1.5, yRadius: 1.5).fill()
        }
    }

    func snowTexture() -> SKTexture {
        makeTexture(size: CGSize(width: 14, height: 14)) { rect in
            NSColor.white.withAlphaComponent(0.95).setFill()
            NSBezierPath(ovalIn: rect.insetBy(dx: 1, dy: 1)).fill()
        }
    }

    func sakuraTexture() -> SKTexture {
        makeTexture(size: CGSize(width: 18, height: 18)) { rect in
            let color = NSColor(calibratedRed: 1, green: 0.78, blue: 0.84, alpha: 0.92)
            color.setFill()
            let petalA = NSBezierPath(ovalIn: NSRect(x: 4, y: 7, width: 7, height: 9))
            petalA.fill()
            let petalB = NSBezierPath(ovalIn: NSRect(x: 7, y: 7, width: 7, height: 9))
            petalB.fill()
            let petalC = NSBezierPath(ovalIn: NSRect(x: 5, y: 3, width: 8, height: 9))
            petalC.fill()
            NSColor.white.withAlphaComponent(0.5).setFill()
            NSBezierPath(ovalIn: rect.insetBy(dx: 7, dy: 7)).fill()
        }
    }
}
