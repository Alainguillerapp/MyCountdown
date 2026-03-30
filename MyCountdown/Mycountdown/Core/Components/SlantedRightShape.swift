//
//  SlantedRightShape.swift
//  Mycountdown
//
//  Created by Alexander Grushanskiy on 14.01.2026.
//

import Foundation
import SwiftUI

struct SlantedRightShape: Shape {

    var slant: CGFloat = 22

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let x = rect.minX + slant

        path.move(to: CGPoint(x: x, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: x, y: rect.maxY))

        path.addQuadCurve(
            to: CGPoint(x: x, y: rect.minY),
            control: CGPoint(x: x - slant, y: rect.midY)
        )

        path.closeSubpath()
        return path
    }
}
