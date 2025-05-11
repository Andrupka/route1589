//
//  GraphParser.swift
//  AStar
//
//  Created by Андрей Гончаренко on 03.02.2025.
//

import Foundation

class GraphMLParser: NSObject, XMLParserDelegate {
    var graph: [String: [String: Double]] = [:]
    
    private var currentElement = ""
    private var currentNodeId: String?
    private var currentSource: String?
    private var currentTarget: String?
    private var currentWeight: Double = 1.0
    
    func parseGraphML(from data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }

    // MARK: - XMLParserDelegate Methods

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes attributeDict: [String: String]) {
        currentElement = elementName
        
        if elementName == "node" {
            if let nodeId = attributeDict["id"] {
                currentNodeId = nodeId
                graph[nodeId] = [:]
                // print("Parsed node ID: \(nodeId)") // Debug statement
            }
        } else if elementName == "edge" {
            currentSource = attributeDict["source"]
            currentTarget = attributeDict["target"]
            currentWeight = Double(attributeDict["weight"] ?? "1") ?? 1.0
            // print("Parsed edge from \(currentSource ?? "") to \(currentTarget ?? "") with weight \(currentWeight)") // Debug statement
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
        if elementName == "edge", let source = currentSource, let target = currentTarget {
            graph[source]?[target] = currentWeight
            // print("Added edge to graph: \(source) -> \(target) with weight \(currentWeight)") // Debug statement
        }
    }
}
