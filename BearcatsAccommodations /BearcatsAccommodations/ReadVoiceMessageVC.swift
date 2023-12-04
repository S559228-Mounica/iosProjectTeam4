//
//  ReadVoiceMessageVC.swift
//  BearcatsAccommodations
//
//  Created by Bhargav Krishna Moparthy on 11/18/23.
//

import UIKit
import AVKit

class ReadVoiceMessageVC: UIViewController {
    
    @IBOutlet var playerView: UIView!
    
    @IBOutlet var progressBar: UISlider!
    @IBOutlet var playerTimeLbl: UILabel!
    @IBOutlet var totalTimeLbl: UILabel!
    
    @IBOutlet var cancelBtn: UIButton!
    @IBOutlet var spinnerView: UIActivityIndicatorView!
    @IBOutlet var playBtn: UIButton!
    
    var serverDuration = 0
    var totalDuration = 0.0
    var playingTimer: Timer?
    var playingCounter = 0
    
    var audioURL = ""
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    
    var isAlreadyGet = false
    var isFinished = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerView.isHidden = true
        
        let url1 = URL(string: audioURL)
        let playerItem:AVPlayerItem = AVPlayerItem(url: url1!)
        player = AVPlayer(playerItem: playerItem)
        player?.volume = 10
        
        
        setDesign()
        progressBar.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        self.playBtnClicked(playBtn)
    }
    
    func duration(for resource: String) -> Double {
        let asset = AVURLAsset(url: URL(fileURLWithPath: resource))
        return Double(CMTimeGetSeconds(asset.duration))
    }
    
    @objc func finishedPlaying() -> Void {
        
        progressBar.value = Float(self.totalDuration)
        
        let time = Int(self.totalDuration)
        progressBar.setValue(Float(time), animated: true)
        
        let mints = (time % 3600) / 60
        let sec = (time % 3600) % 60
        
        let title = String(format: "%02d:%02d",mints, sec)
        playerTimeLbl.text = title
        
        isFinished = true
        playingTimer?.invalidate()
        playingTimer = nil
        
        playBtn.setImage(UIImage(named: "Play"), for: .normal)
        player?.pause()
        playBtn.tag = 1
        
        playingCounter = 0
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider: UISlider) {
        
        playingCounter = Int(playbackSlider.value)
        
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        print("000===\(targetTime)")
        player!.seek(to: targetTime)
        
        let mints = (playingCounter % 3600) / 60
        let sec = (playingCounter % 3600) % 60
        
        let title = String(format: "%02d:%02d",mints, sec)
        playerTimeLbl.text = title
    }
    
    func setDesign() -> Void {
        
        
    }
    
    @objc func setPlayerClock() -> Void {
        
        playingCounter += 1
        
        let time = playingCounter
        print(String(format: "====%d", time))
        progressBar.setValue(Float(time), animated: true)
        
        let mints = (time % 3600) / 60
        let sec = (time % 3600) % 60
        
        let title = String(format: "%02d:%02d",mints, sec)
        playerTimeLbl.text = title
        
        if playingCounter >= serverDuration {
            
            self.finishedPlaying()
        }
        
    }
    
    func cleanMemory() -> Void {
        
        if player != nil {
            
            player?.pause()
        }
        
        playingTimer?.invalidate()
        playingTimer = nil
        
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelBtnClicked(_ sender: Any) {
        
        self.cleanMemory()
    }
    
    @IBAction func playBtnClicked(_ sender: UIButton) {
        
        if !isAlreadyGet {
            
            //self.totalDuration = self.duration(for: self.audioURL)
            if serverDuration > 0 {
                
                self.totalDuration = Double(serverDuration)
            }
            
            isAlreadyGet = true
            spinnerView.isHidden = false
            spinnerView.startAnimating()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    
                self.spinnerView.isHidden = true
                self.playOrPause(tag: sender.tag)
             }
        }else{
            
            self.playOrPause(tag: sender.tag)
        }
    }
    
    func playOrPause(tag: Int) -> Void {
        
        if tag == 1 {
            
            let a = Int(ceil(totalDuration))
            self.totalDuration = Double(a)
            progressBar.maximumValue = Float(a)
            
            if isFinished {
                
                progressBar.value = 0
            }
            isFinished = false
            
            let mints = (a % 3600) / 60
            let sec = (a % 3600) % 60
            
            let title = String(format: "%02d:%02d",mints, sec)
            totalTimeLbl.text = title
            
            playingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setPlayerClock), userInfo: nil, repeats: true)
            playBtn.setImage(UIImage(named: "Pause"), for: .normal)
            
            let seconds : Int64 = Int64(progressBar.value)
            let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
            
            player?.seek(to: targetTime)
            player?.play()
            
            playBtn.tag = 2

        }else{
            
            playingTimer?.invalidate()
            playingTimer = nil
            
            playBtn.setImage(UIImage(named: "Play"), for: .normal)
            player?.pause()
            playBtn.tag = 1
        }
    }
}
