//
//  SendVoiceMessageVC.swift
//  BearcatsAccommodations
//
//  Created by Aashritha Dodda on 11/18/23.
//

import UIKit
import AVKit
import FirebaseStorage
import FirebaseAuth
import FirebaseFirestore

protocol voiceMessageSentDelegate {
    
    func didVoiceMessageSent() -> Void
}

class SendVoiceMessageVC: UIViewController {
    
    var delegate: voiceMessageSentDelegate?
    
    @IBOutlet var recordingView: UIView!
    @IBOutlet var recordTimeLbl: UILabel!
    @IBOutlet var playerView: UIView!
    
    @IBOutlet var progressBar: UISlider!
    @IBOutlet var playerTimeLbl: UILabel!
    
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var deleteBtn: UIButton!
    @IBOutlet var stopBtn: UIButton!
    @IBOutlet var sendBtn: UIButton!
    
    var loginUserID = ""
    var bookingDetails = NSDictionary()
    
    var recordingTimer: Timer?
    var recordingCounter = 0
    
    var playingTimer: Timer?
    var playingCounter = 0
    
    var isFinished = true
    
    let RecordingName = "Recording.m4a"
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVPlayer!
    
    var alert: UIAlertController?
    var user_ID = ""
    var user_name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        playerView.isHidden = true
        recordingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setRecordingClock), userInfo: nil, repeats: true)
        
        self.startRecording()
        
        self.setDesign()
        progressBar.addTarget(self, action: #selector(playbackSliderValueChanged(_:)), for: .valueChanged)
    }
    
    @objc func playbackSliderValueChanged(_ playbackSlider: UISlider) {
        
        let counter = Int(playbackSlider.value)
        playingCounter = recordingCounter - counter
        
        print(String(format: "slider value changed === %d", playingCounter))
        let seconds : Int64 = Int64(playbackSlider.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        audioPlayer!.seek(to: targetTime)
        
        let mints = (counter % 3600) / 60
        let sec = (counter % 3600) % 60
        
        let title = String(format: "%02d:%02d",mints, sec)
        playerTimeLbl.text = title
    }
    
    @objc func setRecordingClock() -> Void {
        
        recordingCounter += 1
        
        let mints = (recordingCounter % 3600) / 60
        let sec = (recordingCounter % 3600) % 60
        
        let title = String(format: "%02d:%02d",mints, sec)
        recordTimeLbl.text = title
    }
    
    @objc func setPlayerClock() -> Void {
        
        if playingCounter > 0 {
            
            playingCounter -= 1
            
            print(String(format: "timer value changed === %d", playingCounter))
            
            let time = recordingCounter - playingCounter
            progressBar.setValue(Float(time), animated: true)
            
            let mints = (playingCounter % 3600) / 60
            let sec = (playingCounter % 3600) % 60
            
            let title = String(format: "%02d:%02d",mints, sec)
            playerTimeLbl.text = title
        }
    }
    
    func setDesign() -> Void {
        
        playerView.isHidden = true
        recordTimeLbl.isHidden = false
        
        
        sendBtn.isHidden = true
    }
    
    @IBAction func playPauseBtnClicked(_ sender: UIButton) {
        
        if sender.tag == 1 {
            
            if playingCounter == recordingCounter {
                
                if isFinished {
                    
                    progressBar.value = 0
                }
                
                isFinished = false
            }
            
            playingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(setPlayerClock), userInfo: nil, repeats: true)
            playBtn.setImage(UIImage(named: "Pause"), for: .normal)
            
            let seconds : Int64 = Int64(progressBar.value)
            let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
            
            audioPlayer!.seek(to: targetTime)
            audioPlayer.play()
            
            playBtn.tag = 2

        }else{
            
            playingTimer?.invalidate()
            playingTimer = nil
            
            playBtn.setImage(UIImage(named: "Play"), for: .normal)
            audioPlayer.pause()
            playBtn.tag = 1
        }
    }
    
    @IBAction func deleteBtnClicked(_ sender: Any) {
        
        self.cleanMemory()
    }
    
    func cleanMemory() -> Void {
        
        if audioPlayer != nil {
            
            audioPlayer.pause()
        }
        
        if audioRecorder.isRecording {
            
            audioRecorder.stop()
        }
        
        playingTimer?.invalidate()
        playingTimer = nil
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        self.dismiss(animated: true)
    }
    
    @IBAction func stopBtnClicked(_ sender: Any) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.finishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        audioRecorder.stop()
        setupPlayer()
        
        recordingTimer?.invalidate()
        recordingTimer = nil
        
        stopBtn.isHidden = true
        recordTimeLbl.isHidden = true
        sendBtn.isHidden = false
        playerView.isHidden = false
    }
    
    @objc func finishedPlaying() -> Void {
        
        isFinished = true
        playingTimer?.invalidate()
        playingTimer = nil
        
        playBtn.setImage(UIImage(named: "Play"), for: .normal)
        audioPlayer.pause()
        playBtn.tag = 1
        
        playingCounter = recordingCounter
    }
    
    @IBAction func sendBtnClicked(_ sender: Any) {
        
        self.showLoader()
        self.uploadAudio()

    }
    
    func showLoader() -> Void {
        
        alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert?.view.addSubview(loadingIndicator)
        present(alert!, animated: true, completion: nil)
    }
    
    
    func uploadAudio() -> Void {
        
        let storage = Storage.storage()
        
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(RecordingName)
        
        
        let referance = storage.reference()
        let mediaFolder = referance.child("Audios")
        let id = UUID().uuidString // using uuid to give uniq names to audiofiles preventing overwrite
        let mediaRef = mediaFolder.child(String(format: "%@.mp3", id))// creating file referance using uuid + filename
        let path = audioFileURL // getting filepath
        do {
            let data = try Data(contentsOf: path) // getting data from filepath
            mediaRef.putData(data) { metadata, error in
                if error != nil {
                    //self.showAlert(title: "Error", message: error?.localizedDescription, cancelButtonTitle: "cancel", handler: nil)
                    self.alert?.dismiss(animated: true)
                } else {
                    mediaRef.downloadURL { url, error in
                        let url = url?.absoluteString
                        self.uploadAudioMessage(str: url ?? "")
                    }
                }
            }
            print("record has come")
        } catch {
            print("error cant get audio file")
        }
        
    }
    
    func uploadAudioMessage(str: String) -> Void {
        
        let myTimeStamp = Date().timeIntervalSince1970
        
        let id = Auth.auth().currentUser?.uid ?? ""
        let name = Auth.auth().currentUser?.displayName ?? ""
        
        let params = ["message": "Audio Message",
                      "url": str,
                      "sender_id": id,
                      "sender_name": name,
                      "receiver_id": user_ID,
                      "receiver_name": user_name,
                      "type": 4,
                      "duration": String(format: "%d", recordingCounter),
                      "timestamp": myTimeStamp] as [String : Any]
        
        
        let path = String(format: "Chats")
        let db = Firestore.firestore()
        
        db.collection(path).document().setData(params) { err in
            if let _ = err {
                
                self.alert?.dismiss(animated: true)
                self.view.makeToast("Message sending failed")
            } else {
                
                self.alert?.dismiss(animated: true)
                self.view.makeToast("Message sent successfully")
                
                self.delegate?.didVoiceMessageSent()
                self.cleanMemory()
                
            }
        }
    }
    
    
}

extension SendVoiceMessageVC: AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        
        isFinished = true
        playingTimer?.invalidate()
        playingTimer = nil
        
        playBtn.setImage(UIImage(named: "Play"), for: .normal)
        playBtn.tag = 1
        
        progressBar.maximumValue = Float(recordingCounter)
        progressBar.minimumValue = 0
        progressBar.isSelected = false
        progressBar.value = 0
        
        playingCounter = recordingCounter
    }
}


extension SendVoiceMessageVC {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    // MARK: - Recording
    func startRecording() {
        
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(RecordingName)
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.duckOthers)
        } catch {
            print(error)
        }
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        
        guard let recorder  = try? AVAudioRecorder(url: audioFileURL, settings: settings) else {
            stopRecording(success: false)
            return
        }
        
        audioRecorder = recorder
        audioRecorder.isMeteringEnabled = true
        audioRecorder.delegate = self
        //try! session.setActive(true)
        audioRecorder.record()
        
        
        
    }
    
    func stopRecording(success: Bool) {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
        }
    }
    
    //MARK: Player
    func setupPlayer() {
        
        let audioFileURL = getDocumentsDirectory().appendingPathComponent(RecordingName)
        let playerItem:AVPlayerItem = AVPlayerItem(url: audioFileURL)
        audioPlayer = AVPlayer(playerItem: playerItem)
        audioPlayer.volume = 100
    }
}
