//
//  Extension.swift
//  Coupon near you
//
//  Created by Siddarth Reddy on 10/12/23.
//

import SwiftUI

extension Color {
    static let darkBlue = Color(
        red: 0x05 / 255,
        green: 0x0C / 255,
        blue: 0x22 / 255
    )
    
    static let skyBlue = Color(
        red: 0x1E / 255,
        green: 0x7E / 255,
        blue: 0xC1 / 255
    )
}

extension View {
    func logo() -> some View {
        Image("logo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.main.bounds.width / 1.5, height: UIScreen.main.bounds.width / 1.5)
    }
}

