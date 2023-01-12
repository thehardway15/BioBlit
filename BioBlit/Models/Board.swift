//
//  Board.swift
//  BioBlit
//
//  Created by Damian Wiśniewski on 10/01/2023.
//

import GameplayKit

class Board: NSObject {
    private let rowCount = 11
    private let columnCount = 22
    
    public var grid = [[Bacteria]]()
    
    public var currentPlayer: Player = Player.allPlayers.first!
    
    public var winner: Player? = nil
    
    override init() {
        super.init()
        reset()
    }
    
    func reset() {
        winner = nil
        currentPlayer = Player.allPlayers.first!
        
        grid.removeAll()
        
        for row in 0..<rowCount {
            var newRow = [Bacteria]()
            
            for col in 0..<columnCount {
                let bacteria = Bacteria(row: row, col: col)
                
                if row <= rowCount / 2 {
                    if row == 0 && col == 0 {
                        // make sure the player starts pointing away from anything
                        bacteria.direction = .north
                    } else if row == 0 && col == 1 {
                        // make sure nothing points to the player
                        bacteria.direction = .east
                    } else if row == 1 && col == 0 {
                        bacteria.direction = .south
                    } else {
                        // all other pieces are random
                        bacteria.direction = Bacteria.Direction.allCases.randomElement()!
                    }
                } else {
                    // mirror the counterpart
                    if let counterPart = getBacteria(atRow: rowCount - 1 - row, col: columnCount - 1 - col) {
                        bacteria.direction = counterPart.direction.opposite
                    }
                }
                
                newRow.append(bacteria)
            }
            
            grid.append(newRow)
        }
        
        grid[0][0].color = .green
        grid[rowCount - 1][columnCount - 1].color = .red
    }
    
    func getBacteria(atRow row: Int, col: Int) -> Bacteria? {
        guard row >= 0 else { return nil }
        guard row < grid.count else { return nil }
        guard col >= 0 else { return nil }
        guard col < grid[0].count else { return nil }
        return grid[row][col]
    }
    
    func rotate(bacteria: Bacteria) {
        bacteria.direction = bacteria.direction.next
        infect(from: bacteria)
    }
    
    func infect(from: Bacteria) {
        var bacteriaToInfect = [Bacteria?]()
        
        // direct infection
        switch from.direction {
        case .north: bacteriaToInfect.append(getBacteria(atRow: from.row - 1, col: from.col))
        case .south: bacteriaToInfect.append(getBacteria(atRow: from.row + 1, col: from.col))
        case .east: bacteriaToInfect.append(getBacteria(atRow: from.row, col: from.col + 1))
        case .west: bacteriaToInfect.append(getBacteria(atRow: from.row, col: from.col - 1))
        }
        
        // indirect infection from above
        if let indirect = getBacteria(atRow: from.row - 1, col: from.col) {
            if indirect.direction == .south {
                bacteriaToInfect.append(indirect)
            }
        }
        
        // indirect infection from below
        if let indirect = getBacteria(atRow: from.row + 1, col: from.col) {
            if indirect.direction == .north {
                bacteriaToInfect.append(indirect)
            }
        }
        
        // indirect infection from left
        if let indirect = getBacteria(atRow: from.row, col: from.col - 1) {
            if indirect.direction == .east {
                bacteriaToInfect.append(indirect)
            }
        }
        
        // indirect infection from right
        if let indirect = getBacteria(atRow: from.row, col: from.col + 1) {
            if indirect.direction == .west {
                bacteriaToInfect.append(indirect)
            }
        }
        
        for case let bacteria? in bacteriaToInfect {
            if bacteria.color != from.color {
                bacteria.color = from.color
                
                infect(from: bacteria)
            }
            
        }
    }
    
    func changePlayer() {
        currentPlayer = currentPlayer.oponent
    }
    
    func calculateScore() -> (Int, Int) {
        var redBlock = 0
        var greenBlock = 0
        
        for row in grid {
            for bacteria in row {
                if bacteria.color == .red {
                    redBlock += 1
                } else if bacteria.color == .green {
                    greenBlock += 1
                }
            }
        }
        
        return (greenBlock, redBlock)
    }
    
    var winningPlayer: Player? {
        
        let (greenBlock, redBlock) = calculateScore()
        
        if redBlock == 0 {
            return Player.allPlayers[0]
        } else if greenBlock == 0 {
            return Player.allPlayers[1]
        } else {
            return nil
        }
    }
}

extension Board: GKGameModel {
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
    
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            grid.removeAll()
            for row in 0..<rowCount {
                var newRow = [Bacteria]()
                
                for col in 0..<columnCount {
                    let bacteria = Bacteria(row: row, col: col)
                    bacteria.color = board.getBacteria(atRow: row, col: col)!.color
                    bacteria.direction = board.getBacteria(atRow: row, col: col)!.direction
                    newRow.append(bacteria)
                }
                grid.append(newRow)
            }
        }
    }
    
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }
    
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        guard let player = player as? Player else {
            return false
        }
        
        if let winner = winningPlayer {
            return player == winner
        } else {
            return false
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        guard let player = player as? Player else {
            return nil
        }
        
        if isWin(for: player) {
            return nil
        }
        
        var moves = [Move]()
        
        for row in grid {
            for bacteria in row {
                if bacteria.color == player.color {
                    var bacteriaToInfect = [Bacteria?]()
                    let from = Bacteria(row: bacteria.row, col: bacteria.col)
                    from.color = bacteria.color
                    from.direction = bacteria.direction.next
                    // direct infection
                    if from.direction == .north {
                        if let direct = getBacteria(atRow: from.row - 1, col: from.col) {
                            if direct.color != bacteria.color {
                                bacteriaToInfect.append(direct)
                            }
                        }
                    }
                    
                    if from.direction == .south {
                        if let direct = getBacteria(atRow: from.row + 1, col: from.col) {
                            if direct.color != bacteria.color {
                                bacteriaToInfect.append(direct)
                            }
                        }
                    }
                    
                    if from.direction == .east {
                        if let direct = getBacteria(atRow: from.row, col: from.col + 1) {
                            if direct.color != bacteria.color {
                                bacteriaToInfect.append(direct)
                            }
                        }
                    }
                    
                    if from.direction == .west {
                        if let direct = getBacteria(atRow: from.row, col: from.col - 1) {
                            if direct.color != bacteria.color {
                                bacteriaToInfect.append(direct)
                            }
                        }
                    }
                    
                    // indirect infection from above
                    if let indirect = getBacteria(atRow: from.row - 1, col: from.col) {
                        if indirect.color != bacteria.color && indirect.direction == .south {
                            bacteriaToInfect.append(indirect)
                        }
                    }
                    
                    // indirect infection from below
                    if let indirect = getBacteria(atRow: from.row + 1, col: from.col) {
                        if indirect.color != bacteria.color && indirect.direction == .north {
                            bacteriaToInfect.append(indirect)
                        }
                    }
                    
                    // indirect infection from left
                    if let indirect = getBacteria(atRow: from.row, col: from.col - 1) {
                        if indirect.color != bacteria.color && indirect.direction == .east {
                            bacteriaToInfect.append(indirect)
                        }
                    }
                    
                    // indirect infection from right
                    if let indirect = getBacteria(atRow: from.row, col: from.col + 1) {
                        if indirect.color != bacteria.color && indirect.direction == .west {
                            bacteriaToInfect.append(indirect)
                        }
                    }
                    
                    if bacteriaToInfect.count > 0 {
                        moves.append(Move(bacteria))
                    }
                }
            }
        }
        
        if moves.count == 0 {
            for row in grid {
                for bacteria in row {
                    if bacteria.color == player.color {
                        moves.append(Move(bacteria))
                    }
                }
            }
        }
        
        if moves.count > 30 {
            moves = Array(moves.shuffled().prefix(upTo: 20))
        }
        
        return moves
    }
    
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        guard let move = gameModelUpdate as? Move else {
            return
        }
        
        let bacteria = getBacteria(atRow: move.bacteria.row, col: move.bacteria.col)!
        
        rotate(bacteria: bacteria)
        currentPlayer = currentPlayer.oponent
    }
    
    func score(for player: GKGameModelPlayer) -> Int {
        guard let player = player as? Player else {
            return 0
        }
        
        let (greenBlock, redBlock) = calculateScore()
        
        if greenBlock == 0 && player.color == .red {
            return 1000
        }
        
        if redBlock == 0 && player.color == .green {
            return 1000
        }
        
        if player.color == .green {
            return greenBlock
        } else if player.color == .red {
            return redBlock
        } else {
            return 0
        }
    }
}
