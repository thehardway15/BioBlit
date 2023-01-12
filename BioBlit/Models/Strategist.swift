//
//  Strategist.swift
//  BioBlit
//
//  Created by Damian Wiśniewski on 12/01/2023.
//

import GameplayKit

struct Strategist {
    private let strategist: GKMinmaxStrategist = {
        let strategist = GKMinmaxStrategist()
        
        strategist.maxLookAheadDepth = 4
        strategist.randomSource = GKARC4RandomSource()
        return strategist
    }()
    
    var board: Board {
        didSet {
            strategist.gameModel = board
        }
    }
    
    var bestMove: Bacteria? {
        if let move = strategist.bestMove(for: board.currentPlayer) as? Move {
            return move.bacteria
        }
        
        return nil
    }
}
