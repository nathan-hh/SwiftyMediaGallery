//
//  MediaViewCell.swift
//  SwiftyMediaGallery
//
//  Created by nati on 14/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import Combine

class MediaViewCell: UICollectionViewCell {
    @IBOutlet weak var imgPic: UIImageView!
    @IBOutlet var vTrackVideoPlaying: UIView!
    @IBOutlet var sliderVideoPlaying: UISlider!
    @IBOutlet var lblCurrentLoc: UILabel!
    @IBOutlet var lblTotalDuration: UILabel!
    private var videoURL :String?
    private var playerLayer : AVPlayerLayer?
    private var player : AVPlayer?
    private var isPlaying = false
    private var isSeeking = false
    private var item : AnyMediaItem!;
    
    private lazy var setupSlider: () = {
        let radius : CGFloat = 16
        let thumbView = UIView()
        thumbView.backgroundColor = .white
        thumbView.layer.borderWidth = 0.2
        thumbView.layer.borderColor = UIColor.darkGray.cgColor
        thumbView.frame = CGRect(x: 0, y: radius / 2, width: radius, height: radius)
        thumbView.layer.cornerRadius = radius / 2
        let thumb = thumbView.asImage()
        sliderVideoPlaying.setThumbImage(thumb, for: .normal)
        sliderVideoPlaying.setThumbImage(thumb, for: .selected)
        sliderVideoPlaying.setThumbImage(thumb, for: .highlighted)
    }()
    
    private lazy var setupPlayerLayer: () = {
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = imgPic.bounds
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        enableZoom()
    }
    
    func setup(item : AnyMediaItem){
        self.item = item
        switch item.type {
        case .image: break
        case .video:
            videoURL = item.url
            setupVideo();
        }
        updateImage()
    }
    
    func updateImage(){
        switch item.type {
        case .image:
            let url = item.thumbUrl ?? item.url
            imgPic.contentMode = .scaleAspectFill
            if let url = url , !url.isEmpty  {
                imgPic.set(image: url)
            }
        case .video:
            imgPic.contentMode = .scaleAspectFit
            if let url = videoURL , !url.isEmpty  {
                imgPic.set(image: url)
            }
        }
    }
    
    func playPause(){
        guard item.type == .video else {return}
        _ = setupSlider
        _ = setupPlayerLayer

        vTrackVideoPlaying.isHidden = false
        if let playerLayer = playerLayer, playerLayer.superlayer == nil{
            layer.addSublayer(playerLayer)
        }
        isPlaying ? player?.pause() : player?.play()
        isPlaying = !isPlaying
    }
    
    func finishVideo(){
        guard item.type == .video else {return}
        playerLayer?.removeFromSuperlayer()
        player?.seek(to: .zero)
        player?.pause()
        vTrackVideoPlaying?.isHidden = true
        isPlaying = false
    }
    
    @IBAction private func slideVideoAction(_ sender: UISlider) {
        seekVideoTo(seconds: Double(sender.value))
    }
    
    private func setupVideo(){
        guard let urlstr = videoURL,let url = URL(string: urlstr) else{
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {[weak self] in
            guard let self = self else {return}
            let item = AVPlayerItem(url: url);
            self.player = AVPlayer(playerItem: item)
            self.player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.01, preferredTimescale: 1000), queue: nil) {[weak self] time in
                guard let self = self, let item = self.player?.currentItem ,!self.isSeeking else {
                    return
                }
                let current = time.seconds / item.duration.seconds
                guard !(current.isNaN || current.isInfinite) else { return}
                self.lblTotalDuration?.text = Int(item.duration.seconds).localizedSecondsTime
                self.sliderVideoPlaying.value = Float(current)
                self.lblCurrentLoc?.text = Int(time.seconds).localizedSecondsTime
                if  time.seconds == item.duration.seconds{
                    self.finishVideo()
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.imgPic.bounds
    }
    
    private func seekVideoTo(seconds:Double){
        guard let item = self.player?.currentItem else {
            return
        }
        isSeeking = true
        player?.seek(to: CMTime(seconds: seconds * item.duration.seconds, preferredTimescale: 1000), completionHandler: { [weak self](finish) in
            self?.isSeeking = !finish
        })
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        imgPic.layoutIfNeeded()
    }
    
    deinit {
        player = nil
    }
}
