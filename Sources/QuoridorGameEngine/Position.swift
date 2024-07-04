//
//  Position.swift
//  
//
//  Created by Daniel Cardona on 3/07/24.
//

import Foundation

extension QuoridorGameEngine {
  public struct Position: Equatable, CustomStringConvertible, Codable {
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

  }
}
