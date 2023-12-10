import SwiftUI
import MapKit

struct MapCouponsView: View {
    @EnvironmentObject var couponsViewModel: CouponsViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    @EnvironmentObject var cameraAuthorizationViewModel: CameraAuthorizationViewModel
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.751244, longitude: 37.618423),
        span: MKCoordinateSpan(latitudeDelta: 0.6, longitudeDelta: 0.6)
    )
    @State private var showUserLocation = false
    @State private var userCoordinate = CLLocationCoordinate2D()
    @State private var selectedCouponIndex: Int?
    @State private var shouldAutoCenter = true
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: MapInteractionModes.all, showsUserLocation: showUserLocation, userTrackingMode: .constant(.follow), annotationItems: couponsViewModel.coupons) { coupon in
                MapAnnotation(coordinate: coupon.coordinate.coordinate) {
                    Button(action: {
                        if let selectedCouponIndex = couponsViewModel.coupons.firstIndex(where: { $0.id == coupon.id }) {
                            let selectedCoupon = couponsViewModel.coupons[selectedCouponIndex]
                            
                            if selectedCoupon.distanceToUser <= 100 {
                                DispatchQueue.main.async {
                                    cameraAuthorizationViewModel.requestCameraAccess()
                                    couponsViewModel.isShowingCaptureCouponView = true
                                    self.selectedCouponIndex = selectedCouponIndex
                                }
                            } else {
                                let distance = Int(selectedCoupon.distanceToUser)
                                let alertMessage = "You are too far from the coupon – \(distance) meters"
                                showAlert(alertMessage)
                            }
                        }
                    }) {
                        Image(uiImage: coupon.image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: couponSize(for: region.span))
                    }
                }
            }
            .ignoresSafeArea()
            
            VStack {
                HStack() {
                    Spacer()
                    Image("logo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 90)
                        .padding(.trailing, 10)
                }
                Spacer()
                
                HStack {
                    Spacer()
                    VStack(spacing: 20) {
                        Button(action: zoomIn) {
                            ZStack {
                                Circle()
                                    .fill(Color.darkBlue.opacity(0.6))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        
                        Button(action: zoomOut) {
                            ZStack {
                                Circle()
                                    .fill(Color.darkBlue.opacity(0.6))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "minus")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .frame(width: 30, height: 30)
                            }
                        }
                        .padding(.bottom, 60)
                        
                        Button(action: centerMapOnUserLocation) {
                            ZStack {
                                Circle()
                                    .fill(Color.darkBlue.opacity(0.6))
                                    .frame(width: 60, height: 60)
                                Image(systemName: "location")
                                    .foregroundColor(.white)
                                    .font(.title)
                                    .frame(width: 30, height: 30)
                            }
                        }
                    }
                    .padding(20)
                }
                Spacer()
            }
            
            VStack {
                Spacer()
                NavigationLink(destination: WalletView()
                    .environmentObject(couponsViewModel)
                ) {
                    ZStack {
                        Capsule()
                            .fill(Color.darkBlue.opacity(0.6))
                            .frame(width: 200, height: 60)
                        Text("My Coupons")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.bottom, 20)
                .navigationBarBackButtonHidden(true)
                .navigationTitle("")
                .navigationBarHidden(true)
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .onAppear {
            setupMap()
            setupCoupons()
        }
        .onReceive(locationViewModel.$userLocation) { userLocation in
            if let coordinate = userLocation {
                self.userCoordinate = coordinate
                
                if shouldAutoCenter {
                    region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002))
                }

                couponsViewModel.updateUserCoordinate(coordinate)
                shouldAutoCenter = false
            }
        }
        .fullScreenCover(isPresented: $couponsViewModel.isShowingCaptureCouponView, onDismiss: {
            if let index = selectedCouponIndex {
                couponsViewModel.captureCoupon(at: index)
            }
        }) {
            if let index = selectedCouponIndex, index < couponsViewModel.coupons.count {
                if cameraAuthorizationViewModel.authorizationStatus == .authorized {
                    CaptureCouponView(coupon: couponsViewModel.coupons[index])
                        .environmentObject(couponsViewModel)
                        .environmentObject(locationViewModel)
                        .environmentObject(cameraAuthorizationViewModel)
                } else {
                    NoCameraPermissionView()
                        .environmentObject(cameraAuthorizationViewModel)
                }
            }
        }
    }
    
    private func setupMap() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            showUserLocation = true
        }
    }
    
    private func setupCoupons() {
        DispatchQueue.main.async {
            guard let userLocation = locationViewModel.userLocation else { return }
            couponsViewModel.generateInitialCoupons(with: userLocation)
            couponsViewModel.startUpdatingCoupons(with: userLocation)
        }
    }

    private func zoomOut() {
        let maxDelta: CLLocationDegrees = 180 /// Максимальное значение дельты широты или долготы

        let newLatitudeDelta = min(region.span.latitudeDelta * 1.25, maxDelta)
        let newLongitudeDelta = min(region.span.longitudeDelta * 1.25, maxDelta)

        region.span = MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)
        shouldAutoCenter = false
    }

    private func zoomIn() {
        let minDelta: CLLocationDegrees = 0.001 /// Минимальное значение дельты широты или долготы

        let newLatitudeDelta = max(region.span.latitudeDelta * 0.75, minDelta)
        let newLongitudeDelta = max(region.span.longitudeDelta * 0.75, minDelta)

        region.span = MKCoordinateSpan(latitudeDelta: newLatitudeDelta, longitudeDelta: newLongitudeDelta)
        shouldAutoCenter = false
    }
    
    private func centerMapOnUserLocation() {
        region.center = userCoordinate
        shouldAutoCenter = true
    }
    
    private func showAlert(_ message: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let alert = UIAlertController(title: "Attention", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        window.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    private func couponSize(for span: MKCoordinateSpan) -> CGFloat {
        // Максимальный допустимый масштаб карты, при котором монстры будут видны
        let maxVisibleSpan: Double = 1.2
        
        let maxDelta = max(span.latitudeDelta, span.longitudeDelta)
        let scaleFactor = 1 / maxDelta

        // Масштабирование с учетом диапазона и чувствительности
        let minScaleFactor: CGFloat = 0.5
        let maxScaleFactor: CGFloat = 2.0
        let sensitivity: CGFloat = 0.1
        let scaledSize = scaleFactor * sensitivity
        let clampedScale = max(min(scaledSize, maxScaleFactor), minScaleFactor)

        // Проверка на слишком большой масштаб карты, чтобы монстры были невидимы
        if maxDelta > maxVisibleSpan {
            return 0.0
        }

        let baseSize: CGFloat = 40
        let finalSize = baseSize * clampedScale
        return finalSize
    }
}

struct MapCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        MapCouponsView()
            .environmentObject(LocationViewModel())
            .environmentObject(CouponsViewModel())
            .preferredColorScheme(.dark)
    }
}

