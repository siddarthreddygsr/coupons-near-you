import CoreLocation
import UIKit

final class CouponsViewModel: ObservableObject {
    @Published var coupons: [Coupon] = []
    @Published var capturedCoupons: [Coupon] = []
    @Published var isShowingCaptureCouponView = false
    var userCoordinate: CLLocationCoordinate2D?
    private var isInitialCouponsGenerated = false
    private var timer: Timer?
    private var isTimerRunning = false
    private var lastUpdatedTime: Date?
    private let updateInterval: TimeInterval = 5 * 60
    

    let couponImages: [UIImage] = [
        UIImage(named: "pantry"),
        UIImage(named: "toys"),
        UIImage(named: "shoe")
    ].map { $0 ?? UIImage() }
    
    let couponDescriptions: [String: String] = [
        "pantry": "These coupons can be used to avail offers on select pantry items.",
        "toys": "These coupons can be used to avail offers on select toys.",
        "shoe": "These coupons can be used to avail offers on select shoes."
    ]
    
    func generateInitialCoupons(with userCoordinate: CLLocationCoordinate2D) {
        guard !isInitialCouponsGenerated else { return }
        
        coupons = (0...30).map { _ in
            generateRandomCoupon(with: userCoordinate)
        }
        
        isInitialCouponsGenerated = true
        setupNicknameCoupon()
    }
    
    private func generateRandomCoupon(with userCoordinate: CLLocationCoordinate2D) -> Coupon {
        let randomCoordinate = generateRandomCoordinate(from: userCoordinate)
        let randomImage = couponImages.randomElement() ?? UIImage()
        let randomLevel = Int.random(in: 5...20)
        let couponName = getCouponName(for: randomImage)
        let randomDescription = couponDescriptions[couponName] ?? ""
        
        return Coupon(name: couponName, image: randomImage, level: randomLevel, coordinate: randomCoordinate, description: randomDescription)
    }
    
    private func setupNicknameCoupon() {
        for index in 0..<coupons.count {
            let coupon = coupons[index]
            if let imageIndex = couponImages.firstIndex(of: coupon.image) {
                coupons[index].name = getCouponName(for: couponImages[imageIndex])
            }
        }
    }
    
    private func getCouponName(for image: UIImage) -> String {
        switch image {
        case couponImages[0]:
            return "pantry"
        case couponImages[1]:
            return "toys"
        case couponImages[2]:
            return "shoe"
        default:
            return ""
        }
    }
    
    func startUpdatingCoupons(with userCoordinate: CLLocationCoordinate2D?) {
        self.userCoordinate = userCoordinate
        
        guard let userCoordinate = userCoordinate else { return }
        
        generateInitialCoupons(with: userCoordinate)
        
        if !isTimerRunning {
            startTimer(with: userCoordinate)
            isTimerRunning = true
        }
    }
    
    private func startTimer(with userCoordinate: CLLocationCoordinate2D) {
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.updateCouponsIfNeeded()
        }
    }
    
    private func updateCouponsIfNeeded() {
        guard let lastUpdatedTime = lastUpdatedTime else {
            updateCoupons()
            return
        }
        
        if Date().timeIntervalSince(lastUpdatedTime) >= updateInterval {
            updateCoupons()
        }
    }
    

    private func updateCoupons() {
        timer?.invalidate()
        
        coupons = coupons.filter { _ in
            Int.random(in: 1...100) > 20
        }
        
        addRandomCoupons(with: userCoordinate ?? CLLocationCoordinate2D())
        
        lastUpdatedTime = Date()
        
        setupNicknameCoupon()
        startTimer(with: userCoordinate ?? CLLocationCoordinate2D())
    }
    
    private func updateDistancesToUser(from userCoordinate: CLLocationCoordinate2D) {
        for index in coupons.indices {
            let couponLocation = CLLocation(latitude: coupons[index].coordinate.latitude, longitude: coupons[index].coordinate.longitude)
            let userLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
            coupons[index].distanceToUser = couponLocation.distance(from: userLocation)
        }
    }
    
    private func removeRandomCoupons() {
        coupons = coupons.filter { _ in
            Int.random(in: 1...100) > 20
        }
    }
    
    private func addRandomCoupons(with userCoordinate: CLLocationCoordinate2D) {
        for _ in 0..<6 {
            coupons.append(generateRandomCoupon(with: userCoordinate))
        }
    }
    
    private func generateRandomCoordinate(from userCoordinate: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        let radiusInMeters: Double = 1000 /// Радиус в метрах
        let distance = Double.random(in: 0...radiusInMeters)
        let angle = Double.random(in: 0...(2 * Double.pi))
        
        let earthRadius = 6371000.0
        
        let lat1 = userCoordinate.latitude * Double.pi / 180
        let lon1 = userCoordinate.longitude * Double.pi / 180
        
        let lat2 = asin(sin(lat1) * cos(distance / earthRadius) + cos(lat1) * sin(distance / earthRadius) * cos(angle))
        let lon2 = lon1 + atan2(sin(angle) * sin(distance / earthRadius) * cos(lat1), cos(distance / earthRadius) - sin(lat1) * sin(lat2))
        
        let newLatitude = lat2 * 180 / Double.pi
        let newLongitude = lon2 * 180 / Double.pi
        
        return CLLocationCoordinate2D(latitude: newLatitude, longitude: newLongitude)
    }
    
    func updateUserCoordinate(_ coordinate: CLLocationCoordinate2D) {
        userCoordinate = coordinate
        updateDistancesToUser(from: coordinate)
    }
    
    func captureCoupon(at index: Int) {
        guard index >= 0 && index < coupons.count else {
            return
        }
        
        coupons.remove(at: index)
    }
    
    func addCouponToTeam(_ coupon: Coupon) {
        capturedCoupons.append(coupon)
        saveCapturedCoupons()
    }
    
    func saveCapturedCoupons() {
        let data = try? JSONEncoder().encode(capturedCoupons)
        UserDefaults.standard.set(data, forKey: "capturedCoupons")
    }
    
    func loadCapturedCoupons() {
        if let data = UserDefaults.standard.data(forKey: "capturedCoupons"),
           let decodedCoupons = try? JSONDecoder().decode([Coupon].self, from: data) {
            capturedCoupons = decodedCoupons
        }
    }
}

