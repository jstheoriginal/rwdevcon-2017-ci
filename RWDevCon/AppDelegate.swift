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
import UIKit
import CoreData
import Fabric
import Answers

// A date before the bundled plist date
private let beginningOfTimeDate = Date(timeIntervalSince1970: 1456876800) // 02-03-2016 12:00 AM

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  lazy var coreDataStack = CoreDataStack()

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {

    Fabric.with([Answers.self])

    AppDelegate.loadInitialData(coreDataStack: coreDataStack)

    // global style
    application.statusBarStyle = UIStatusBarStyle.lightContent
    UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17)!,
                                                         NSForegroundColorAttributeName: UIColor.white],
                                                        for: .normal)

    let splitViewController = self.window!.rootViewController as! UISplitViewController
    splitViewController.delegate = self

    let navigationController = splitViewController.viewControllers[0] as! UINavigationController
    (navigationController.topViewController as! ScheduleViewController).coreDataStack = coreDataStack

    let detailWrapperController = splitViewController.viewControllers[1] as! UINavigationController
    (detailWrapperController.topViewController as! SessionViewController).coreDataStack = coreDataStack

    return true
  }

  class func loadInitialData(coreDataStack: CoreDataStack) {
    guard let plist = Bundle.main.url(forResource: "RWDevCon2016", withExtension: "plist"),
      let data = NSDictionary(contentsOf: plist) as? [String: AnyObject] else {
        return
    }

    let localLastUpdateDate = Config.userDefaults().object(forKey: "lastUpdated") as? Date ?? beginningOfTimeDate
    let plistLastUpdateDate = beginningOfTimeDate
    if Session.sessionCount(context: coreDataStack.context) == 0
      || localLastUpdateDate.compare(plistLastUpdateDate) == .orderedAscending {
      loadDataFromDictionary(data: data, coreDataStack:coreDataStack)
    }
  }

  class func loadDataFromDictionary(data: [String: AnyObject], coreDataStack: CoreDataStack) {
    typealias PlistDict = [String: NSDictionary]
    typealias PlistArray = [NSDictionary]

    guard let metadata = data["metadata"] as? [String: AnyObject],
      let sessions: PlistDict = data["sessions"] as? PlistDict,
      let people: PlistDict = data["people"] as? PlistDict,
      let rooms: PlistArray = data["rooms"] as? PlistArray,
      let tracks: [String] = data["tracks"] as? [String] else {
        return
    }

    let lastUpdated = metadata["lastUpdated"] as? Date ?? beginningOfTimeDate
    Config.userDefaults().set(lastUpdated, forKey: "lastUpdated")

    var allRooms = [Room]()
    var allTracks = [Track]()
    var allPeople = [String: Person]()

    for (identifier, dict) in rooms.enumerated() {
      let room = Room.roomByRoomIdOrNew(roomId: identifier, context: coreDataStack.context)

      room.roomId = Int32(identifier)
      room.name = dict["name"] as? String ?? ""
      room.image = dict["image"] as? String ?? ""
      room.roomDescription = dict["roomDescription"] as? String ?? ""
      room.mapAddress = dict["mapAddress"] as? String ?? ""
      room.mapLatitude = dict["mapLatitude"] as? Double ?? 0
      room.mapLongitude = dict["mapLongitude"] as? Double ?? 0

      allRooms.append(room)
    }

    for (identifier, name) in tracks.enumerated() {
      let track = Track.trackByTrackIdOrNew(trackId: identifier, context: coreDataStack.context)

      track.trackId = Int32(identifier)
      track.name = name

      allTracks.append(track)
    }

    for (identifier, dict) in people {
      let person = Person.personByIdentifierOrNew(identifier: identifier, context: coreDataStack.context)

      person.identifier = identifier
      person.first = dict["first"] as? String ?? ""
      person.last = dict["last"] as? String ?? ""
      person.active = dict["active"] as? Bool ?? false
      person.twitter = dict["twitter"] as? String ?? ""
      person.bio = dict["bio"] as? String ?? ""

      allPeople[identifier] = person
    }

    for (identifier, dict) in sessions {
      let session = Session.sessionByIdentifierOrNew(identifier: identifier, context: coreDataStack.context)

      session.identifier = identifier
      session.active = dict["active"] as? Bool ?? false
      session.date = dict["date"] as? Date ?? beginningOfTimeDate
      session.duration = Int32(dict["duration"] as? Int ?? 0)
      session.column = Int32(dict["column"] as? Int ?? 0)
      session.sessionNumber = dict["sessionNumber"] as? String ?? ""
      session.sessionDescription = dict["sessionDescription"] as? String ?? ""
      session.title = dict["title"] as? String ?? ""

      session.track = allTracks[dict["trackId"] as! Int]
      session.room = allRooms[dict["roomId"] as! Int]

      var presenters = [Person]()
      if let rawPresenters = dict["presenters"] as? [String] {
        for presenter in rawPresenters {
          if let person = allPeople[presenter] {
            presenters.append(person)
          }
        }
      }
      session.presenters = NSOrderedSet(array: presenters)
    }

    coreDataStack.saveContext()

    NotificationCenter.default.post(name: NSNotification.Name(rawValue: SessionDataUpdatedNotification), object: self)
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    coreDataStack.saveContext()
  }
}

// MARK: - UISplitViewControllerDelegate
extension AppDelegate: UISplitViewControllerDelegate {

  func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
    if let secondaryAsNavController = secondaryViewController as? UINavigationController {
      if let topAsDetailController = secondaryAsNavController.topViewController as? SessionViewController {
        if topAsDetailController.session == nil {
          // Return true to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
          return true
        }
      }
    }
    return false
  }
}
