import SpriteKit

final class Block: SKSpriteNode {

    var index: Int

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(index: Int, size: CGSize, texture: SKTexture) {
        self.index = index
        super.init(texture: texture, color: .clear, size: size)
    }
}
