import CoreLocation
import UIKit
import CoreMotion
import Combine

class TelemetryManager: NSObject, ObservableObject {
    @Published var currentTelemetry: TelemetryData?
    @Published var remoteTelemetry: TelemetryData?
    
    private let locationManager = CLLocationManager()
    private let motionManager = CMMotionManager()
    private var cancellables = Set<AnyCancellable>()
    
    private var lastSignificantMotion: Date = Date()
    private let movementThreshold: TimeInterval = 30 // 30秒間動きがなければ停滞とみなす
    
    override init() {
        super.init()
        setupLocationManager()
        setupMotionDetection()
        startTelemetryUpdates()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10m移動ごとに更新
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func setupMotionDetection() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 1.0
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            
            // 加速度の変化を検出
            let acceleration = sqrt(
                pow(data.acceleration.x, 2) +
                pow(data.acceleration.y, 2) +
                pow(data.acceleration.z, 2)
            )
            
            // 重力加速度(1.0)からの変化が0.1以上なら動いているとみなす
            if abs(acceleration - 1.0) > 0.1 {
                self.lastSignificantMotion = Date()
            }
        }
    }
    
    private func startTelemetryUpdates() {
        // 5秒ごとにテレメトリーデータを更新
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTelemetry()
            }
            .store(in: &cancellables)
        
        // Don't start location updates here - wait for permission
        // locationManager.startUpdatingLocation() will be called in didChangeAuthorization
    }
    
    private func updateTelemetry() {
        let batteryLevel = UIDevice.current.batteryLevel
        UIDevice.current.isBatteryMonitoringEnabled = true
        
        let isMoving = Date().timeIntervalSince(lastSignificantMotion) < movementThreshold
        
        let telemetry = TelemetryData(
            timestamp: Date(),
            altitude: locationManager.location?.altitude,
            latitude: locationManager.location?.coordinate.latitude,
            longitude: locationManager.location?.coordinate.longitude,
            batteryLevel: batteryLevel >= 0 ? batteryLevel : 1.0,
            isMoving: isMoving,
            deviceName: UIDevice.current.name
        )
        
        currentTelemetry = telemetry
    }
    
    func updateRemoteTelemetry(_ telemetry: TelemetryData) {
        remoteTelemetry = telemetry
    }
}

extension TelemetryManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 位置情報が更新されたらテレメトリーを更新
        updateTelemetry()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}
