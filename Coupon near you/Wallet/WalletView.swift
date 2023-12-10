import SwiftUI

struct WalletView: View {
    @EnvironmentObject var couponsViewModel: CouponsViewModel
    @State private var selectedCoupon: Coupon? = nil
    
    var body: some View {
        ZStack {
//            Image("3")
//                .resizable()
//                .ignoresSafeArea()
            
            VStack {
                if couponsViewModel.capturedCoupons.isEmpty {
                    Image("team")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: UIScreen.main.bounds.width / 3.0, height: UIScreen.main.bounds.width / 3.0)
                    Text("Oh oh! Looks like you don't have any captured coupons on your wallet yet!")
                        .font(.title2)
                        .foregroundColor(Color.skyBlue)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack {
                            ForEach(couponsViewModel.capturedCoupons) { coupon in
                                CouponContainer(coupon: coupon)
                                    .onTapGesture {
                                        selectedCoupon = coupon
                                    }
                                Divider()
                                    .padding(.horizontal, 30)
                            }
                        }
                    }
                }
            }
            .onAppear {
                couponsViewModel.loadCapturedCoupons()
            }
            .navigationBarTitle("My wallet")
            .sheet(item: $selectedCoupon) { coupon in
//                CouponView()
                VStack {
                            Text("Swipe down to close")
                    Text(coupon.name)
                    ARQuickLookView(name: coupon.name.lowercased())
                        }
//                CouponDescriptionView(coupon: coupon)
//                    .presentationDetents([.height(320)])
            }
        }
    }
}

struct WalletView_Previews: PreviewProvider {
    static var previews: some View {
        WalletView()
            .environmentObject(CouponsViewModel())
    }
}
