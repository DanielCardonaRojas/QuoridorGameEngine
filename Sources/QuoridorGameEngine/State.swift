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
    public private(set) var playerBarriers: PlayerBarriers = [:]

    /// The tile positions in the game
    var barrierPositions: [BarrierPosition] = []

    // A history of all player positions throughout the game
    var playerPositions: [Player: [Position]] = [:]

    init(boardSize: Int = normalBoardSize, numberOfPlayers: Int = 2) {
      self.boardSize = boardSize
      self.numberOfPlayers = numberOfPlayers

      var index = 0

      for _ in 0..<numberOfPlayers {
        let increment = (QuoridorGameEngine.maxPlayers / numberOfPlayers)
        guard let boardSide = BoardSide(rawValue: index) else {
          break
        }
        let player = Player(side: boardSide)
        self.playerBarriers[player] = boardSize
        score[player] = .zero
        index = (index + increment) % QuoridorGameEngine.maxPlayers
      }
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
      var newPosition: Position = currentPosition

      switch direction {
      case .up:
        newPosition = currentPosition.moveUp()
      case .down:
        newPosition = currentPosition.moveDown()
      case .left:
        newPosition = currentPosition.moveLeft()
      case .right:
        newPosition = currentPosition.moveRight()
      }

      if direction != targetDirection(player) && outOfBounds(newPosition) {
        throw GameError.illegalMove
      }


      // Check: barrier blocks
      var isBlockedByBarrier = false

      let barriersContain = { [self] position in
        barrierPositions.contains(where: { barrier in
          return barrier.position == position || barrier.endPosition == position
        })
      }

      for barrier in barrierPositions {
        if isBlockedByBarrier {
          break
        }

        switch direction {
        case .up:
          isBlockedByBarrier = barrier.horizontal && barriersContain(currentPosition)
        case .down:
          isBlockedByBarrier = barrier.horizontal && barriersContain(newPosition)
        case .left:
          isBlockedByBarrier = barrier.vertical && barriersContain(newPosition)
        case .right:
          isBlockedByBarrier = barrier.vertical && barriersContain(currentPosition)
        }
      }

      guard !isBlockedByBarrier else {
        throw GameError.illegalMove
      }

      if playerWon(player: player, direction: direction, position: currentPosition) {
        end(winner: player)
        return
      }


      playerPositions[player, default: []].append(newPosition)
    }

    private func playerWon(player: Player, direction: Direction, position: Position) -> Bool {
      let targetDirection = targetDirection(player)
      switch player.side {
      case .top:
        return position.y == 1 && direction == targetDirection
      case .right:
        return position.x == 1 && direction == targetDirection
      case .left:
        return position.x == boardSize && direction == targetDirection
      case .bottom:
        return position.y == boardSize && direction == targetDirection
      }
    }

    private func targetDirection(_ player: Player) -> Direction {
      switch player.side {
      case .top:
        return .down
      case .right:
        return .left
      case .left:
        return .right
      case .bottom:
        return .up
      }
    }

    mutating func placeBarrier(player: Player, barrierPosition: BarrierPosition) throws {
      guard
        !barrierPositions.contains(where: { $0 == barrierPosition }),
        !outOfBounds(barrierPosition.position),
        !outOfBounds(barrierPosition.endPosition)
      else {
        throw GameError.illegalMove
      }

      playerBarriers[player, default: boardSize] -= 1
      barrierPositions.append(barrierPosition)
    }
    
    func outOfBounds(_ position: Position) -> Bool {
      position.x < 1 || position.x > boardSize || position.y < 1 || position.y > boardSize
    }

    mutating func end(winner: Player) {
      score[winner, default: 0] += 1
      reset()
    }

    mutating func reset() {
      turn = .init(side: .top)
      playerPositions = [:]
      
      var index = 0

      for playerIndex in 0..<numberOfPlayers {
        let increment = (QuoridorGameEngine.maxPlayers / numberOfPlayers)
        index = (index + increment) % QuoridorGameEngine.maxPlayers
        guard let boardSide = BoardSide(rawValue: playerIndex) else {
          break
        }
        let player = Player(side: boardSide)
        self.playerBarriers[player] = boardSize
      }
    }
  }
}
