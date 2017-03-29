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

let MyScheduleSomethingChangedNotification = "com.razeware.rwdevcon.notifications.myScheduleChanged"

class SessionViewController: UITableViewController {

  // MARK: - Properties
  var coreDataStack: CoreDataStack!
  var session: Session?

  struct Sections {
    static let info = 0
    static let description = 1
    static let presenters = 2
  }

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    title = session?.title

    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 76

    navigationController?.navigationBar.barStyle = UIBarStyle.default
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pattern-64tall"), for: UIBarMetrics.default)
    navigationController?.navigationBar.tintColor = UIColor.white
    navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationController?.setNavigationBarHidden(false, animated: animated)
  }

  // MARK: - Table view data source

  override func numberOfSections(in tableView: UITableView) -> Int {
    if session == nil {
      return 0
    } else {
      return 3
    }
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == Sections.info {
      return 4
    } else if section == Sections.description {
      return 1
    } else if section == Sections.presenters {
      return session?.presenters.count ?? 0
    }

    return 0
  }

  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if let session = session {
      if section == Sections.info {
        if session.sessionNumber == "" {
          return "Summary"
        } else {
          return "Session #\(session.sessionNumber)"
        }
      } else if section == Sections.description {
        return "Description"
      } else if section == Sections.presenters {
        if session.presenters.count == 1 {
          return "Presenter"
        } else if session.presenters.count > 1 {
          return "Presenters"
        }
      }
    }
    return nil
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let session = session else {
      return tableView.dequeueReusableCell(withIdentifier: "detailButton", for: indexPath)
    }
    if (indexPath.section == Sections.info && indexPath.row == 3){
      let cell = tableView.dequeueReusableCell(withIdentifier: "detailButton", for: indexPath) as! DetailTableViewCell

      cell.keyLabel.text = "My Schedule".uppercased()
      if session.isFavorite {
        cell.valueButton.setTitle("Remove from My Schedule", for: .normal)
      } else {
        cell.valueButton.setTitle("Add to My Schedule", for: .normal)
      }
      cell.valueButton.addTarget(self, action: #selector(myScheduleButton(sender:)), for: .touchUpInside)

      return cell
    } else if indexPath.section == Sections.info && indexPath.row == 2 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "detailButton", for: indexPath as IndexPath) as! DetailTableViewCell

      cell.keyLabel.text = "Where".uppercased()
      cell.valueButton.setTitle(session.room.name, for: .normal)
      if session.isParty {
        cell.valueButton.setTitleColor(view.tintColor, for: .normal)
        cell.valueButton.addTarget(self, action: #selector(roomDetails(sender:)), for: .touchUpInside)
      } else {
        cell.valueButton.setTitleColor(UIColor.darkText, for: .normal)
      }
      return cell
    } else if indexPath.section == Sections.info {
      let cell = tableView.dequeueReusableCell(withIdentifier: "detail", for: indexPath as IndexPath) as! DetailTableViewCell

      if indexPath.row == 0 {
        cell.keyLabel.text = "Track".uppercased()
        cell.valueLabel.text = session.track.name
      } else if indexPath.row == 1 {
        cell.keyLabel.text = "When".uppercased()
        cell.valueLabel.text = session.startDateTimeString
      }

      return cell
    } else if indexPath.section == Sections.description {
      let cell = tableView.dequeueReusableCell(withIdentifier: "label", for: indexPath as IndexPath) as! LabelTableViewCell
      cell.label.text = session.sessionDescription
      return cell
    } else if indexPath.section == Sections.presenters {
      let cell = tableView.dequeueReusableCell(withIdentifier: "presenter", for: indexPath as IndexPath) as! PresenterTableViewCell
      let presenter = session.presenters[indexPath.row] as! Person

      if let image = UIImage(named: presenter.identifier) {
        cell.squareImageView.image = image
      } else {
        cell.squareImageView.image = UIImage(named: "RW_logo")
      }
      cell.nameLabel.text = presenter.fullName
      cell.bioLabel.text = presenter.bio
      if presenter.twitter != "" {
        cell.twitterButton.isHidden = false
        cell.twitterButton.setTitle("@\(presenter.twitter)", for: .normal)
        cell.twitterButton.addTarget(self, action: #selector(twitterButton(sender:)), for: .touchUpInside)
      } else {
        cell.twitterButton.isHidden = true
      }

      return cell
    } else {
      assertionFailure("Unhandled session table view section")
      let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath as IndexPath) as UITableViewCell
      return cell
    }
  }

  func roomDetails(sender: UIButton) {
    if let roomVC = storyboard?.instantiateViewController(withIdentifier: "RoomViewController") as? RoomViewController {
      roomVC.room = session?.room
      roomVC.title = session?.room.name
      navigationController?.pushViewController(roomVC, animated: true)
    }
  }

  func myScheduleButton(sender: UIButton) {
    guard let session = session else {
      return;
    }
    session.isFavorite = !session.isFavorite

    tableView.reloadSections(NSIndexSet(index: Sections.info) as IndexSet, with: .automatic)
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: MyScheduleSomethingChangedNotification), object: self, userInfo: ["session": session])
  }

  func twitterButton(sender: UIButton) {
    UIApplication.shared.open(URL(string: "http://twitter.com/\(sender.title(for: .normal)!)")!)
  }
}
