//
//  File.swift
//  
//
//  Created by Daniel Cardona on 4/07/24.
//

import Foundation

extension QuoridorGameEngine {
  public enum Event: CustomStringConvertible, Codable, Equatable {

    public enum Kind: String, Equatable, Codable {
      case move
      case placeBarrier
      case changeTurn
    }
    
    case move(direction: Direction) // Move or jump
    case placeBarrier(position: BarrierPosition)
    case changeTurn


    enum CodingKeys: String, CodingKey {
      case payload, eventKind
    }

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

    public init(from decoder: Decoder) throws {
      let container = try decoder.container(keyedBy: CodingKeys.self)
      let eventKind = try container.decode(Event.Kind.self, forKey: .eventKind)

      switch eventKind {
      case .move:
        let direction = try container.decode(Direction.self, forKey: .payload)
        self = .move(direction: direction)
      case .placeBarrier:
        let position = try container.decode(BarrierPosition.self, forKey: .payload)
        self = .placeBarrier(position: position)
      case .changeTurn:
        self = .changeTurn
      }
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      switch self {
      case .move(let direction):
        try container.encode(Event.Kind.move, forKey: .eventKind)
        try container.encode(direction, forKey: .payload)
      case .placeBarrier(let position):
        try container.encode(Event.Kind.placeBarrier, forKey: .eventKind)
        try container.encode(position, forKey: .payload)
      case .changeTurn:
        try container.encode(Event.Kind.changeTurn, forKey: .eventKind)
      }
    }
  }
}
