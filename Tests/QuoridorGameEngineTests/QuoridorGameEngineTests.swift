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
  func testInitialScoreIsZeroForAllPlayers() {
    XCTAssert(sut.state.score.values.reduce(true, { acc, score in acc && score == .zero }))
    XCTAssertFalse(sut.state.score.values.isEmpty)
  }

  func testInitialBarrierCountForEachPlayerIsEqual() { // All players have the same amount of barriers
    XCTAssert(sut.state.playerBarriers.values.reduce(true, { acc, count in acc && count == sut.state.boardSize }))
    XCTAssertFalse(sut.state.playerBarriers.values.isEmpty)
  }

  func testCannotPlaceBarrierAtBoardSize() { // There are N - 1 barrier slots

  }

  func testJumpsPlayerIfHasContiguousPlayerInTheDirectionOfMovement() {
    // check that doesn't accidentally jump a barrier

  }

  func testResetsStateWhenPlayerWins() {

  }

  func testIncrementsScoreWhenPlayerWins() throws {
    for _ in 1...sut.state.boardSize {
      try sut.handleEvent(player: player1, event: .move(direction: .down))
      try sut.handleEvent(player: player2, event: .move(direction: .up))
    }

    XCTAssertEqual(sut.state.score[player1], 1, "Player 1 scores 1")
    XCTAssertEqual(sut.state.score[player2], 0, "Player 2 scores 0")

  }

  func testInitialPlayerPositions() {

  }

  func testReducesPlayerBarriersWhenPlacesOne() throws {
    let initialCount = try XCTUnwrap(sut.state.playerBarriers[player1])
    XCTAssert(initialCount > 0, "Has available barriers")
    try sut.handleEvent(player: player1, event: .placeBarrier(position: .init(position: .init(x: 1, y: 1), vertical: false)))
    let finalCount = try XCTUnwrap(sut.state.playerBarriers[player1])
    XCTAssertEqual(finalCount, initialCount - 1, "Reduces barrier count by one")
  }

  func testCannotPlaceBarrierThatCompletelyBlockOtherPlayers() {
    // This is the hardest to test in the general case
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
