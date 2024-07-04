//
//  File.swift
//  
//
//  Created by Daniel Cardona on 4/07/24.
//

import XCTest
@testable import QuoridorGameEngine

final class CodableTests: XCTestCase {

  func testCanDecodeChangeTurnEvent() throws {
    let jsonString = """
    {
      "eventKind": "changeTurn",
    }
    """

    let data = jsonString.data(using: .utf8)!
    let moveEvent = try JSONDecoder().decode(QuoridorGameEngine.Event.self, from: data)

    XCTAssertEqual(moveEvent, .changeTurn)
  }

  func testCanDecodeMoveEvent() throws {
    let jsonString = """
    {
      "eventKind": "move",
      "payload": "up"
    }
    """

    let data = jsonString.data(using: .utf8)!
    let moveEvent = try JSONDecoder().decode(QuoridorGameEngine.Event.self, from: data)

    XCTAssertEqual(moveEvent, .move(direction: .up))
  }
  
  func testCanDecodePlaceBarrierEvent() throws {
    let jsonString = """
    {
      "eventKind": "placeBarrier",
      "payload": {
        "position": { "x": 1, "y": 1 },
        "vertical": true
      }
    }
    """

    let data = jsonString.data(using: .utf8)!
    let barrierEvent = try JSONDecoder().decode(QuoridorGameEngine.Event.self, from: data)

    XCTAssertEqual(barrierEvent, .placeBarrier(position: .vertical(x: 1, y: 1)))
  }

  func testCanEncodeEventToJson() throws {
    let event = QuoridorGameEngine.Event.move(direction: .up)
    let data = try JSONEncoder().encode(event)
    let decoded = try JSONDecoder().decode(QuoridorGameEngine.Event.self, from: data)
    XCTAssertEqual(event, decoded, "Should decode encoded event and be equal")
  }
}

