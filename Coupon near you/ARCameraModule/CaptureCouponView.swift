import SwiftUI
import CoreLocation
import ARKit

struct CaptureCouponView: View {
    @EnvironmentObject var couponsViewModel: CouponsViewModel
    @EnvironmentObject var locationViewModel: LocationViewModel
    
    let coupon: Coupon
    
    @State private var isShowingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var aimOffset = CGSize.zero
    @State private var isImageCatchHimAnimating = false
    @State private var isDescriptionCouponAnimating = false
    
    var body: some View {
        ZStack {
            if ARWorldTrackingConfiguration.isSupported {
                ARViewContainer(coupon: coupon)
                    .ignoresSafeArea()
            } else {
                Text("ARKit is not supported on this device.")
                    .foregroundColor(.red)
            }
            
            VStack {
                VStack {
                    HStack {
                        VStack {
                            Capsule()
                                .fill(Color.darkBlue.opacity(0.6))
                                .frame(width: 180, height: 70)
                                .overlay {
                                    HStack {
                                        Image(uiImage: coupon.image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 60)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .padding(5)
                                        
                                        VStack(alignment: .leading) {
                                            Text(coupon.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                                .padding(.trailing,5)
                                            Text("Coupon Value: \(coupon.level)")
                                                .font(.caption)
                                                .foregroundColor(.white)
                                        }
                                        Spacer()
                                    }
                                }
                        }
                        .opacity(isDescriptionCouponAnimating ? 1 : 0)
                        .offset(y: CGFloat(isDescriptionCouponAnimating ? 0 : -200))
                        .animation(.interpolatingSpring(stiffness: 170, damping: 8).delay(0.5), value: isDescriptionCouponAnimating)
                        .padding()
                    }
                }
                .frame(width: 180, height: 70)
                .padding(.bottom, 20)
                
                Image("catch-him")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200)
                    .opacity(isImageCatchHimAnimating ? 0.9 : 0)
                    .scaleEffect(isImageCatchHimAnimating ? 2.2 : 1.0)
                    .animation(isImageCatchHimAnimating ? .interpolatingSpring(stiffness: 170, damping: 8, initialVelocity: 10).delay(0.5) : .easeInOut(duration: 0.5), value: isImageCatchHimAnimating)
                    .padding(.top, 20)
                Spacer()
                
                Image("aim")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .opacity(0.8)
                    .offset(aimOffset)
                Spacer()
                
                Button(action: {
                    tryToCaptureCoupon()
                    animateAim()
                }) {
                    ZStack {
                        Capsule()
                            .fill(Color.darkBlue.opacity(0.6))
                            .frame(width: 280, height: 60)
                        Text("Try to catch")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            setupCapture()
        }
        .alert(isPresented: $isShowingAlert) {
            switch alertTitle {
            case "Hooray!":
                return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Return to map")) {
                    returnToMapView()
                })
            case "The coupon has expired!":
                return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    returnToMapView()
                })
            default:
                return Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func setupCapture() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            catchit()
            animateAim()
        }
        isDescriptionCouponAnimating = true
    }
    
    private func tryToCaptureCoupon() {
        let randomChance = Int.random(in: 1...100)
        
        if randomChance <= 20 {
            couponsViewModel.addCouponToTeam(coupon)
            alertTitle = "Hooray!"
            alertMessage = "You added \(coupon.name) to your coupons"
        } else if randomChance <= 50 {
            alertTitle = "The coupon has expired!"
            alertMessage = ""
        } else {
            alertTitle = "It didn't work out :("
            alertMessage = "Try catching it again!"
        }
        
        isShowingAlert = true
    }
    
    private func returnToMapView() {
        couponsViewModel.isShowingCaptureCouponView = false
    }
    
    private func animateAim() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            aimOffset = CGSize(
                width: CGFloat.random(in: -50...50),
                height: CGFloat.random(in: -50...50)
            )
        }
    }
    
    private func catchit() {
        isImageCatchHimAnimating = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isImageCatchHimAnimating.toggle()
        }
    }
}

struct CaptureCouponView_Previews: PreviewProvider {
    static var previews: some View {
//        comebackhere
        CaptureCouponView()
    }
}

