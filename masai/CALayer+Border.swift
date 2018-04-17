//
//  CALayer+Border.swift
//  masai
//
//  Created by Florian Rath on 27.08.17.
//  Copyright © 2017 Codepool GmbH. All rights reserved.
//

import Foundation
import UIKit


extension CALayer {
    
    static func createDashedBorderLayer(edge: UIRectEdge, color: UIColor, thickness: CGFloat, dashPattern: [NSNumber]?) -> CAShapeLayer {
        let borderLayer = CAShapeLayer()
        
//        updateFrame(for: borderLayer, edge: edge, thickness: thickness)
        
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = thickness
        borderLayer.lineDashPattern = dashPattern
        
        return borderLayer
    }
    
    static func createBorderLayer(edge: UIRectEdge, color: UIColor, thickness: CGFloat) -> CALayer {
        let borderLayer = CALayer()
        
//        updateFrame(for: borderLayer, edge: edge, thickness: thickness)
        
        borderLayer.backgroundColor = color.cgColor
        
        return borderLayer
    }
    
    func updateFrame(for border: CALayer, edge: UIRectEdge, thickness: CGFloat) {
        switch edge {
        case UIRectEdge.top:
            border.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: thickness)
            
        case UIRectEdge.bottom:
            border.frame = CGRect(x: 0, y: self.bounds.height - thickness, width: self.bounds.width, height: thickness)
            
        case UIRectEdge.left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: self.bounds.height)
            
        case UIRectEdge.right:
            border.frame = CGRect(x: self.bounds.width - thickness, y: 0, width: thickness, height: self.bounds.height)
            
        default:
            break
        }
        
        if let shapeLayer = border as? CAShapeLayer {
            let path = CGMutablePath()
            var from = CGPoint(x: 0, y: 0)
            var to = CGPoint(x: 0, y: 0)
            
            switch edge {
            case UIRectEdge.top:
                from.y = thickness / 2.0
                to.y = from.y
                to.x = self.bounds.size.width
            case UIRectEdge.bottom:
                from.y = self.bounds.size.height - (thickness / 2.0)
                to.y = from.y
                to.x = self.bounds.size.width
            case UIRectEdge.left:
                from.x = thickness / 2.0
                to.x = from.x
                to.y = self.bounds.size.height
            case UIRectEdge.right:
                from.x = self.bounds.size.width - (thickness / 2.0)
                to.x = from.x
                to.y = self.bounds.size.height
                
            default:
                break
            }
            
            path.addLines(between: [from, to])
            shapeLayer.path = path
        }
    }
    
}
