//
//  State.swift
//  
//
//  Created by Daniel Cardona on 3/07/24.
//

import Foundation

extension QuoridorGameEngine {
  public struct State: Equatable {
    public private(set) var boardSize: Int
    public private(set) var numberOfPlayers: Int
    public private(set) var turn: Player = .init(side: .top)
    public private(set) var score: Score = [:]
    public private(set) var tileCount: TileCount = [:]

    /// The tile positions in the game
    var barrierPositions: [BarrierPosition] = []

    // A history of all player positions throughout the game
    var playerPositions: [Player: [Position]] = [:]

    init(boardSize: Int = normalBoardSize, numberOfPlayers: Int = 2) {
      self.boardSize = boardSize
      self.numberOfPlayers = numberOfPlayers
    }


    /// Move turn to the next player
    mutating func advanceTurn() {
      let increment = (QuoridorGameEngine.maxPlayers / numberOfPlayers)
      let nextTurnIndex = (turn.side.rawValue + increment) % QuoridorGameEngine.maxPlayers
      guard let newTurnSide = BoardSide(rawValue: nextTurnIndex)  else {
        fatalError("This should never happen")
      }
      self.turn = Player(side: newTurnSide)
    }

    mutating func move(player: Player, direction: Direction) throws {
      let currentPosition = playerPositions[player]?.last ?? Position.initial(forPlayer: player, boardSize: boardSize)
      let nextPosition = try currentPosition.move(direction: direction, boardSize: boardSize, barriers: barrierPositions)
      playerPositions[player, default: []].append(nextPosition)
    }

    mutating func move(player: Player, barrierPosition: BarrierPosition) throws {
      guard
        !barrierPositions.contains(where: { $0 == barrierPosition }),
        !barrierPosition.position.outOfBounds(boardSize: boardSize),
        !barrierPosition.endPosition.outOfBounds(boardSize: boardSize)
      else {
        throw GameError.illegalMove
      }
      barrierPositions.append(barrierPosition)
    }

    mutating func end(winner: Player) {
      score[winner, default: 0] += 1
    }

    mutating func reset() {
      turn = .init(side: .top)
      score = [:]
      tileCount = [:]
    }
  }
}
