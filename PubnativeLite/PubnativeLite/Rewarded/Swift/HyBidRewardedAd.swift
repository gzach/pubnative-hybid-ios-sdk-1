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
public protocol HyBidRewardedAdDelegate: AnyObject {
    func rewardedDidLoad()
    
    @objc(rewardedDidFailWithError:)
    func rewardedDidFailWithError(error: Error)
    
    func rewardedDidTrackImpression()
    func rewardedDidTrackClick()
    func rewardedDidDismiss()
    func onReward()
}

@objc
public class HyBidRewardedAd: NSObject {
    
    // MARK: - Public properties
    
    @objc public var ad: HyBidAd?
    @objc public var isReady = false
    @objc public var isMediation = false
    
    // MARK: - Private properties
    
    private var zoneID: String?
    private weak var delegate: HyBidRewardedAdDelegate?
    private var rewardedPresenter: HyBidRewardedPresenter?
    private var rewardedAdRequest: HyBidRewardedAdRequest?
    
    @objc
    public convenience init(zoneID: String, andWithDelegate delegate: HyBidRewardedAdDelegate) {
        self.init()
        self.rewardedAdRequest = HyBidRewardedAdRequest()
        self.rewardedAdRequest?.openRTBAdType = VIDEO
        self.zoneID = zoneID
        self.delegate = delegate
    }
    
    convenience init(delegate: HyBidRewardedAdDelegate) {
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
            self.rewardedAdRequest?.setIntegrationType(self.isMediation ? MEDIATION : STANDALONE, withZoneID: zoneID)
            self.rewardedAdRequest?.requestAd(with: HyBidRewardedAdRequestWrapper(parent: self), withZoneID: zoneID)
        } else {
            let error = NSError(domain: "Invalid Zone ID provided.", code: 0, userInfo: nil)
            self.invokeDidFailWithError(error: error)
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
    
    func processAdContent(adContent: String) {
        let signalDataProcessor = HyBidSignalDataProcessor()
        signalDataProcessor.delegate = self
        signalDataProcessor.processSignalData(adContent, withZoneID: self.zoneID)
    }
    
    @objc
    public func show() {
        if self.isReady {
            self.rewardedPresenter?.show()
        } else {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidRewardedAd.self), methodName: #function, message: "Can't display ad. Rewarded is not ready.")
        }
    }
    
    @objc(showFromViewController:)
    public func showFromViewController(viewController: UIViewController) {
        if self.isReady {
            self.rewardedPresenter?.show(from: viewController)
        } else {
            HyBidLogger.warningLog(fromClass: String(describing: HyBidRewardedAd.self), methodName: #function, message: "Can't display ad. Rewarded is not ready.")
        }
    }
    
    func hide() {
        self.rewardedPresenter?.hide()
    }
    
    func renderAd(ad: HyBidAd) {
        let rewardedPresenterFactory = HyBidRewardedPresenterFactory()
        self.rewardedPresenter = rewardedPresenterFactory.createRewardedPresenter(with: ad, with: self)
            
        if (self.rewardedPresenter == nil) {
            HyBidLogger.errorLog(fromClass: String(describing: HyBidRewardedAd.self), methodName: #function, message: "Could not create valid rewarded presenter.")
            
            let error = NSError(domain: "The server has returned an unsupported ad asset.", code: 0, userInfo: nil)
            self.invokeDidFailWithError(error: error)
            return
        } else {
            self.rewardedPresenter?.load()
        }
    }
    
    func invokeDidLoad() {
        guard let delegate = self.delegate else { return }
        delegate.rewardedDidLoad()
    }
    
    func invokeDidFailWithError(error: Error) {
        HyBidLogger.errorLog(fromClass: String(describing: HyBidRewardedAd.self), methodName: #function, message: error.localizedDescription)
        
        if let delegate = delegate {
            delegate.rewardedDidFailWithError(error: error)
        }
    }
    
    func invokeDidTrackImpression() {
        guard let delegate = self.delegate else { return }
        delegate.rewardedDidTrackImpression()
    }
    
    func invokeDidTrackClick() {
        guard let delegate = self.delegate else { return }
        delegate.rewardedDidTrackClick()
    }
    
    func invokeDidDismiss() {
        guard let delegate = self.delegate else { return }
        delegate.rewardedDidDismiss()
    }
    
    func invokeOnReward() {
        guard let delegate = self.delegate else { return }
        delegate.onReward()
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

extension HyBidRewardedAd {
    public func requestDidStart(_ request: HyBidAdRequest) {
        let message = "Ad Request \(String(describing: request)) started"
        HyBidLogger.debugLog(fromClass: String(describing: HyBidRewardedAd.self), methodName: #function, message: message)
    }

    public func request(_ request: HyBidAdRequest, didLoadWithAd ad: HyBidAd?) {
        let message = "Ad Request \(String(describing: request)) loaded with ad \(String(describing: ad))"
        HyBidLogger.debugLog(fromClass: String(describing: HyBidRewardedAd.self), methodName: #function, message: message)

        if let ad = ad {
            self.ad = ad
            self.ad?.adType = Int(kHyBidAdTypeVideo)
            self.renderAd(ad: ad)
        } else {
            let error = NSError(domain: "Server returned nil ad.", code: 0, userInfo: nil)
            self.invokeDidFailWithError(error: error)
        }
    }

    public func request(_ requst: HyBidAdRequest, didFailWithError error: Error) {
        self.invokeDidFailWithError(error: error)
    }
}

// MARK: - HyBidRewardedPresenterDelegate

extension HyBidRewardedAd: HyBidRewardedPresenterDelegate {
    public func rewardedPresenterDidLoad(_ rewardedPresenter: HyBidRewardedPresenter!) {
        self.isReady = true
        self.invokeDidLoad()
    }
    
    public func rewardedPresenter(_ rewardedPresenter: HyBidRewardedPresenter!, didFailWithError error: Error!) {
        self.invokeDidFailWithError(error: error)
    }

    public func rewardedPresenterDidShow(_ rewardedPresenter: HyBidRewardedPresenter!) {
        self.invokeDidTrackImpression()
    }

    public func rewardedPresenterDidClick(_ rewardedPresenter: HyBidRewardedPresenter!) {
        self.invokeDidTrackClick()
    }

    public func rewardedPresenterDidDismiss(_ rewardedPresenter: HyBidRewardedPresenter!) {
        self.invokeDidDismiss()
    }
    
    public func rewardedPresenterDidFinish(_ rewardedPresenter: HyBidRewardedPresenter!) {
        self.invokeOnReward()
    }
}

// MARK: - HyBidSignalDataProcessorDelegate
extension HyBidRewardedAd: HyBidSignalDataProcessorDelegate {
    public func signalDataDidFinish(with ad: HyBidAd) {
        self.ad = ad
        self.ad?.adType = Int(kHyBidAdTypeVideo)
        self.renderAd(ad: ad)
    }
    
    public func signalDataDidFailWithError(_ error: Error) {
        invokeDidFailWithError(error: error)
    }
}
