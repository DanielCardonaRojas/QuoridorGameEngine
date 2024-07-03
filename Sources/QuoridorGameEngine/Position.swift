//
//  Position.swift
//  
//
//  Created by Daniel Cardona on 3/07/24.
//

import Foundation

extension QuoridorGameEngine {
  public struct Position: Equatable, CustomStringConvertible {
    let x: Int
    let y: Int

    public var description: String {
      "(\(x), \(y))"
    }

    func moveLeft() -> Position {
      Position(x: x - 1, y: y)
    }

    func moveRight() -> Position {
      Position(x: x + 1, y: y)
    }

    func moveUp() -> Position {
      Position(x: x, y: y + 1)
    }

    func moveDown() -> Position {
      Position(x: x, y: y - 1)
    }

    static func initial(forPlayer player: Player, boardSize: Int) -> Position {
      let middlePosition = (boardSize + 1) / 2
      switch player.side {
      case .top:
        return Position(x: middlePosition, y: boardSize)
      case .right:
        return Position(x: boardSize, y: middlePosition)
      case .bottom:
        return Position(x: middlePosition, y: 1)
      case .left:
        return Position(x: 1, y: middlePosition)
      }
    }

    func outOfBounds(boardSize: Int) -> Bool {
      x < 1 || x > boardSize || y < 1 || y > boardSize
    }

    func move(direction: Direction, boardSize: Int, barriers: [BarrierPosition]) throws -> Position {
      var newPosition: Position = self
      switch direction {
      case .up:
        newPosition = moveUp()
      case .down:
        newPosition = moveDown()
      case .left:
        newPosition = moveLeft()
      case .right:
        newPosition = moveRight()
      }

      if newPosition.outOfBounds(boardSize: boardSize) {
        throw GameError.illegalMove
      }

      let isBlockedByBarrier = barriers.contains(where: { tile in
        switch direction {
        case .up:
          tile.horizontal && barriers.contains(where: { $0.position == self || $0.endPosition == self })
        case .down:
          tile.horizontal && barriers.contains(where: { $0.position == newPosition || $0.endPosition == newPosition })
        case .left:
          tile.vertical && barriers.contains(where: { $0.position == newPosition || $0.endPosition == newPosition })
        case .right:
          tile.vertical && barriers.contains(where: { $0.position == self || $0.endPosition == self })
        }

      })

      guard !isBlockedByBarrier else {
        throw GameError.illegalMove
      }


      return newPosition
    }
  }
}
