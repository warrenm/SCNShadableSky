
import SceneKit
import QuartzCore

class ViewController: NSViewController {
    
    @IBOutlet var scnView: SCNView!
    @IBOutlet var timeSlider: NSSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SCNScene()
        scnView.scene = scene
        scnView.allowsCameraControl = true

        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 50, z: 0)
        scene.rootNode.addChildNode(cameraNode)
  
        let skyGeometry = SCNSphere(radius: 70)

        let skyMaterial = skyGeometry.firstMaterial!
        skyMaterial.isDoubleSided = true

        let skyProgram = SCNProgram()
        skyProgram.library = scnView.device?.makeDefaultLibrary()
        skyProgram.vertexFunctionName = "sky_vertex"
        skyProgram.fragmentFunctionName = "sky_fragment"
        skyMaterial.program = skyProgram

        let skyImage = NSImage(named: "sky")!
        let skyTexture = SCNMaterialProperty(contents: skyImage)
        skyMaterial.setValue(skyTexture, forKey: "skyTexture")

        let skyNode = SCNNode(geometry: skyGeometry)
        scene.rootNode.addChildNode(skyNode)

        // Action to drive sky animation
        let action = SCNAction.customAction(duration: 1.0) { (node, progress) in
            DispatchQueue.main.async {
                self.updateTimeOfDay(node)
            }
        }
        skyNode.runAction(SCNAction.repeatForever(action))

        updateTimeOfDay(skyNode)
    }
    
    func updateTimeOfDay(_ node: SCNNode) {
        if let skyMaterial = node.geometry?.firstMaterial {
            var timeOfDay = self.timeSlider.floatValue
            let timeOfDayData = NSData(bytes: &timeOfDay, length: MemoryLayout<Float>.size)
            skyMaterial.setValue(timeOfDayData, forKey: "timeOfDay")
        }
    }
}
