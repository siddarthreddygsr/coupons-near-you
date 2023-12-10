import SwiftUI
import CoreLocation

struct NoLocationPermissionView: View {
    @EnvironmentObject private var locationViewModel: LocationViewModel
    @State private var showAlert = false

    var body: some View {
        ZStack {

            
            VStack {
                logo()
                    .opacity(0.7)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(""),
                message: Text("Oh no! We couldn't access your location on the map! Let us find you. Open your device's settings and set the options you want to allow location access. Then we can find you and your nearby coupons!"),
                dismissButton: .default(Text("Open Settings"), action: {
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl)
                    }
                })
            )
        }
        .onAppear {
            showAlert = true
        }
    }
}

struct NoLocationPermissionView_Previews: PreviewProvider {
    static var previews: some View {
        NoLocationPermissionView()
    }
}
