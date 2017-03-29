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

@objc(Person)
class Person: NSManagedObject {
  @NSManaged var first: String
  @NSManaged var last: String
  @NSManaged var bio: String
  @NSManaged var twitter: String
  @NSManaged var identifier: String
  @NSManaged var active: Bool
  @NSManaged var sessions: Set<Session>

  var fullName: String {
    let locale = NSLocale.current
    return fullNameFor(locale.languageCode)
  }

  func fullNameFor(_ language: String?) -> String {
    if let language = language {
      if language == "zh" {
        return "\(last)\(first)"
      }
    }
    return "\(first) \(last)"
  }

  class func personByIdentifier(identifier: String, context: NSManagedObjectContext) -> Person? {
    let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Person")
    fetch.predicate = NSPredicate(format: "identifier = %@", argumentArray: [identifier])
    do {
      let results = try context.fetch(fetch)
      guard let result = results.first as? Person else { return nil }
      return result
    } catch {
      return nil
    }
  }

  class func personByIdentifierOrNew(identifier: String, context: NSManagedObjectContext) -> Person {
    return personByIdentifier(identifier: identifier, context: context) ?? Person(entity: NSEntityDescription.entity(forEntityName: "Person", in: context)!, insertInto: context)
  }
}
