//
//  Move.swift
//  BioBlit
//
//  Created by Damian Wiśniewski on 12/01/2023.
//

import GameplayKit

class Move: NSObject, GKGameModelUpdate {
    var value: Int = 0
    
    var bacteria: Bacteria
    
    init(_ bacteria: Bacteria) {
        self.bacteria = bacteria
    }
    
}
