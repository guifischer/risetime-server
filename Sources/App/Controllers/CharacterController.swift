//
//  CharacterController.swift
//  App
//
//  Created by Guilherme Fischer on 15/06/2018.
//

import Foundation
import Vapor

final class CharacterController {
    
    private var drop: Application!
    
    init(drop: Application) {
        self.drop = drop
        setupSockets()
    }
    
    private func setupSockets() {
//        let ws = HTTPServer.webSocketUpgrader(shouldUpgrade: { req in
//            // return non-nil HTTPHeaders to allow upgrade
//        }, onUpgrade: { ws, req in
//            // setup callbacks or send data to connected WebSocket
//        })
//
//        HTTPServer.start(hostname: "localhost", port: 8080, upgraders: [ws])
    }
}
