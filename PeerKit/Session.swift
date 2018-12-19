//
//  Session.swift
//  CardsAgainst
//
//  Created by JP Simard on 11/3/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public protocol SessionDelegate {
    func connecting(myPeerID: MCPeerID, toPeer peer: MCPeerID)
    func connected(myPeerID: MCPeerID, toPeer peer: MCPeerID)
    func disconnected(myPeerID: MCPeerID, fromPeer peer: MCPeerID)
    func receivedData(_ data: Data, fromPeer peer: MCPeerID)
    func finishReceivingResource(myPeerID: MCPeerID, resourceName: String, fromPeer peer: MCPeerID, atURL localURL: URL?)
}

public class Session: NSObject, MCSessionDelegate {
    public private(set) var myPeerID: MCPeerID
    public private(set) var mcSession: MCSession
    public private(set) var state: MCSessionState = .notConnected

    public init(displayName: String) {
        myPeerID = MCPeerID(displayName: displayName)
        mcSession = MCSession(peer: myPeerID, securityIdentity: nil, encryptionPreference: .none)
        super.init()
        mcSession.delegate = self
    }

    public func disconnect() {
        mcSession.delegate = nil
        mcSession.disconnect()
    }

    // MARK: MCSessionDelegate
    // http://stackoverflow.com/questions/18935288/why-does-my-mcsession-peer-disconnect-randomly, needs to check peerID

    public func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
            case .connecting:
                transceiver.connecting(myPeerID: myPeerID, toPeer: peerID)
                self.state = .connecting
            case .connected:
                transceiver.connected(myPeerID: myPeerID, toPeer: peerID)
                if self.state != .connected {
                    //called n times when MCSession has n connected peers
                    transceiver.advertiser.stopAdvertising();
                }
                self.state = .connected
            case .notConnected:
                transceiver.disconnected(myPeerID: myPeerID, fromPeer: peerID)
                // MEMO: stateに齟齬が会った時はリスタートする
                if self.state == .connected {
                    transceiver.advertiser.restartAdvertising()
                }
                self.state = .notConnected
        }
    }

    public func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        transceiver.receivedData(data, fromPeer: peerID)
    }

    public func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // unused
    }

    public func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // unused
    }

    public func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        if (error == nil) {
            transceiver.finishReceivingResource(myPeerID: myPeerID, resourceName: resourceName, fromPeer: peerID, atURL: localURL)
        }
    }
    
    public func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        certificateHandler(true)
    }
}
