//
//  ContentView.swift
//  BioBlit
//
//  Created by Damian Wiśniewski on 09/01/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var board = GameBoard()
    
    var body: some View {
        VStack {
            HStack {
                Text("GREEN: \(board.greenScore)")
                    .padding(.horizontal)
                    .background(Capsule().fill(.green).opacity(board.currentPlayer.color == .green ? 1 : 0))
                
                Spacer()
                
                Text("BIOBLITZ")
                
                Spacer()
                
                Text("RED: \(board.redScore)")
                    .padding(.horizontal)
                    .background(Capsule().fill(.red).opacity(board.currentPlayer.color == .red ? 1 : 0))

            }
            .font(.system(size: 36).weight(.bold))
            
            ZStack {
                VStack {
                    ForEach(0..<11, id: \.self) { row in
                        HStack {
                            ForEach(0..<22, id: \.self) { col in
                                let bacteria = board.board.grid[row][col]
                                
                                BacteriaView(bacteria: bacteria) {
                                    if board.currentPlayer.color == .green {
                                        board.rotate(bacteria: bacteria)
                                    }
                                }
                            }
                        }
                    }
                }
                
                if let winner = board.winner {
                    VStack {
                        Text("\(winner.color == .green ? "Green" : "Red") wins!")
                            .font(.largeTitle)
                        
                        Button(action: board.reset) {
                            Text("Play Again")
                                .padding()
                                .background(.blue)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(40)
                    .background(.black.opacity(0.85))
                    .cornerRadius(25)
                    .transition(.scale)
                }
            }
        }
        .padding()
        .fixedSize()
        .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
