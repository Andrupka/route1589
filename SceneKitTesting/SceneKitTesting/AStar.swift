//
//  AStar.swift
//  AStar
//
//  Created by Андрей Гончаренко on 03.02.2025.
//

import Foundation

class AStar {
    class Node {
        let id: String
        var g: Double // Cost from start to this node
        var h: Double // Heuristic cost to goal
        var f: Double { return g + h }
        var parent: Node?
        
        init(id: String, g: Double = 0, h: Double = 0, parent: Node? = nil) {
            self.id = id
            self.g = g
            self.h = h
            self.parent = parent
        }
    }
    
    // Symmetrical adjacency list (undirected graph)
    private var graph: [String: [String: Double]]
    
    init(graph: [String: [String: Double]]) {
        // Convert the graph to an undirected graph
        var undirectedGraph: [String: [String: Double]] = [:]
        for (node, neighbors) in graph {
            for (neighbor, cost) in neighbors {
                // Add A → B
                undirectedGraph[node, default: [:]][neighbor] = cost
                // Add B → A
                undirectedGraph[neighbor, default: [:]][node] = cost
            }
        }
        self.graph = undirectedGraph
    }
    
    // Euclidean distance heuristic (replace with your actual node positions)
    func heuristic(_ a: String, _ b: String) -> Double {
        // If you have node coordinates, use them here
        return 0 // Placeholder
    }
    
    func aStar(start: String, goal: String) -> [String]? {
        var openSet: [Node] = []
        var closedSet: Set<String> = []
        
        let startNode = Node(id: start, g: 0, h: heuristic(start, goal))
        openSet.append(startNode)
        
        while !openSet.isEmpty {
            openSet.sort { $0.f < $1.f }
            let currentNode = openSet.removeFirst()
            
            if currentNode.id == goal {
                return reconstructPath(currentNode)
            }
            
            closedSet.insert(currentNode.id)
            
            for (neighbor, cost) in graph[currentNode.id] ?? [:] {
                if closedSet.contains(neighbor) {
                    continue
                }
                
                let gScore = currentNode.g + cost
                let hScore = heuristic(neighbor, goal)
                let neighborNode = Node(id: neighbor, g: gScore, h: hScore, parent: currentNode)
                
                if let existingNodeIndex = openSet.firstIndex(where: { $0.id == neighbor }) {
                    if openSet[existingNodeIndex].g <= gScore {
                        continue
                    }
                    openSet[existingNodeIndex] = neighborNode
                } else {
                    openSet.append(neighborNode)
                }
            }
        }
        
        return nil // No path found
    }
    
    private func reconstructPath(_ node: Node) -> [String] {
        var path: [String] = []
        var current: Node? = node
        while let n = current {
            path.append(n.id)
            current = n.parent
        }
        return path.reversed()
    }
}
