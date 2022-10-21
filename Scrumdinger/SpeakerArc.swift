//
//  SpeakerArc.swift
//  Scrumdinger
//
//  Created by Kevin on 6/25/22.
//

import Foundation
import SwiftUI

struct SpeakerArc: Shape {
    let speakerIndex: Int
    let totalSpeakers: Int
    
    //computed property for degrees per arc
    private var degreesPerSpeaker: Double {
        360.0 / Double(totalSpeakers)
    }
    
    //computed property for start angle per arc
    private var startAngle: Angle {
        Angle(degrees: degreesPerSpeaker * Double(speakerIndex) + 1.0)
    }
    
    //computed property for end angle per arc
    private var endAngle: Angle {
        Angle(degrees: startAngle.degrees + degreesPerSpeaker - 1.0)
    }
    
    func path(in rect: CGRect) -> Path {
        //diameter for circle of the arc
        let diameter = min(rect.size.width, rect.size.height) - 24.0
        let radius = diameter / 2.0
        
        //center of rectangle (CGRect)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        return Path { path in
            //add arc to the path
            path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
    
    
}
