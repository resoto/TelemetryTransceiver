import MultipeerConnectivity
import Combine

class NetworkManager: NSObject, ObservableObject {
    private let serviceType = "telemetry-tc"
    private let myPeerID: MCPeerID
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?
    private var session: MCSession?
    
    @Published var connectedPeers: [MCPeerID] = []
    @Published var availablePeers: [MCPeerID] = []
    @Published var isAdvertising = false
    @Published var isBrowsing = false
    
    var onAudioDataReceived: ((Data, MCPeerID) -> Void)?
    var onTelemetryReceived: ((TelemetryData, MCPeerID) -> Void)?
    
    override init() {
        // デバイス名をPeer IDとして使用
        self.myPeerID = MCPeerID(displayName: UIDevice.current.name)
        super.init()
        
        setupSession()
    }
    
    private func setupSession() {
        session = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
    }
    
    func startAdvertising() {
        advertiser = MCNearbyServiceAdvertiser(peer: myPeerID, discoveryInfo: nil, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
        isAdvertising = true
    }
    
    func stopAdvertising() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
        isAdvertising = false
    }
    
    func startBrowsing() {
        browser = MCNearbyServiceBrowser(peer: myPeerID, serviceType: serviceType)
        browser?.delegate = self
        browser?.startBrowsingForPeers()
        isBrowsing = true
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
        browser = nil
        isBrowsing = false
    }
    
    func invitePeer(_ peerID: MCPeerID) {
        guard let browser = browser, let session = session else { return }
        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 30)
    }
    
    func sendAudioData(_ data: Data) {
        guard let session = session, !session.connectedPeers.isEmpty else { return }
        
        let packet = DataPacket(type: .audio, senderID: myPeerID.displayName, data: data)
        guard let packetData = packet.encode() else { return }
        
        do {
            try session.send(packetData, toPeers: session.connectedPeers, with: .unreliable)
        } catch {
            print("Failed to send audio data: \(error)")
        }
    }
    
    func sendTelemetry(_ telemetry: TelemetryData) {
        guard let session = session, !session.connectedPeers.isEmpty else { return }
        
        guard let telemetryData = try? JSONEncoder().encode(telemetry) else { return }
        let packet = DataPacket(type: .telemetry, senderID: myPeerID.displayName, data: telemetryData)
        guard let packetData = packet.encode() else { return }
        
        do {
            try session.send(packetData, toPeers: session.connectedPeers, with: .reliable)
        } catch {
            print("Failed to send telemetry: \(error)")
        }
    }
    
    func disconnect() {
        session?.disconnect()
        stopAdvertising()
        stopBrowsing()
    }
}

// MARK: - MCSessionDelegate

extension NetworkManager: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            self.connectedPeers = session.connectedPeers
            
            if state == .connected {
                print("Connected to: \(peerID.displayName)")
            } else if state == .notConnected {
                print("Disconnected from: \(peerID.displayName)")
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let packet = DataPacket.decode(from: data) else { return }
        
        DispatchQueue.main.async {
            switch packet.type {
            case .audio:
                self.onAudioDataReceived?(packet.data, peerID)
                
            case .telemetry:
                if let telemetry = try? JSONDecoder().decode(TelemetryData.self, from: packet.data) {
                    self.onTelemetryReceived?(telemetry, peerID)
                }
                
            case .beep:
                break
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Not used
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // Not used
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // Not used
    }
}

// MARK: - MCNearbyServiceAdvertiserDelegate

extension NetworkManager: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // 自動的に接続を受け入れる
        invitationHandler(true, session)
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension NetworkManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            if !self.availablePeers.contains(peerID) {
                self.availablePeers.append(peerID)
            }
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.availablePeers.removeAll { $0 == peerID }
        }
    }
}
