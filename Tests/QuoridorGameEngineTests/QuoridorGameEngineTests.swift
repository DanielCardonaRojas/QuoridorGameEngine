import XCTest
@testable import QuoridorGameEngine

final class QuoridorGameEngineTests: XCTestCase {
  var sut: QuoridorGameEngine!
  let player1 = QuoridorGameEngine.Player(side: .top)
  let player2 = QuoridorGameEngine.Player(side: .bottom)

  override func setUp() {
    sut = QuoridorGameEngine()
  }

  func testThrowsErrorWhenAttemptingToPlayInOtherPlayersTurn() {
    let result = Result {
      try sut.handleEvent(player: player2, event: .move(direction: .up))
    }

    XCTAssert(result.isErrorMatching(.notTurn))
  }

  func testThrowsErrorWhenAttemptingToMoveOutsideBoundsOfBoard() {
    let result = Result {
      try sut.handleEvent(player: player1, event: .move(direction: .up))
    }

    XCTAssert(result.isErrorMatching(.illegalMove))
  }

  func testThrowsErrorWhenAttemptingToPlaceBarrieBeyondBoardBounds() {
    let xPositions = [0, sut.state.boardSize]

    for position in xPositions {
      let event = QuoridorGameEngine.Event.placeBarrier(position: .init(position: .init(x: position, y: 1), vertical: false))

      let result = Result {
        try sut.handleEvent(player: player1, event: event)
      }

      XCTAssert(result.isErrorMatching(.illegalMove))
    }
  }

  func testThrowsErrorWhenMovingInDirectionOfBarrier()  {
    let result = Result {
      try sut.handleEvent(player: player1 , event: .placeBarrier(position: .init(position: .init(x: 5, y: 1), vertical: false)))
      try sut.handleEvent(player: player2, event: .move(direction: .up))
    }

    XCTAssert(result.isErrorMatching(.illegalMove))
  }

  // TODO: Add test
  func testCannotPlaceBarrierAtBoardSize() { // There are N - 1 barrier slots

  }

  func testJumpsPlayerIfHasContiguousPlayerInTheDirectionOfMovement() {
    // check that doesn't accidentally jump a barrier

  }

  func testResetsStateWhenPlayerWins() {

  }

  func testIncrementsScoreWhenPlayerWins() {

  }

  func testInitialPlayerPositions() {

  }

  func testCannotPlaceBarrierThatCompletelyBlockOtherPlayers() {
    // This is the hardest to test
  }
}

extension Result  {
  func isErrorMatching(_ gameError: QuoridorGameEngine.GameError) -> Bool {
    if case .failure(let error) = self, let converted = error as? QuoridorGameEngine.GameError, converted == gameError {
      return true
    }

    return false
  }

}
