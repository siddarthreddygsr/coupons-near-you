//
//  Coupon_near_youApp.swift
//  Coupon near you
//
//  Created by Siddarth Reddy on 10/12/23.
//

import SwiftUI

@main
struct Coupon_near_you_ARApp: App {
    @StateObject private var locationViewModel = LocationViewModel()
    @State private var isShowingSplash = true

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                ScreenView()
                    .preferredColorScheme(.dark)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            isShowingSplash = false
                        }
                    }
            } else {
                ContentView()
                    .preferredColorScheme(.dark)
                    .environmentObject(locationViewModel)
            }
        }
    }
}

