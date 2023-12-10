import SwiftUI
import CoreLocation

struct CouponContainer: View {
    let coupon: Coupon
    
    var body: some View {
        HStack {
            Image(uiImage: coupon.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 110, height: 110)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(coupon.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    Image(systemName: "info.bubble")
                        .foregroundColor(.white)
                        .padding(.bottom)
                }
                Text("Coupon Level: \(coupon.level)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(20)
        }
    }
}

