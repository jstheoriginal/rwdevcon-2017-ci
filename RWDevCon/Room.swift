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

import Foundation
import CoreData

@objc(Room)
class Room: NSManagedObject {
  @NSManaged var roomId: Int32
  @NSManaged var name: String
  @NSManaged var roomDescription: String
  @NSManaged var sessions: Set<Session>
  @NSManaged var image: String
  @NSManaged var mapAddress: String
  @NSManaged var mapLatitude: Double
  @NSManaged var mapLongitude: Double

  class func roomByRoomId(roomId: Int, context: NSManagedObjectContext) -> Room? {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Room")
    fetch.predicate = NSPredicate(format: "roomId = %@", argumentArray: [roomId])
    do {
      let results = try context.fetch(fetch)
      guard let result = results.first as? Room else { return nil }
      return result
    } catch {
      return nil
    }
  }

  class func roomByRoomIdOrNew(roomId: Int, context: NSManagedObjectContext) -> Room {
    return roomByRoomId(roomId: roomId, context: context) ?? Room(entity: NSEntityDescription.entity(forEntityName: "Room", in: context)!, insertInto: context)
  }
}
