//
//  ContentView.swift
//  Coupon near you
//
//  Created by Siddarth Reddy on 10/12/23.
//


import SwiftUI

struct ContentView: View {
    @EnvironmentObject var locationViewModel: LocationViewModel
    @StateObject private var couponsViewModel = CouponssViewModel()
    @StateObject private var cameraAuthorizationViewModel = CameraAuthorizationViewModel()

    var body: some View {
        NavigationView {
            VStack {
                switch locationViewModel.authorizationStatus {
                case .notDetermined:
                    LocationRequestView()
                case .restricted, .denied:
                    NoLocationPermissionView()
                case .authorizedAlways, .authorizedWhenInUse:
                    MapCouponsView()
                        .environmentObject(couponViewModel)
                        .environmentObject(cameraAuthorizationViewModel)
                default:
                    Text("Unknown status")
                }
            }
        }
    }
}
    
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(LocationViewModel())
    }
}
