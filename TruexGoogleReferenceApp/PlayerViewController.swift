//
//  PlayerViewController.swift
//  TruexGoogleReferenceApp
//
//  Copyright © 2019 true[X]. All rights reserved.
//

import AVKit
import GoogleInteractiveMediaAds
import TruexAdRenderer

class PlayerViewController: UIViewController,
                            IMAAdsLoaderDelegate,
                            IMAStreamManagerDelegate,
                            TruexAdRendererDelegate,
                            AVPlayerViewControllerDelegate {
    // MARK: [CHANGE ME]
    // Properties needed to initialize a stream with the IMA SDK
    // Values should be set based on your stream
    private var contentSourceID: String = "2494430"
    private var videoID: String = "googleio-highlights"
    
    // MARK: [REQUIRED]
    // These four properties allow us to do the basic work of playing back ad-stitched video.
    private var playerViewController: AVPlayerViewController
    private var player: AVPlayer
    private var videoDisplay: IMAAVPlayerVideoDisplay
    private var streamManager: IMAStreamManager?
    private var adsLoader: IMAAdsLoader
    
    // The renderer that drives the true[X] Engagement experience.
    private var adRenderer: TruexAdRenderer?
    
    // [1]
    // We keep track of which ad break we're in so we know how far to seek when skipping it.
    private var currentAdBreak: IMAAdPodInfo?
    private var currentTrueXAd: IMAAd?
    private var timeRangesToSkip: [CMTimeRange] = []
    
    // MARK: [OPTIONAL]
    // Variables used to display a loading screen
    private var loadingImage: UIImageView = UIImageView()
    private var loadingOverlay: UIView = UIView()
    private var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    private var playerItemContext = 0
    
    // To save the viewer's seek time if a seek is interrupted by an ad break
    private var userSeekTime: TimeInterval?

    // To show when the ad breaks are in the player progress bar
    private var adCuepoints: [IMACuepoint] = []
    
    // MARK: - View Controller Overrides
    // MARK: [REQUIRED]
    required init?(coder decoder: NSCoder) {
        playerViewController = AVPlayerViewController()
        player = CustomAVPlayer()
        playerViewController.player = player
        
        videoDisplay = IMAAVPlayerVideoDisplay(avPlayer: playerViewController.player)
        adsLoader = IMAAdsLoader()

        super.init(coder: decoder)
        
        adsLoader.delegate = self
        playerViewController.delegate = self

        listenForApplicationEvents()
        /* [OPTIONAL] */ listenForPlayerStatus()
    }
    
    class CustomAVPlayer: AVPlayer {
        override func seek(to time: CMTime) {
            return super.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
    
    private func listenForApplicationEvents() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.willResignActiveNotification),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didBecomeActiveNotification),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let adDisplayContainer = IMAAdDisplayContainer(adContainer: self.view)
        let streamRequest = IMAVODStreamRequest(contentSourceID: contentSourceID, videoID: videoID, adDisplayContainer: adDisplayContainer, videoDisplay: videoDisplay)
        adsLoader.requestStream(with: streamRequest)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        present(playerViewController, animated: false)
    }
    
    // MARK: - UIApplicationDelegate Methods
    // MARK: [REQUIRED]
    @objc func willResignActiveNotification(_ application: UIApplication) {
        adRenderer?.pause()
    }

    @objc func didBecomeActiveNotification(_ application: UIApplication) {
        adRenderer?.resume()
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, adsLoadedWith adsLoadedData: IMAAdsLoadedData!) {
        streamManager = adsLoadedData.streamManager
        streamManager?.delegate = self
        streamManager?.initialize(with: nil)
    }
    
    func adsLoader(_ loader: IMAAdsLoader!, failedWith adErrorData: IMAAdLoadingErrorData!) {
        print("Error: \(adErrorData)")
        NSLog("truex: adsLoader failedWith error");
    }

    // MARK: - IMA Stream Manager Delegate Methods
    // MARK: [REQUIRED]
    func streamManager(_ streamManager: IMAStreamManager!, didReceive error: IMAAdError!) {
        print("Error: \(error)")
        NSLog("truex: streamManager didReceive error");
    }
    
    func streamManager(_ streamManager: IMAStreamManager?, didReceive event: IMAAdEvent) {
        if (event.ad != nil && event.ad.companionAds != nil) {
            print(String(format: "truex: companions?.count: %zd", (event.ad.companionAds.count) ))
            
        }
        NSLog("truex: event: %@", event.typeString)
        
        // We should skip to the regular ads if the placeholder plays
        let searchCompanionAds = event.ad?.companionAds.filter{ $0.apiFramework == "truex" }
        if (searchCompanionAds?.first != nil) {
            if (event.type == .FIRST_QUARTILE || event.type == .MIDPOINT || event.type == .THIRD_QUARTILE) {
                seekAfterTrueXInvalidAndPlay()
                print("Error: truex ad should not be played as normal ads, skipping to regular ads.")
                return
            }
        }
        
        switch event.type {
        case .AD_BREAK_STARTED:
            allowSeeks(false)
            break;
        case .AD_BREAK_ENDED:
            allowSeeks(true)
            /* [OPTIONAL] */ seekToUserTime()
            break;
        case .CUEPOINTS_CHANGED:
            adCuepoints.removeAll()
            adCuepoints.append(contentsOf: event.adData?["cuepoints"] as! [IMACuepoint])
            showAdTimesInAVPlayer()
            break;
        case .LOADED:
            // [1]
            // Keep track of this for later use.
            currentAdBreak = event.ad.adPodInfo
            NSLog("truex: LOADED");
            break;
        case .STARTED:
            NSLog("truex: STARTED");
            // [2]
            // The true[X] Engagement information is stored in a VAST companion ad
            // Search the available companions to see if a true[X] companion ad is present
            let searchCompanionAds = event.ad?.companionAds.filter{ $0.apiFramework == "truex" }
            guard let companionAd = searchCompanionAds!.first else {
                print("Unable to find true[X] ad")
                break;
            }

            currentTrueXAd = event.ad
            // [3]
            // The companion ad contains a URL (the "static resource URL") which tells us where to go to get the
            // ad parameters for our Engagement.
            // Expect a data URL in the following format: "data:application/json;charset=utf-8;base64,<base64 encoded JSON>"
            // Here we parse the <base 64 encoded JSON> string
            let base64Config = companionAd.resourceValue!.components(separatedBy: "base64,")[1]
            guard let decodedData = Data(base64Encoded:base64Config,
                                         options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else {
                print("Unable to parse static resource url data")
                break;
            }
            
            let jsonDict = try? JSONSerialization.jsonObject(with: decodedData, options: [])
            if (jsonDict == nil || !(jsonDict is [String: String])) {
                print("Unable to parse ad parameters JSON")
                return
            }
            
            // [4]
            // We pause the underlying stream in order to present the true[X] experience and seek over the current ad,
            // which is just a placeholder for the true[X] ad.
            videoDisplay.pause()
            let currentAdBreakIndex = currentAdBreak?.podIndex ?? 0
            let normalAdPodStartTime = self.adCuepoints[currentAdBreakIndex].startTime + (currentTrueXAd?.duration ?? 0)
            videoDisplay.seekStream(toTime: normalAdPodStartTime)
            
            // Slot type constants are defined in TruexConstants.h
            let slotType = currentAdBreakIndex == 0 ? PREROLL : MIDROLL
            
            // [5]
            adRenderer = TruexAdRenderer(url: "https://media.truex.com/placeholder.js",
                                         adParameters:jsonDict as! [String: String],
                                         slotType: slotType)
            adRenderer?.delegate = self
            break;
        default:
            break;
        }
    }

    // MARK: - true[X] Ad Renderer Delegate Methods
    // MARK: [REQUIRED]
    
    // A real application may use this delegate to implement a timeout
    // If this delegate is not fired after a set amount of time, the renderer can be stopped with adRenderer?.stop()
    // Then normal video ads can be shown instead
    func onAdStarted(_ campaignName: String?) {
        if let campaignName = campaignName {
            print("Did start ad: \(campaignName)")
        }
    }
    
    // [6]
    // This method is invoked when the viewer has earned their true[ATTENTION] credit. Since in this example their reward
    // is getting to skip the ads, here we seek over the linear ad pod and into the content. Note that we don't re-enable
    // playback here; the viewer might stay in their engagements for quite a while after they've earned their credit. However,
    // by seeking now, we can have the play head at the right place when the viewer is ready.
    func onAdFreePod() {
        if (self.userSeekTime != nil) {
            /* [OPTIONAL] */ seekToUserTime()
        } else {
            let currentAdBreakIndex = currentAdBreak?.podIndex ?? 0
            videoDisplay.seekStream(toTime: self.adCuepoints[currentAdBreakIndex].endTime)
        }
        allowSeeks(true)
    }

    // The next three methods are all invoked when the engagement has, for whatever reason, stopped running. In all of these
    // cases, we resume playback of the player. If the viewer has earned their true[ATTENTION] credit, then they will
    // already be seeked past the ad pod, so they will se content. If not, then the playhead will still be at the beginning
    // of the ad pod, so on resume, the viewer will see the ads.
    // If there the true[X] renderer did not receive an ad, we record the time range of the placeholder ad to skip over it if needed
    func onAdCompleted(_ timeSpent: Int) {
        // [7]
        adRenderer = nil
        videoDisplay.play()
    }
    
    func onAdError(_ errorMessage: String?) {
        // [7]
        adRenderer = nil
        seekAfterTrueXInvalidAndPlay()
    }
    
    func onNoAdsAvailable() {
        // [7]
        adRenderer = nil
        seekAfterTrueXInvalidAndPlay()
    }
    
    private func seekAfterTrueXInvalidAndPlay() {
        let currentAdBreakIndex = currentAdBreak?.podIndex ?? 0
        timeRangesToSkip.append(timeRangeFrom(start: adCuepoints[currentAdBreakIndex].startTime, duration: (currentTrueXAd?.duration ?? 0)))
        let normalAdPodStartTime = adCuepoints[currentAdBreakIndex].startTime + (currentTrueXAd?.duration ?? 0)
        videoDisplay.seekStream(toTime: normalAdPodStartTime)
        videoDisplay.play()
    }
    
    // This is invoked when the user presses the menu button on the TV remote while the renderer is still showing the
    // engagement choice card. In that case, we assume the user wants to cancel the whole stream, not just the true[X]
    // experience. We dismiss the view controller, returning to the stream selection screen
    func onUserCancelStream() {
        // [8]
        playerViewController.dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: "ReturnToStreamSelect", sender: self)
        })
    }
    
    // Finally, this method is invoked after the renderer has finished initialization, and since we always initialize the
    // renderer right before we want to play, we just immediately begin playback.
    func onFetchAdComplete() {
        // [5]
        adRenderer?.start(playerViewController)
    }
    
    // MARK: - AV Player Delegate Methods
    // MARK: [OPTIONAL]
    func playerViewController(_ playerViewController: AVPlayerViewController,
                              timeToSeekAfterUserNavigatedFrom oldTime: CMTime,
                              to targetTime: CMTime) -> CMTime {
        let targetTimeSeconds = CMTimeGetSeconds(targetTime)
        let prevCuepoint = self.streamManager?.previousCuepoint(forStreamTime: targetTimeSeconds)
        // Ensure the viewer cannot seek past an unplayed ad
        if let prevCuepoint = prevCuepoint, isInvalidSeekFromAdBreak(prevCuepoint, oldTime: oldTime) {
            self.userSeekTime = targetTimeSeconds
            return getFirstVideoAdStartTime(prevCuepoint)
        }
        return targetTime
    }

    private func isInvalidSeekFromAdBreak(_ cuePoint: IMACuepoint, oldTime: CMTime) -> Bool {
        // Old time may report incorrectly from within ad break because we resume playback after the true[X] renderer has exited
        // A seek time within the ad break means the seek was started before the ad break
        return !cuePoint.isPlayed ||
                oldTime.seconds < cuePoint.startTime ||
                (oldTime.seconds > cuePoint.startTime && oldTime.seconds < cuePoint.endTime);
    }
    
    private func getFirstVideoAdStartTime(_ cuePoint: IMACuepoint) -> CMTime {
        let adBreakStartTime = CMTime(seconds: cuePoint.startTime, preferredTimescale: 1000)
        for skippableTruexPlaceholders in timeRangesToSkip {
            if skippableTruexPlaceholders.containsTime(adBreakStartTime) {
                return skippableTruexPlaceholders.end
            }
        }
        return adBreakStartTime
    }
    
    func playerViewControllerDidEndDismissalTransition(_ playerViewController: AVPlayerViewController) {
        performSegue(withIdentifier: "ReturnToStreamSelect", sender: self)
    }
    
    // MARK: - NS Object Overrides
    // MARK: [OPTIONAL]
    // Hide loading screen when the player is ready
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        // Only handle observations for the playerItemContext
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
            return
        }
        
        if keyPath == #keyPath(AVPlayerItem.status) {
            let status: AVPlayerItem.Status
            if let statusNumber = change?[.newKey] as? NSNumber {
                status = AVPlayerItem.Status(rawValue: statusNumber.intValue)!
            } else {
                status = .unknown
            }
            switch status {
                case .readyToPlay:
                    hideLoadingScreen()
                default:
                    break
            }
        }
    }

    // MARK: - Player View Controller Utilities
    // MARK: [OPTIONAL]
    // Setter for content stream
    func setStream(contentSourceID: String, videoID: String) {
        self.contentSourceID = contentSourceID
        self.videoID = videoID
    }
    
    // Display a loading screen via an overlay on a designated image
    func displayLoadingScreen(_ screen: UIImage) {
        playerViewController.view.addSubview(loadingImage)
        playerViewController.view.addSubview(loadingOverlay)
        playerViewController.view.addSubview(loadingIndicator)
        loadingIndicator.color = .white
        loadingImage.image = screen
        loadingImage.frame = UIScreen.main.bounds
        loadingOverlay.frame = UIScreen.main.bounds
        loadingOverlay.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.75)
        loadingIndicator.center = CGPoint(x: UIScreen.main.bounds.midX,
                                          y: UIScreen.main.bounds.midY)
        loadingIndicator.startAnimating()
    }
    
    // Hides the loading screen
    private func hideLoadingScreen() {
        UIView.animate(withDuration: 1.0, delay: 0, options: .curveEaseOut, animations: {
            self.loadingImage.alpha = 0
            self.loadingOverlay.alpha = 0
        }, completion : { finished in
            self.loadingIndicator.stopAnimating()
        })
    }
    
    private func seekToUserTime() {
        if let userSeekTime = self.userSeekTime {
            videoDisplay.seekStream(toTime: userSeekTime)
            self.userSeekTime = nil
        }
    }
    
    private func allowSeeks(_ isSeekingAllowed: Bool) {
        playerViewController.requiresLinearPlayback = !isSeekingAllowed
    }
    
    private func listenForPlayerStatus() {
        player.addObserver(self,
                           forKeyPath: #keyPath(AVPlayerItem.status),
                           options: [.new, .old],
                           context: &playerItemContext)
    }

    private func interstitialRangesFromCuepoints(_ cuepoints: [IMACuepoint]) -> [AVInterstitialTimeRange] {
        var ranges: [AVInterstitialTimeRange] = []
        for cuepoint in cuepoints {
            ranges.append(
                AVInterstitialTimeRange(timeRange: timeRangeFrom(start: cuepoint.startTime,
                                                                 duration: cuepoint.endTime - cuepoint.startTime))
            );
        }
        return ranges
    }

    private func timeRangeFrom(start: TimeInterval, duration: TimeInterval) -> CMTimeRange {
        return CMTimeRange(start: CMTimeMakeWithSeconds(start, preferredTimescale: 1000),
                           duration: CMTimeMakeWithSeconds(duration, preferredTimescale: 1000))
    }

    private func showAdTimesInAVPlayer() {
        if adCuepoints.count > 0 {
            player.currentItem?.interstitialTimeRanges = interstitialRangesFromCuepoints(adCuepoints)
        }
    }
}
