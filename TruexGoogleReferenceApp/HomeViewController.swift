//
//  HomeViewController.swift
//  TruexGoogleReferenceApp
//
//  Copyright © 2019 true[X]. All rights reserved.
//

import AVKit

class HomeViewController: UIViewController,
                          UICollectionViewDataSource,
                          UICollectionViewDelegate,
                          StreamDisplayViewCellDelegate {
    private let streamConfigurationsURL = "https://stash.truex.com/reference-apps/tvos/config/reference-app-streams.json"
    
    @IBOutlet private var collectionView: UICollectionView?
    @IBOutlet private var streamTitle: UITextView?
    @IBOutlet private var streamDescription: UITextView?
    
    private var streamConfigurations: [StreamConfiguration]?
    private var focusedStream: StreamConfiguration?
    private var playerLayer: AVPlayerLayer?
    private var playerLooper: AVPlayerLooper?
    private var collectionViewOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchStreamConfigurations()
        if let firstStream = streamConfigurations?[0] {
            focusedStream = firstStream
        }
        playerLayer = AVPlayerLayer()
        if let playerLayer = playerLayer {
            playerLayer.frame = view.bounds
            playerLayer.backgroundColor = UIColor.black.cgColor
            view.layer.insertSublayer(playerLayer, at: 0)
        }
        let background = UIView()
        background.frame = view.frame
        background.backgroundColor = UIColor.init(displayP3Red: 0, green: 0, blue: 0, alpha: 0.75)
        view.insertSubview(background, at: 1)
        collectionViewOffset = collectionView?.frame.origin.x ?? 0
    }
 
    private func fetchStreamConfigurations() {
        if let url = URL(string: streamConfigurationsURL) {
            guard let data = try? Data(contentsOf: url) else {
                print("Unable to load data from stream configuration URL")
                return
            }
            self.streamConfigurations = try? JSONDecoder().decode([StreamConfiguration].self, from: data)
            if (self.streamConfigurations == nil) {
                print("Unable to decode stream configurations")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let playerViewController = segue.destination as? PlayerViewController,
            let focusedStream = focusedStream {
            playerViewController.setStream(contentSourceID: focusedStream.googleContentID,
                                           videoID: focusedStream.googleVideoID)
            setScreenshotAsLoadingScreen(for: playerViewController)
            playerLayer?.player?.pause()
        }
    }
 
    private func setScreenshotAsLoadingScreen(for playerViewController: PlayerViewController) {
        UIGraphicsBeginImageContextWithOptions(view.frame.size, view.isOpaque, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            if let screenshot = screenshot {
                playerViewController.displayLoadingScreen(screenshot)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource protocol
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let streamConfigurations = streamConfigurations {
            return streamConfigurations.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StreamDisplayCell",
                                                      for: indexPath)
        if let streamDisplay = cell as? StreamDisplayViewCell, let configs = streamConfigurations {
            streamDisplay.setConfiguration(configs[indexPath.section], delegate: self)
        }
        return cell
    }
    
    // MARK: StreamDisplayViewCellDelegate protocol
    func setFocusedStream(_ configuration: StreamConfiguration) {
        focusedStream = configuration
        let index = indexOfSelectedStream()
        if index == 0 {
            collectionView?.frame.origin.x = collectionViewOffset
        } else {
            collectionView?.frame.origin.x = (CGFloat) (-index * 380) + (collectionViewOffset - 100)
        }

        streamTitle?.text = configuration.title
        streamDescription?.text = configuration.description
        setupLoopingPreview(videoURLString: configuration.preview)
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
    
    private func indexOfSelectedStream() -> Int {
        if let streamConfigurations = streamConfigurations, let focusedStream = focusedStream {
            return streamConfigurations.firstIndex(where: { $0 == focusedStream }) ?? 0
        }
        return 0
    }
    
    private func setupLoopingPreview(videoURLString: String) {
        if let videoURL = URL(string: videoURLString) {
            let videoAsset = AVAsset(url: videoURL)
            let playerItem = AVPlayerItem(asset: videoAsset)
            let player = AVQueuePlayer(url: videoURL)
            playerLooper = AVPlayerLooper(player: player,
                                          templateItem: playerItem)
            playerLayer?.player = player
            player.volume = 0
            player.play()
        }
    }
}
