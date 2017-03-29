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

@objc(Track)
class Track: NSManagedObject {
  @NSManaged var trackId: Int32
  @NSManaged var name: String
  @NSManaged var sessions: Set<Session>

  class func trackByTrackId(trackId: Int, context: NSManagedObjectContext) -> Track? {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Track")
    fetch.predicate = NSPredicate(format: "trackId = %@", argumentArray: [trackId])
    do {
      let results = try context.fetch(fetch)
      guard let result = results.first as? Track else { return nil }
      return result
    } catch {
      return nil
    }
  }

  class func trackByTrackIdOrNew(trackId: Int, context: NSManagedObjectContext) -> Track {
    return trackByTrackId(trackId: trackId, context: context) ?? Track(entity: NSEntityDescription.entity(forEntityName: "Track", in: context)!, insertInto: context)
  }
}
