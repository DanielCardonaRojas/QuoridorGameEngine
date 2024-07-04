import Foundation

public class QuoridorGameEngine {
  // 9 x 9 board
  public static let normalBoardSize = 9
  public static let maxPlayers = 4

  public typealias Score = [Player: Int]
  public typealias PlayerBarriers = [Player: Int]

  public enum BoardSide: Int, Equatable, CaseIterable {
    case top = 0, right = 1, bottom = 2, left = 3
  }

  public struct Player: Hashable, CustomStringConvertible {
    let side: BoardSide

    public var description: String {
      "Player \(side)"
    }
  }

  public enum Event: CustomStringConvertible {
    public var description: String {
      switch self {
      case .move(let direction):
        return "Move \(direction)"
      case .placeBarrier(let position):
        return "PlaceBarrier \(position.position) \(position.endPosition)"
      case .changeTurn:
        return "Change turn"
      }
    }

    case move(direction: Direction) // Move or jump
    case placeBarrier(position: BarrierPosition)
    case changeTurn
  }


  // Since tile position are the lines in the board grid this should be constrained by boardSize - 1
  // Tiles are 2 x 1
  public struct BarrierPosition: Equatable {
    public let position: Position
    public let vertical: Bool

    public var horizontal: Bool {
      !vertical
    }

    public var endPosition: Position {
      Position(x: vertical ? position.x : position.x + 1, y: vertical ? position.y + 1 : position.y)
    }

    static func horizontal(x: Int, y: Int) -> Self {
      BarrierPosition(position: Position(x: x, y: y), vertical: false)
    }

    static func vertical(x: Int, y: Int) -> Self {
      BarrierPosition(position: Position(x: x, y: y), vertical: true)
    }
  }

  public enum GameError: Error, Equatable {
    case illegalMove
    case notTurn
  }

  public enum Direction {
    case up
    case down
    case left
    case right
  }

  // MARK: Properties
  var state: State

  /// Allows time travel and can be used to rebuild state in disconnected clients
  var history: [(Player, Event)] = []

  public var eventLogger: ((Player, Event, State) -> Void)?

  public init(boardSize: Int = normalBoardSize, numberOfPlayers: Int = 2) {
    state = State(boardSize: boardSize, numberOfPlayers: numberOfPlayers)
  }

  // MARK: Methods
  @discardableResult
  public func handleEvent(player: Player, event: Event) throws -> State {
    guard state.turn == player else {
      throw GameError.notTurn
    }

    switch event {
    case .move(let direction):
      try state.move(player: player, direction: direction)
    case .placeBarrier(position: let barrierPosition):
      try state.placeBarrier(player: player, barrierPosition: barrierPosition)
    case .changeTurn:
      state.advanceTurn()
    }

    history.append((player, event))
    eventLogger?(player, event, state)
    return state
  }

}

