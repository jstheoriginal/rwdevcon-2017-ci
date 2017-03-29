/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import XCTest
@testable import RWDevCon

class SessionWithStartDateTimeString: SessionDateFormattable {
  init(startDateTimeString: String) {
    self.startDateTimeString = startDateTimeString;
  }

  let startDateDayOfWeek = ""
  let startDateTimeString: String
  let startTimeString = ""
}

class PropertyRecordingSession: SessionDateFormattable {
  var _startDateDayOfWeekCount = 0
  var _startTimeStringCount = 0

  var startDateDayOfWeek: String {
    _startDateDayOfWeekCount += 1
    return ""
  }
  var startDateTimeString: String {
    _startTimeStringCount += 1
    return ""
  }
  let startTimeString = ""
}

class ScheduleDataSourceTests: XCTestCase {

  func testDistinctTimes() {
    var sessions = [SessionDateFormattable]()
    sessions.append(SessionWithStartDateTimeString(
      startDateTimeString: "1"))
    XCTAssertEqual(ScheduleDataSource.distinctTimes(
      for: sessions, favoritesOnly:false).count, 1)

    sessions.append(SessionWithStartDateTimeString(
      startDateTimeString: "1"))
    XCTAssertEqual(ScheduleDataSource.distinctTimes(
      for: sessions, favoritesOnly:false).count, 1)

    sessions.append(SessionWithStartDateTimeString(
      startDateTimeString: "2"))
    XCTAssertEqual(ScheduleDataSource.distinctTimes(
      for: sessions, favoritesOnly:false).count, 2)

    sessions.append(SessionWithStartDateTimeString(
      startDateTimeString: "3"))
    XCTAssertEqual(ScheduleDataSource.distinctTimes(
      for: sessions, favoritesOnly:false).count, 3)

    sessions.append(SessionWithStartDateTimeString(
      startDateTimeString: "3"))
    XCTAssertEqual(ScheduleDataSource.distinctTimes(
      for: sessions, favoritesOnly:false).count, 3)
  }

  func testDistinctTimesUsesCorrectTimeString() {
    let session = PropertyRecordingSession()
    let _ = ScheduleDataSource.distinctTimes(
      for: [session], favoritesOnly:false)
    XCTAssertEqual(session._startTimeStringCount, 1)
    XCTAssertEqual(session._startDateDayOfWeekCount, 0)

    let session2 = PropertyRecordingSession()
    let _ = ScheduleDataSource.distinctTimes(
      for: [session2], favoritesOnly:true)
    XCTAssertEqual(session2._startTimeStringCount, 0)
    XCTAssertEqual(session2._startDateDayOfWeekCount, 1)
  }

}
