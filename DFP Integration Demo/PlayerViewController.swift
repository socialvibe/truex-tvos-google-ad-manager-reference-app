//
//  PlayerViewController.swift
//  DFP Integration Demo
//
//  Copyright © 2019 true[X]. All rights reserved.
//

import AVKit
import InteractiveMediaAds
import TruexAdRenderer

class PlayerViewController: UIViewController,
                            IMAStreamManagerDelegate,
                            TruexAdRendererDelegate,
                            AVPlayerViewControllerDelegate {
    // Properties needed to initialize a stream with the IMA SDK
    private var contentSourceID: String = "2494430"
    private var videoID: String = "googleio-highlights"

    // These four properties allow us to do the basic work of playing back ad-stitched video.
    private var playerViewController: AVPlayerViewController
    private var player: AVPlayer
    private var videoDisplay: IMAAVPlayerVideoDisplay
    private var streamManager: IMAStreamManager
    
    // Variables used to display a loading screen
    private var loadingImage: UIImageView
    private var loadingOverlay: UIView
    private var loadingIndicator: UIActivityIndicatorView
    private var playerItemContext = 0
    
    // The renderer that drives the true[X] Engagement experience.
    private var adRenderer: TruexAdRenderer?
    
    // [1]
    // We keep track of which ad break we're in so we know how far to seek when skipping it.
    private var currentAdBreak: IMAAdBreakInfo?
    private var userSeekTime: CMTime?
    
    // Setter for content stream
    func setStream(contentSourceID: String, videoID: String) {
        self.contentSourceID = contentSourceID
        self.videoID = videoID
    }
    
    // Display a loading screen via an overlay on a designated image
    func displayLoadingScreen(_ screen: UIImage) {
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
    
    required init?(coder decoder: NSCoder) {
        playerViewController = AVPlayerViewController()
        player = AVPlayer()
        playerViewController.player = player
        loadingImage = UIImageView()
        loadingOverlay = UIView()
        loadingIndicator = UIActivityIndicatorView(style: .whiteLarge)
        loadingIndicator.color = .white

        videoDisplay = IMAAVPlayerVideoDisplay(avPlayer: playerViewController.player)
        streamManager = IMAStreamManager(videoDisplay: videoDisplay)

        super.init(coder: decoder)
        
        streamManager.delegate = self
        playerViewController.delegate = self
        playerViewController.view.addSubview(loadingImage)
        playerViewController.view.addSubview(loadingOverlay)
        playerViewController.view.addSubview(loadingIndicator)

        // Observe the player's status changes in order to hide loading screen
        player.addObserver(self,
                           forKeyPath: #keyPath(AVPlayerItem.status),
                           options: [.new, .old],
                           context: &playerItemContext)
    }
    
    //MARK: - View Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        let streamRequest = IMAVODStreamRequest(contentSourceID: contentSourceID, videoID: videoID)
        streamManager.requestStream(streamRequest)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        present(playerViewController, animated: false)
    }
    
    //MARK: - IMA Stream Manager Delegate Methods
    func streamManager(_ streamManager: IMAStreamManager?, adBreakDidStart adBreakInfo: IMAAdBreakInfo?) {
        // [1]
        // Keep track of this for later use. adBreakDidStart should fire before adDidStart in all cases.
        currentAdBreak = adBreakInfo
        allowSeeks(false)
    }

    func streamManager(_ streamManager: IMAStreamManager?, adDidStart ad: IMAAd?) {
        // [2]
        // The true[X] Engagement information is stored in a VAST companion ad
        // Search the available companions to see if a true[X] companion ad is present
        let searchCompanionAds = ad?.companions.filter{ $0.apiFramework == "truex" }
        guard let companionAd = searchCompanionAds!.first else {
            print("Unable to find true[X] ad")
            return
        }
        
        // [3]
        // The companion ad contains a URL (the "static resource URL") which tells us where to go to get the
        // ad parameters for our Engagement.
        // Expect a data URL in the following format: "data:application/json;charset=utf-8;base64,<base64 encoded JSON>"
        // Here we parse the <base 64 encoded JSON> string
        let base64Config = companionAd.staticResourceURL.components(separatedBy: "base64,")[1]
        guard let decodedData = Data(base64Encoded:base64Config,
                                     options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else {
            print("Unable to parse static resource url data")
            return
        }
        
        let jsonDict = try? JSONSerialization.jsonObject(with: decodedData, options: [])
        if (jsonDict == nil || !(jsonDict is [String: String])) {
            print("Unable to parse ad parameters JSON")
            return
        }
        
        // [4]
        // We pause the underlying stream in order to present the true[X] experience and seek over the current ad,
        // which is just a placeholder for the true[X] ad.
        player.pause()
        let seekTime = player.currentTime() + CMTimeMakeWithSeconds(ad?.duration ?? 0, preferredTimescale: 1000)
        player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
        // Slot type constants are defined in TruexConstants.h
        let slotType = currentAdBreak?.adBreakIndex == 0 ? PREROLL : MIDROLL
        
        // [5]
        adRenderer = TruexAdRenderer(url: "https://media.truex.com/placeholder.js",
                              adParameters: jsonDict as! [String: String],
                              slotType: slotType)
        adRenderer?.delegate = self
    }
    
    // These next two methods are required in the IMAStreamManagerDelegate protocol
    // but there's nothing we need to do in them for the purposes of this integration demo,
    // so we leave the bodies empty
    func streamManager(_ streamManager: IMAStreamManager!, didReceiveError error: Error!) {
        if let error = error {
            print("Error: \(error)")
        }
    }
    
    func streamManager(_ streamManager: IMAStreamManager?, didInitializeStream streamID: String?) {
        if let streamID = streamID {
            print("Did initialize stream: \(streamID)")
        }
    }

    func streamManager(_ streamManager: IMAStreamManager?, adBreakDidEnd adBreakInfo: IMAAdBreakInfo?) {
        allowSeeks(true)
        seekToUserTime()
    }
    
    private func seekToUserTime() {
        if let userSeekTime = self.userSeekTime {
            player.seek(to: userSeekTime, toleranceBefore: .zero, toleranceAfter: .zero)
            self.userSeekTime = nil
        }
    }
    
    private func allowSeeks(_ isSeekingAllowed: Bool) {
        playerViewController.requiresLinearPlayback = !isSeekingAllowed
    }
    
    // MARK: - true[X] Ad Renderer Delegate Methods
    
    // A real application would probably have something to do here, but there's nothing we're strictly required to
    // do here in the simplest case.
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
        if let adBreak = currentAdBreak {
            let seekTime = CMTimeMakeWithSeconds(adBreak.timeOffset + adBreak.duration,
                                                 preferredTimescale: 1000)
            player.seek(to: seekTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }

    // The next three methods are all invoked when the engagement has, for whatever reason, stopped running. In all of these
    // cases, we can just resume playback of the player. If the viewer has earned their true[ATTENTION] credit, then they will
    // already be seeked past the ad pod, so they will se content. If not, then the playhead will still be at the beginning
    // of the ad pod, so on resume, the viewer will see the ads.
    func onAdCompleted(_ timeSpent: Int) {
        // [7]
        player.play()
    }
    
    func onAdError(_ errorMessage: String?) {
        // [7]
        player.play()
    }
    
    func onNoAdsAvailable() {
        // [7]
        player.play()
    }
    
    // This is invoked when the user presses the menu button on the TV remote while the renderer is still showing the
    // engagement choice card. In that case, we assume the user wants to cancel the whole stream, not just the true[X]
    // experience, so we dismiss the view controller, exiting the app. Of course, in a real media app, this would instead
    // go back to the episode list view, or whatever is appropriate.
    func onUserCancelStream() {
        // [8]
        dismiss(animated: true)
    }
    
    // Finally, this method is invoked after the renderer has finished initialization, and since we always initialize the
    // renderer right before we want to play, we just immediately begin playback.
    func onFetchAdComplete() {
        // [5]
        adRenderer?.start(playerViewController)
    }
    
    // MARK: AVPlayer delegate
    func playerViewController(_ playerViewController: AVPlayerViewController,
                              timeToSeekAfterUserNavigatedFrom oldTime: CMTime,
                              to targetTime: CMTime) -> CMTime {
        let targetTimeSeconds = CMTimeGetSeconds(targetTime)
        let prevCuepoint = self.streamManager.previousCuepoint(forStreamTime: targetTimeSeconds)
        // Ensure the viewer cannot seek past an unplayed ad
        if let prevCuepoint = prevCuepoint, !prevCuepoint.isPlayed {
            self.userSeekTime = targetTime;
            return CMTimeMakeWithSeconds(prevCuepoint.startTime, preferredTimescale: 1000)
        }
        return targetTime
    }
    
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

}
