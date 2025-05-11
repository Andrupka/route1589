//
//  SceneKitView.swift
//  SceneKitTesting
//
//  Created by Андрей Гончаренко on 09.02.2025.
//

import SceneKit
import SwiftUI
import Foundation

struct SceneKitView: UIViewRepresentable {
    var startNode: String
    var goalNode: String
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.allowsCameraControl = true
        scnView.autoenablesDefaultLighting = true
        configureScene(scnView: scnView)
        return scnView
    }

    func updateUIView(_ scnView: SCNView, context: Context) {
        configureScene(scnView: scnView)
    }

    private func configureScene(scnView: SCNView) {
        guard let scene = SCNScene(named: "TestScene.scn") else { return }
        scnView.scene = scene
        
        // Clear previous elements
        scene.rootNode.childNodes.filter { $0.name == "pathLine" }.forEach { $0.removeFromParentNode() }
        scene.rootNode.childNodes.filter { $0.name == "debugMarker" }.forEach { $0.removeFromParentNode() }

        // Load and parse GraphML
        guard let graphMLUrl = Bundle.main.url(forResource: "map", withExtension: "graphml"),
              let graphMLData = try? Data(contentsOf: graphMLUrl) else {
            print("❌ Failed to load map.graphml")
            return
        }

        let parser = GraphMLParser()
        parser.parseGraphML(from: graphMLData)

        // Find path using A*
        let astar = AStar(graph: parser.graph)
        guard let path = astar.aStar(start: startNode, goal: goalNode) else {
            print("❌ No path found from \(startNode) to \(goalNode)")
            return
        }

        print("✅ Path found: \(path.joined(separator: " → "))")
        
        // Get world positions for all nodes in path
        var nodeWorldPositions = getWorldPositions(for: path, in: scene.rootNode)
        
        // Add debug markers for visualization
        // addDebugMarkers(for: nodeWorldPositions, to: scene.rootNode)
        
        // Draw path lines with proper 3D orientation
        drawPathLines(between: path, using: nodeWorldPositions, in: scene)
        
        // Configure camera
        configureCamera(in: scene, scnView: scnView)
    }
    
    // MARK: - Path Visualization
    
    private func getWorldPositions(for path: [String], in rootNode: SCNNode) -> [String: SCNVector3] {
        var positions = [String: SCNVector3]()
        traverseNodes(rootNode) { node in
            guard let name = node.name, path.contains(name) else { return }
            positions[name] = node.worldPosition
        }
        return positions
    }
    
    private func drawPathLines(between path: [String], using positions: [String: SCNVector3], in scene: SCNScene) {
        for i in 0..<path.count-1 {
            let nodeA = path[i]
            let nodeB = path[i+1]
            
            guard let posA = positions[nodeA], let posB = positions[nodeB] else { continue }
            
            let direction = posB - posA
            let distance = direction.length
            
            let cylinder = SCNCylinder(radius: 0.12, height: CGFloat(distance))
            cylinder.firstMaterial = createPathMaterial()
            
            let lineNode = SCNNode(geometry: cylinder)
            lineNode.name = "pathLine"
            
            // Position and orient in world space
            lineNode.worldPosition = (posA + posB) * 0.5
            lineNode.eulerAngles = direction.eulerAngles
            
            scene.rootNode.addChildNode(lineNode)
        }
    }
    
    private func createPathMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.systemBlue
        material.emission.intensity = 1
        material.blendMode = .add
        material.readsFromDepthBuffer = false
        material.writesToDepthBuffer = false
        return material
    }
    
    // MARK: - Debug Helpers
    
    private func addDebugMarkers(for positions: [String: SCNVector3], to rootNode: SCNNode) {
        for (name, position) in positions {
            let sphere = SCNSphere(radius: 0.15)
            sphere.firstMaterial?.diffuse.contents = UIColor.red
            let marker = SCNNode(geometry: sphere)
            marker.name = "debugMarker"
            marker.worldPosition = position
            rootNode.addChildNode(marker)
        }
    }
    
    // MARK: - Camera Configuration
    
    private func configureCamera(in scene: SCNScene, scnView: SCNView) {
        guard let cameraNode = findCameraNode(in: scene.rootNode) else { return }
        scnView.pointOfView = cameraNode
    }
    
    // MARK: - Node Utilities
    
    private func traverseNodes(_ node: SCNNode, _ block: (SCNNode) -> Void) {
        block(node)
        node.childNodes.forEach { traverseNodes($0, block) }
    }
    
    private func findCameraNode(in node: SCNNode) -> SCNNode? {
        if node.camera != nil { return node }
        for child in node.childNodes {
            if let found = findCameraNode(in: child) { return found }
        }
        return nil
    }
}

// MARK: - Vector Math Extensions

extension SCNVector3 {
    static func - (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x - rhs.x, lhs.y - rhs.y, lhs.z - rhs.z)
    }
    
    static func + (lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
    
    static func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
        return SCNVector3(vector.x * scalar, vector.y * scalar, vector.z * scalar)
    }
    
    var length: Float {
        return sqrt(x*x + y*y + z*z)
    }
    
    var normalized: SCNVector3 {
        let len = length
        return len > 0 ? self * (1/len) : self
    }
    
    var eulerAngles: SCNVector3 {
        let yAxis = SCNVector3(0, 1, 0)
        let cross = SCNVector3(
            yAxis.y * self.z - yAxis.z * self.y,
            yAxis.z * self.x - yAxis.x * self.z,
            yAxis.x * self.y - yAxis.y * self.x
        )
        let dot = yAxis.x * self.x + yAxis.y * self.y + yAxis.z * self.z
        let angle = acos(dot / (yAxis.length * self.length))
        return SCNVector3(cross.x, cross.y, cross.z).normalized * angle
    }
}
