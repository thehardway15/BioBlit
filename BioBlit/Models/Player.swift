//
//  Player.swift
//  BioBlit
//
//  Created by Damian Wiśniewski on 10/01/2023.
//

import GameplayKit
import SwiftUI

enum PlayerColor: Int {
    case green = 0, red
}

class Player: NSObject, GKGameModelPlayer {
    var playerId: Int
    var color: Color
    static var allPlayers: [Player] = [Player(.green), Player(.red)]
    
    init(_ playerId: PlayerColor) {
        self.playerId = playerId.rawValue
        self.color = playerId.rawValue == 0 ? .green : .red
    }
    
    var oponent: Player {
        if color == .green {
            return Player.allPlayers[1]
        } else {
            return Player.allPlayers[0]
        }
    }
}
