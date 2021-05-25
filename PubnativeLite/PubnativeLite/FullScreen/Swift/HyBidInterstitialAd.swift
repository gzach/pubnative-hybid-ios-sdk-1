//
//  Copyright © 2020 PubNative. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

@objc
public protocol HyBidInterstitialAdDelegate: AnyObject {
    func interstitialDidLoad()
    @objc(interstitialDidFailWithError:)
    func interstitialDidFailWithError(error: Error)
    func interstitialDidTrackImpression()
    func interstitialDidTrackClick()
    func interstitialDidDismiss()
}

@objc
public class HyBidInterstitialAd: NSObject {
    
    // MARK: - Public properties
    
    @objc public var ad: HyBidAd?
    @objc public var isReady = false
    @objc public var isMediation = false
    
    // MARK: - Private properties
    
    private var zoneID: String?
    private weak var delegate: HyBidInterstitialAdDelegate?
    private var interstitialPresenter: HyBidInterstitialPresenter?
    private var interstitialAdRequest: HyBidInterstitialAdRequest?
    private var skipOffset: Int?
    private var closeOnFinish = false

    @objc
    public convenience init(zoneID: String, andWithDelegate delegate: HyBidInterstitialAdDelegate) {
        self.init()
        self.interstitialAdRequest = HyBidInterstitialAdRequest()
        self.interstitialAdRequest?.openRTBAdType = VIDEO
        self.zoneID = zoneID
        self.delegate = delegate
        
        guard let settingsSkipOffset = HyBidSettings.sharedInstance.skipOffset?.intValue else { return }
        
        if settingsSkipOffset > 0 && (self.skipOffset ?? 0) <= 0 {
            setSkipOffset(settingsSkipOffset)
        }
    }
    
    convenience init(delegate: HyBidInterstitialAdDelegate) {
        self.init(zoneID: "", andWithDelegate: delegate)
    }
    
    func cleanUp() {
        self.ad = nil
    }
    
    @objc
    public func load() {
        cleanUp()
        
        if let zoneID = self.zoneID, zoneID.count > 0 {
            self.isReady = false
            self.interstitialAdRequest?.setIntegrationType(self.isMediation ? MEDIATION : STANDALONE, withZoneID: zoneID)
            self.interstitialAdRequest?.requestAd(with: HyBidIntersitialAdRequestWrapper(parent: self), withZoneID: zoneID)
        } else {
            let error = NSError(domain: "Invalid Zone ID provided.", code: 0, userInfo: nil)
            invokeDidFailWithError(error: error)
        }
    }
    
    @objc(prepareAdWithContent:)
    public func prepareAdWithContent(adContent: String) {
        if adContent.count != 0 {
            self.processAdContent(adContent: adContent)
        } else {
            let error = NSError(domain: "The server has returned an invalid ad asset", code: 0, userInfo: nil)
            self.invokeDidFailWithError(error: error)
        }
    }
    
    @objc(prepareVideoTagFrom:)
    public func prepareVideoTagFrom(url: String) {
        self.interstitialAdRequest?.requestVideoTag(from: url, andWith: HyBidIntersitialAdRequestWrapper(parent: self))
    }
    
    @objc
    public func show() {
        if self.isReady {
            self.interstitialPresenter?.show()
        } else {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidInterstitialAd.self), methodName: #function, message: "Can't display ad. Interstitial is not ready.")
        }
    }
    
    @objc(showFromViewController:)
    public func showFromViewController(viewController: UIViewController) {
        if self.isReady {
            self.interstitialPresenter?.show(from: viewController)
        } else {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidInterstitialAd.self), methodName: #function, message: "Can't display ad. Interstitial is not ready.")
        }
    }
    
    func renderAd(ad: HyBidAd) {
        let interstitalPresenterFactory = HyBidInterstitialPresenterFactory()
        self.interstitialPresenter = interstitalPresenterFactory.createInterstitalPresenter(with: ad, withSkipOffset: UInt(self.skipOffset ?? 0), withCloseOnFinish: self.closeOnFinish, with: self)
        
        if (self.interstitialPresenter == nil) {
            HyBidLogger.errorLog(fromClass: String(describing: HyBidInterstitialAd.self), methodName: #function, message: "Could not create valid interstitial presenter.")
            
            let error = NSError(domain: "The server has returned an unsupported ad asset.", code: 0, userInfo: nil)
            self.invokeDidFailWithError(error: error)
            return
        } else {
            self.interstitialPresenter?.load()
        }
    }
    
    func invokeDidLoad() {
        guard let delegate = self.delegate else { return }
        delegate.interstitialDidLoad()
    }
    
    func hide() {
        self.interstitialPresenter?.hide()
    }
    
    func processAdContent(adContent: String) {
        let signalDataProcessor = HyBidSignalDataProcessor()
        signalDataProcessor.delegate = self
        signalDataProcessor.processSignalData(adContent, withZoneID: self.zoneID)
    }
    
    @objc(setSkipOffset:)
    public func setSkipOffset(_ seconds: Int) {
        if seconds > 0 {
            skipOffset = seconds
        }
    }
    
    @objc(setCloseOnFinish:)
    public func setCloseOnFinish(_ closeOnFinish: Bool) {
        self.closeOnFinish = closeOnFinish
    }
    
    func invokeDidFailWithError(error: Error) {
        HyBidLogger.errorLog(fromClass: String(describing: HyBidInterstitialAd.self), methodName: #function, message: error.localizedDescription)
        
        if let delegate = delegate {
            delegate.interstitialDidFailWithError(error: error)
        }
    }
    
    func invokeDidTrackImpression() {
        guard let delegate = self.delegate else { return }
        delegate.interstitialDidTrackImpression()
    }
    
    func invokeDidTrackClick() {
        guard let delegate = self.delegate else { return }
        delegate.interstitialDidTrackClick()
    }
    
    func invokeDidDismiss() {
        guard let delegate = self.delegate else { return }
        delegate.interstitialDidDismiss()
    }
    
    func skAdNetworkModel() -> HyBidSkAdNetworkModel? {
        var result: HyBidSkAdNetworkModel? = nil
        
        if let ad = self.ad {
            result = ad.isUsingOpenRTB
                ? ad.getOpenRTBSkAdNetworkModel()
                : ad.getSkAdNetworkModel()
        }
        return result
    }
}

// MARK: - HyBidAdRequestDelegate

extension HyBidInterstitialAd {
    func requestDidStart(_ request: HyBidAdRequest) {
        let message = "Ad Request \(String(describing: request)) started"
        HyBidLogger.debugLog(fromClass: String(describing: HyBidInterstitialAd.self), methodName: #function, message: message)
    }
    
    func request(_ request: HyBidAdRequest, didLoadWithAd ad: HyBidAd?) {
        let message = "Ad Request \(String(describing: request)) loaded with ad \(String(describing: ad))"
        HyBidLogger.debugLog(fromClass: String(describing: HyBidInterstitialAd.self), methodName: #function, message: message)
        
        if let ad = ad {
            self.ad = ad
            self.renderAd(ad: ad)
        } else {
            let error = NSError(domain: "Server returned nil ad.", code: 0, userInfo: nil)
            self.invokeDidFailWithError(error: error)
        }
    }
    
    func request(_ requst: HyBidAdRequest, didFailWithError error: Error) {
        self.invokeDidFailWithError(error: error)
    }
}

// MARK: - HyBidInterstitialPresenterDelegate

extension HyBidInterstitialAd: HyBidInterstitialPresenterDelegate {
    public func interstitialPresenterDidLoad(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        self.isReady = true
        self.invokeDidLoad()
    }
    
    public func interstitialPresenterDidShow(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        self.invokeDidTrackImpression()
    }
    
    public func interstitialPresenterDidClick(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        self.invokeDidTrackClick()
    }
    
    public func interstitialPresenterDidDismiss(_ interstitialPresenter: HyBidInterstitialPresenter!) {
        self.invokeDidDismiss()
    }
    
    public func interstitialPresenter(_ interstitialPresenter: HyBidInterstitialPresenter!, didFailWithError error: Error!) {
        self.invokeDidFailWithError(error: error)
    }
}

// MARK: - HyBidSignalDataProcessorDelegate

extension HyBidInterstitialAd: HyBidSignalDataProcessorDelegate {
    public func signalDataDidFinish(with ad: HyBidAd) {
        self.ad = ad
        self.renderAd(ad: ad)
    }
    
    public func signalDataDidFailWithError(_ error: Error) {
        invokeDidFailWithError(error: error)
    }
}
