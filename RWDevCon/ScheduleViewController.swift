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

import UIKit

let bottomHeight: CGFloat = 54

class ScheduleViewController: UIViewController {

  // MARK: - Properties
  var coreDataStack: CoreDataStack!

  var scheduleTableViewControllers: [ScheduleTableViewController] = []

  var bottomView: UIView!
  var contentView: UIView!
  var segmentedControl: UISegmentedControl!

  var firstTime = true

  // MARK: - View Life Cycle
  override func awakeFromNib() {
    super.awakeFromNib()

    guard case(.pad) = UIDevice.current.userInterfaceIdiom else { return }

    preferredContentSize = CGSize(width: 320.0, height: 600.0)
    splitViewController?.preferredDisplayMode = .allVisible
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(red: 34.0/255, green: 34.0/255, blue: 34.0/255, alpha: 1.0)

    let backgroundGrey = UIView()
    backgroundGrey.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(backgroundGrey)

    NSLayoutConstraint.activate([
      backgroundGrey.topAnchor.constraint(equalTo: view.topAnchor),
      backgroundGrey.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      backgroundGrey.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      backgroundGrey.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])
    
    let friday = Date(timeIntervalSince1970: 1457676000)

    let vc1 = storyboard?.instantiateViewController(withIdentifier: "ScheduleTableViewController") as! ScheduleTableViewController
    vc1.coreDataStack = coreDataStack
    vc1.startDate = friday
    scheduleTableViewControllers.append(vc1)

    let vc2 = storyboard?.instantiateViewController(withIdentifier: "ScheduleTableViewController") as! ScheduleTableViewController
    vc2.coreDataStack = coreDataStack
    vc2.startDate = Date(timeInterval: 60*60*24, since: friday)
    scheduleTableViewControllers.append(vc2)

    let vc3 = storyboard?.instantiateViewController(withIdentifier: "ScheduleTableViewController") as! ScheduleTableViewController
    vc3.coreDataStack = coreDataStack
    vc3.startDate = nil
    scheduleTableViewControllers.append(vc3)

    contentView = UIView(frame: view.bounds)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(contentView)
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: view.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
    ])

    bottomView = UIView()
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(bottomView)
    NSLayoutConstraint.activate([
      bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomView.heightAnchor.constraint(equalToConstant: bottomHeight),
      bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    let bottomColor = UIView()
    bottomColor.translatesAutoresizingMaskIntoConstraints = false
    bottomColor.backgroundColor = UIColor.white.withAlphaComponent(0.95)
    bottomView.addSubview(bottomColor)
    NSLayoutConstraint.activate([
      bottomColor.topAnchor.constraint(equalTo: bottomView.topAnchor),
      bottomColor.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor),
      bottomColor.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor),
      bottomColor.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor)
    ])

    segmentedControl = UISegmentedControl(items: ["Friday", "Saturday", "My Schedule"])
    // TODO: default segment
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.backgroundColor = UIColor.white
    segmentedControl.tintColor = UIColor(red: 0, green: 109.0/255, blue: 55.0/255, alpha: 1.0)
    bottomView.addSubview(segmentedControl)
    NSLayoutConstraint.activate([
      NSLayoutConstraint(item: segmentedControl, attribute: .centerX, relatedBy: .equal, toItem: bottomView, attribute: .centerX, multiplier: 1.0, constant: 0),
      NSLayoutConstraint(item: segmentedControl, attribute: .centerY, relatedBy: .equal, toItem: bottomView, attribute: .centerY, multiplier: 1.0, constant: 0),
    ])
    segmentedControl.addTarget(self, action: #selector(segmentChanged(sender:)), for: .valueChanged)

    navigationController?.navigationBar.barStyle = UIBarStyle.default
    navigationController?.navigationBar.setBackgroundImage(UIImage(named: "pattern-64tall"), for: UIBarMetrics.default)
    navigationController?.navigationBar.tintColor = UIColor.white
    navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName: UIFont(name: "AvenirNext-Regular", size: 17)!, NSForegroundColorAttributeName: UIColor.white]
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func viewDidLayoutSubviews() {
    if !firstTime {
      return
    }

    firstTime = false

    let vc1 = scheduleTableViewControllers[0]
    let vc2 = scheduleTableViewControllers[1]

    contentView.addSubview(vc2.view)
    addChildViewController(vc2)
    vc2.didMove(toParentViewController: self)

    swapToViewController(toVC: vc1, animated: false)
  }

  func segmentChanged(sender: UISegmentedControl) {
    let toVC = scheduleTableViewControllers[sender.selectedSegmentIndex]
    swapToViewController(toVC: toVC, animated: false)
  }

  func swapToViewController(toVC: ScheduleTableViewController, animated: Bool = true) {
    var fromVC = childViewControllers.first as? ScheduleTableViewController

    segmentedControl.isEnabled = false

    if fromVC != nil && fromVC! == toVC {
      fromVC = nil
    }

    if let fromSelected = fromVC?.selectedIndexPath {
      fromVC?.tableView.deselectRow(at: fromSelected as IndexPath, animated: false)
    }

    fromVC?.willMove(toParentViewController: nil)
    addChildViewController(toVC)

    toVC.view.frame = contentView.bounds
    toVC.viewWillAppear(animated)

    if fromVC == nil {
      toVC.isActive = true
      contentView.addSubview(toVC.view)

      toVC.didMove(toParentViewController: self)
      toVC.viewDidAppear(animated)

      if let toSelected = toVC.tableView.indexPathForSelectedRow {
        toVC.tableView.deselectRow(at: toSelected, animated: false)
      }
      
      self.segmentedControl.isEnabled = true
    } else {
      UIView.transition(from: fromVC!.view, to: toVC.view, duration: animated ? 0.2 : 0, options: .transitionCrossDissolve) { (completed) -> Void in
        fromVC!.isActive = false
        toVC.isActive = true

        toVC.didMove(toParentViewController: self)
        toVC.viewDidAppear(animated)
        fromVC!.view.removeFromSuperview()
        fromVC!.removeFromParentViewController()

        if let toSelected = toVC.tableView.indexPathForSelectedRow {
          toVC.tableView.deselectRow(at: toSelected, animated: false)
        }

        self.segmentedControl.isEnabled = true
      }
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return UIStatusBarStyle.lightContent
  }
}
