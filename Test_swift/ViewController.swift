//
//  ViewController.swift
//  Test_swift
//
//  Created by 张倬豪 on 2017/7/19.
//  Copyright © 2017年 Icarus. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var IID: UUID!
    var scene: SCNScene!
    var cityNode: SCNNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let plane = SCNPlane(width: 0.1, height: 0.1)
        let lavaImage = UIImage(named: "APP")
        let lavaMaterial = SCNMaterial()
        lavaMaterial.diffuse.contents = lavaImage
        lavaMaterial.isDoubleSided = true
        
        plane.materials = [lavaMaterial]
        let planenode = SCNNode(geometry: plane)
        planenode.position = SCNVector3Make(0.2, 0, 0.2)
        reloadMesh()
        //planenode.addChildNode(scene.rootNode)
        planenode.scale = SCNVector3Make(0.5,0.5,0.5)
        
        print(scene.rootNode.position)
        //planenode.
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.scene.rootNode.addChildNode(planenode);
        
        
        //let mod = SCNNode(geometry: SCNGeometrySource()
        // Set the scene to the view
        //sceneView.scene = scene
    }
    
    func reloadMesh() {
        scene = SCNScene(named: "art.scnassets/region1_smaller.DAE")!
        let lavaMaterial = SCNMaterial()
        lavaMaterial.diffuse.contents = UIColor(colorLiteralRed: 0.4, green: 0.4, blue: 0.5, alpha: 1.0)
        lavaMaterial.ambient.contents = UIColor(colorLiteralRed: 1, green: 1, blue: 1, alpha: 1)
        lavaMaterial.specular.contents = UIColor(colorLiteralRed: 0.5, green: 0.7, blue: 0.9, alpha: 1)
        lavaMaterial.shininess = 32.0
        //lavaMaterial.reflective.contents = UIColor(colorLiteralRed: 0.5, green: 0.7, blue: 0.5, alpha: 1)
        lavaMaterial.lightingModel = .phong
        lavaMaterial.isDoubleSided = false
        scene.rootNode.enumerateHierarchy{
            (cn,_) in cn.geometry?.materials = [lavaMaterial]
        }
        //cityNode = scene.rootNode
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let t:UITouch = touch as! UITouch
            //当在屏幕上连续拍动两下时，获得一个平面
            //print(t.tapCount)
            if(t.tapCount >= 2)
            {
                if(IID != nil) { return }
                let res = sceneView.hitTest(t.location(in: sceneView), types: ARHitTestResult.ResultType.existingPlaneUsingExtent)
                if (res.count == 0) {return}
                let anchor = res[0].anchor!
                IID = res[0].anchor?.identifier
                print(IID)
                
                reloadMesh()
                cityNode = scene.rootNode
                cityNode.scale = SCNVector3Make(0.5, 0.5, 0.5)
                let pos = SCNVector3Make(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                cityNode.position = pos
                //cityNode.orientation = node.orientation
                print(cityNode.position)
                sceneView.scene = scene
                //let tmp = sceneView.session as! ARWorldTrackingSessionConfiguration
                //tmp.planeDetection = .init(rawValue: 0)
            }
            
            print("event begin!")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        // Create a SceneKit plane to visualize the node using its position and extent.
        // Create the geometry and its materials
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        //let lavaImage = UIImage(named: "APP")
        let lavaMaterial = SCNMaterial()
        lavaMaterial.diffuse.contents = UIColor(colorLiteralRed: 1.0, green: 0.2, blue: 0.3, alpha: 0.5)
        lavaMaterial.isDoubleSided = true
        
        plane.materials = [lavaMaterial]
        
        // Create a node with the plane geometry we created
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        return planeNode
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        if(IID != nil) {return}
        let planeNode = createPlaneNode(anchor: planeAnchor)
        //print("Fuck YOU a")
        if(IID != nil && anchor.identifier == IID) {
            //let cityNode = SCNScene(named: "art.scnassets/region1_smaller.DAE")!
            if(cityNode == nil) {
                reloadMesh()
                cityNode = scene.rootNode
                let pos = SCNVector3Make(anchor.transform.columns.3.x, anchor.transform.columns.3.y, anchor.transform.columns.3.z)
                cityNode.position = pos
                cityNode.orientation = node.orientation
                print(cityNode.position)
                sceneView.scene.rootNode.addChildNode(cityNode!)
            }
            else {
                //print(IID)
                cityNode.position = node.position
                cityNode.orientation = node.orientation
                //print(node.position)
            }
        }
        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        //print("Fuck you B")
        // Remove existing plane nodes
        node.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }
        if(IID != nil) {return}
        let planeNode = createPlaneNode(anchor: planeAnchor)
        /*if(IID != nil && anchor.identifier == IID) {
            //let cityNode = SCNScene(named: "art.scnassets/region1_smaller.DAE")!
            if(cityNode == nil) {
                reloadMesh()
                cityNode = scene.rootNode
                
                cityNode.position = node.position
                cityNode.orientation = node.orientation
                
                sceneView.scene.rootNode.addChildNode(cityNode)
            }
            else {
                reloadMesh()
                print(IID)
                cityNode.position = node.position
                cityNode.orientation = node.orientation
                print(node.position)
            }
        }*/
        node.addChildNode(planeNode)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        
        guard anchor is ARPlaneAnchor else { return }
        
        // Remove existing plane nodes
        node.enumerateChildNodes {
            (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        if(IID != nil && anchor.identifier == IID)
        {
            IID = nil
            reloadMesh()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
