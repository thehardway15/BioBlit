//
//  GameBoard.swift
//  BioBlit
//
//  Created by Damian Wiśniewski on 09/01/2023.
//

import SwiftUI

class GameBoard: ObservableObject {
    let rowCount = 11
    let columnCount = 22
    
    var board: Board!
    
    var strategist: Strategist!
    
    @Published var currentPlayer: Player = Player.allPlayers.first!
    @Published var greenScore = 1
    @Published var redScore = 1
    
    @Published var winner: Player? = nil
    
    private var bacteriaBeingInfected = 0
    
    init() {
        board = Board()
        reset()
    }
    
    func reset() {
        strategist = Strategist(board: board)
        board.reset()
        
        strategist.board = board
        
        winner = board.winner
        currentPlayer = board.currentPlayer
        
        redScore = 1
        greenScore = 1
    }
    
    func infect(from bacteria: Bacteria) {
        objectWillChange.send()
        
        board.infect(from: bacteria)
        
        updateScores()
    }
    
    func rotate(bacteria: Bacteria) {
        guard bacteria.color == currentPlayer.color else { return }
        guard bacteriaBeingInfected == 0 else { return }
        guard winner == nil else { return }
        
        objectWillChange.send()
        
        bacteria.direction = bacteria.direction.next
        infect(from: bacteria)
    }
    
    func changePlayer() {
        board.changePlayer()
        currentPlayer = board.currentPlayer
    }
    
    func updateScores() {
        var newRedScore = 0
        var newGreenScore = 0
        
        for row in board.grid {
            for bacteria in row {
                if bacteria.color == .red {
                    newRedScore += 1
                } else if bacteria.color == .green {
                    newGreenScore += 1
                }
            }
        }
        
        redScore = newRedScore
        greenScore = newGreenScore
        
        if bacteriaBeingInfected == 0 {
            winner = board.winningPlayer
            
            withAnimation(.spring()) {
                if winner == nil {
                    changePlayer()
                }
            }
        }
        
        if board.currentPlayer.color == .red {
            processAIMove()
        }
    }
    
    func processAIMove() {
        DispatchQueue.global().async {
            let strategistTime = CFAbsoluteTime()
            guard let bestMove = self.strategist.bestMove else {
                return
            }
            
            let delta = CFAbsoluteTime() - strategistTime
            let aiTimeCeiling = 0.75
            let delay = max(delta, aiTimeCeiling)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let bacteria = self.board.getBacteria(atRow: bestMove.row, col: bestMove.col)!
                self.rotate(bacteria: bacteria)
            }
        }
    }
}
