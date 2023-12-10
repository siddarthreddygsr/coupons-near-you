import SwiftUI

struct LocationRequestView: View {
    @EnvironmentObject private var locationViewModel: LocationViewModel
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
//            Image("1")
//                .resizable()
//                .ignoresSafeArea()
            
            VStack {
                logo()
                    .opacity(0.7)
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(""),
                message: Text("In order for us to show you and your closest product coupons, we need permission to access your location. Don't worry, we won't deliver random products to your address!"),
                dismissButton: .default(Text("Allow"), action: {
                    locationViewModel.requestPermission()
                })
            )
        }
        .onAppear {
            showAlert = true
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        LocationRequestView()
    }
}
