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
import AddressBook
import MapKit
import Contacts

class AboutViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet weak var webView: UIWebView!

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()

    // #e6e6e6
    view.backgroundColor = UIColor(red: 230/255.0, green: 230/255.0, blue: 230/255.0, alpha: 1.0)

    do {
      let filePath = Bundle.main.path(forResource: "about", ofType: "html")!
      let htmlString = try String(contentsOfFile: filePath, encoding: .utf8)
      webView.loadHTMLString(htmlString, baseURL: Bundle.main.bundleURL)
    } catch {
      return
    }
  }
}

// MARK: - UIWebViewDelegate
extension AboutViewController: UIWebViewDelegate {

  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    guard let url = request.url,
      url.absoluteString == "rwdevcon://location" else {
        return true
    }

    let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 38.895518, longitude: -77.010729),
                                addressDictionary: [CNPostalAddressStreetKey: "415 New Jersey Avenue Northwest",
                                                    CNPostalAddressCityKey: "Washington",
                                                    CNPostalAddressStateKey: "DC",
                                                    CNPostalAddressPostalCodeKey: "20001",
                                                    CNPostalAddressCountryKey: "US"])
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = "RWDevCon"
    MKMapItem.openMaps(with: [mapItem], launchOptions: [:])
    return false
  }
}
