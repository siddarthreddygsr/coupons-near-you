//
//  NoCameraPermissionView.swift
//  CatchTheMonsterAR
//

import SwiftUI

struct NoCameraPermissionView: View {
    @EnvironmentObject var cameraAuthorizationViewModel: CameraAuthorizationViewModel
    @State private var showAlert = false

    var body: some View {
        ZStack {
//            Image("4")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .ignoresSafeArea()
            
                Image("no-camera")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width / 4.0, height: UIScreen.main.bounds.width / 4.0)
        }
        .onAppear {
            showAlert = true
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(""),
                message: Text("Oops! The product coupons cannot appear without access to the camera. Give us permission to use the camera by going to your device's settings and setting the correct settings."),
                dismissButton: .default(Text("Go to Settings"), action: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl)
                    }
                })
            )
        }
    }
}

struct NoCameraPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        NoCameraPermissionView()
            .environmentObject(CameraAuthorizationViewModel())
    }
}
