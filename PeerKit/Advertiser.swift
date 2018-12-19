//
//  Advertiser.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

class Advertiser: NSObject, MCNearbyServiceAdvertiserDelegate {

    let mcSession: MCSession
    init(mcSession: MCSession) {
        self.mcSession = mcSession
        super.init()
    }

    private var advertiser: MCNearbyServiceAdvertiser?

    func startAdvertising(serviceType: String, discoveryInfo: [String: String]? = nil) {
        advertiser = MCNearbyServiceAdvertiser(peer: mcSession.myPeerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }

    func stopAdvertising() {
        advertiser?.delegate = nil
        advertiser?.stopAdvertisingPeer()
    }

    func restartAdvertising() {
        advertiser?.startAdvertisingPeer()
        advertiser?.delegate = self
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        //https://developer.apple.com/library/content/qa/qa1869/_index.html
        //iOS8+, just accept
        invitationHandler(true, mcSession)
    }
}
