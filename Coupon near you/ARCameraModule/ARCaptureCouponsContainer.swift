import SwiftUI
import ARKit

struct ARViewContainer: UIViewRepresentable {
    let coupon: Coupon
    
    func makeUIView(context: Context) -> ARSCNView {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("ARKit is not supported on this device.")
            return ARSCNView()
        }

        let arView = ARSCNView(frame: .zero)
        
        // Настройка параметров просмотра дополненной реальности
        let configuration = ARWorldTrackingConfiguration()
        arView.session.run(configuration)
        
        // Добавляем монстра в AR-сцену
        let couponNode = createCouponNode()
        arView.scene.rootNode.addChildNode(couponNode)
        
        arView.showsStatistics = false
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
       //
    }
    
    private func createCouponNode() -> SCNNode {
        let couponNode = SCNNode()
        
        let couponImage = coupon.image
        
        // Получение пропорций изображения монстра
        let imageAspectRatio = couponImage.size.width / couponImage.size.height
        
        // Создание геометрии монстра
        let couponWidth: CGFloat = 0.8
        let couponHeight: CGFloat = couponWidth / imageAspectRatio /// Вычисление высоты монстра с учетом пропорций
        
        let couponPlane = SCNPlane(width: couponWidth, height: couponHeight)
        couponPlane.firstMaterial?.diffuse.contents = couponImage
      
        // Создание узла для плоскости монстра
        let couponPlaneNode = SCNNode(geometry: couponPlane)
        
        // Позиционирование монстра в окружении
        let couponHeightAboveGround: Float = -1.0 /// Высота монстра над землей
        let distanceFromDevice: Float = -2.5 /// Расстояние от устройства до монстра

        couponPlaneNode.position = SCNVector3(x: 0, y: couponHeightAboveGround, z: distanceFromDevice)
        
        couponPlane.firstMaterial?.isDoubleSided = true
        couponPlane.firstMaterial?.diffuse.intensity = 0.8
        
        couponNode.addChildNode(couponPlaneNode)

        // Создание текста
        let couponTexts = ["Grrr! Argh!", "Watch out!", "Boooooooooo!", "Roarr! Run!", "Raaaaaahh!"]
        let randomText = couponTexts.randomElement() ?? ""
        
        let textCoupon = SCNText(string: randomText, extrusionDepth: 0.1)
        textCoupon.firstMaterial?.diffuse.contents = UIColor.darkText
        textCoupon.flatness = 0.1

        let textNode = SCNNode(geometry: textCoupon)
        textNode.scale = SCNVector3(0.009, 0.009, 0.009)
        textNode.position = SCNVector3(x: -0.19, y: -0.46, z: -2.5)

        textNode.eulerAngles.z = Float.pi / 40 /// Поворот текста

        textCoupon.firstMaterial?.diffuse.intensity = 0.8

        couponNode.addChildNode(textNode)
        
        // Создание диалогового окна
        let dialogPlane = SCNPlane(width: 1.0, height: 0.65)
        dialogPlane.firstMaterial?.diffuse.contents = UIImage(named: "dialog")
                
        let dialogPlaneNode = SCNNode(geometry: dialogPlane)
        dialogPlaneNode.position = SCNVector3(x: 0.1, y: -0.4, z: -2.5)
        
        dialogPlane.firstMaterial?.isDoubleSided = true
        dialogPlane.firstMaterial?.diffuse.intensity = 0.8
        
        couponNode.addChildNode(dialogPlaneNode)

        return couponNode
    }
}
