//
//  ViewController.swift
//  WhiteNoiseApp
//
//  Created by Thivagar Nadarajan on 2020-04-21.
//  Copyright © 2020 Thivagar Nadarajan. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    /* Main view */
    @IBOutlet weak var heading: UILabel!
    var currentMedia : UIButton! //Determines if play or pause will be displayed
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var timerButton: UIButton!
   
    /* Timer view */
    @IBOutlet weak var timerView: UIView! //Hidden view
    var timerMenu : UIStackView!
    var timeLabel : UILabel!
    var timer : Timer!
    var timeLeft : Int!
    var currentTimer : Int!
        
    /* Sound menu */
    @IBOutlet weak var soundMenu: UIStackView!
    @IBOutlet weak var fireButton: UIButton!
    @IBOutlet weak var rainButton: UIButton!
    @IBOutlet weak var fanButton: UIButton!
    
    /* Audio for each sound */
    var fireAudio : AVAudioPlayer!
    var rainAudio : AVAudioPlayer!
    var fanAudio : AVAudioPlayer!
    var currentAudio : AVAudioPlayer! //Keep track of which audio is playing
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initTimerMenu()
        initSoundMenu()
        initAudio()
        currentMedia = pauseButton
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }

    func initTimerMenu() {
        timerMenu = UIStackView()
        timeLabel = UILabel()
        
        currentTimer = 1
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
        
        /* Close menus on touch */
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(closeTimerView))
        timerView.addGestureRecognizer(tapGesture)
        timerView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        timerMenu.distribution = .fill
        timerMenu.alignment = UIStackView.Alignment.center
        timerMenu.spacing = 20
        timerMenu.axis = .vertical
        timeLabel.textColor = UIColor.white
        timeLabel.font = UIFont.systemFont(ofSize: 30)
        timerMenu.addArrangedSubview(timeLabel)
        
        let timerOptions = UIStackView()
        timerOptions.spacing = 30
        
        let timerOptionsOne = UIStackView()
        timerOptionsOne.spacing = 20
        timerOptionsOne.axis = .vertical
        timerOptionsOne.alignment = UIStackView.Alignment.center
        
        let timerOptionsTwo = UIStackView()
        timerOptionsTwo.spacing = 20
        timerOptionsTwo.axis = .vertical
        timerOptionsTwo.alignment = UIStackView.Alignment.center
        
        for i in 1...8 {
            let timeButton = UIButton()
            
            if (i == 1) {
                timeButton.setTitle("\(i) Hour", for: .normal)
                timeButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
            } else {
                timeButton.setTitle("\(i) Hours", for: .normal)
                timeButton.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            }
                        
            timeButton.tag = i
            timeButton.addTarget(self, action: #selector(changeTimeLeft), for: .touchUpInside)
            timeButton.setTitleColor(UIColor.white, for: .normal)
            timeButton.layer.borderWidth = 2.0
            timeButton.layer.borderColor = UIColor.white.cgColor
            timeButton.layer.cornerRadius = 10
            timeButton.clipsToBounds = true
            timeButton.setTitleColor(UIColor.lightGray, for: .highlighted)
            
            if (i <= 4) {
                timerOptionsOne.addArrangedSubview(timeButton)
            } else {
                timerOptionsTwo.addArrangedSubview(timeButton)
            }
        }
        
        timerOptions.addArrangedSubview(timerOptionsOne)
        timerOptions.addArrangedSubview(timerOptionsTwo)
        timerMenu.addArrangedSubview(timerOptions)
    }
    
    func initSoundMenu() {
        fireButton.layer.borderWidth = 2.0;
        fireButton.layer.borderColor = UIColor.white.cgColor
        fireButton.layer.cornerRadius = 10
        fireButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        let fireImg = UIImage(named: "fire")?.withRenderingMode(.alwaysTemplate)
        fireButton.setImage(fireImg, for: .normal)
        fireButton.tintColor = .white

        
        rainButton.layer.borderWidth = 2.0;
        rainButton.layer.borderColor = UIColor.white.cgColor
        rainButton.layer.cornerRadius = 10
        rainButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        let rainImg = UIImage(named: "rain")?.withRenderingMode(.alwaysTemplate)
        rainButton.setImage(rainImg, for: .normal)
        rainButton.tintColor = .white

        
        fanButton.layer.borderWidth = 2.0;
        fanButton.layer.borderColor = UIColor.white.cgColor
        fanButton.layer.cornerRadius = 10
        fanButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        let fanImg = UIImage(named: "fan")?.withRenderingMode(.alwaysTemplate)
        fanButton.setImage(fanImg, for: .normal)
        fanButton.tintColor = .white
    }
    
    func initAudio(){
        let firePath = Bundle.main.path(forResource: "Fire", ofType: "mp3")
        let rainPath = Bundle.main.path(forResource: "Rain", ofType: "mp3")
        let fanPath = Bundle.main.path(forResource: "Fan", ofType: "mp3")
        
        do {
            fireAudio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: firePath!))
            rainAudio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: rainPath!))
            fanAudio = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fanPath!))
        } catch {
            print(error)
        }
        
        /* Run audio in the background */
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSession.Category.playback)
        } catch {
            print(error)
        }
        
        /* Initialize audio to play for 1 hour */
        rainAudio.numberOfLoops = 12
        fireAudio.numberOfLoops = 12
        fanAudio.numberOfLoops = 12
        
        currentAudio = fireAudio
        currentAudio.play()
        selectSound(fireButton)
    }
    
    @objc func runTimer() {
        if timeLeft <= 0 {
            mediaControl(pauseButton)
            closeTimerView()
            timeLeft = currentTimer*3600
            displayTime()
            return
        }
        
        timeLeft -= 1
        displayTime()
    }
    
    func displayTime() {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional

        let formattedString = formatter.string(from: TimeInterval(timeLeft))!
        timeLabel.text = formattedString
    }
    
    @objc func changeTimeLeft(_ sender: UIButton) {
        currentTimer = sender.tag
        timeLeft = sender.tag*3600
        displayTime()
        currentAudio.currentTime = 0
        currentAudio.numberOfLoops = sender.tag*12
        mediaControl(playButton)
        currentMedia.isHidden = true //Ensure media button doesn't show in timer view
    }
    
    @IBAction func openTimerMenu(_ sender: UIButton) {
        timerView.addSubview(timerMenu)
        timerMenu.translatesAutoresizingMaskIntoConstraints = false
        timerMenu.centerXAnchor.constraint(equalTo:timerView.centerXAnchor).isActive = true
        timerMenu.centerYAnchor.constraint(equalTo:timerView.centerYAnchor).isActive = true

        /* Hide main view items & show shadow view */
        timerView.isHidden = false
        currentMedia.isHidden = true
        timerButton.isHidden = true
        heading.isHidden = true
        soundMenu.isHidden = true
    }
    
    @objc func closeTimerView() {
        /* Empty shadow view */
        for view in timerView.subviews {
            view.removeFromSuperview()
        }
        
        /* Show main view items & hide shadow view */
        timerView.isHidden = true
        currentMedia.isHidden = false
        timerButton.isHidden = false
        heading.isHidden = false
        soundMenu.isHidden = false
    }
    
    @IBAction func selectSound(_ sender: UIButton) {
        /* Clear all set colors for button text and border */
        fireButton.layer.borderColor = UIColor.white.cgColor
        fireButton.setTitleColor(UIColor.white, for: .normal)
        fireButton.tintColor = .white
        
        rainButton.layer.borderColor = UIColor.white.cgColor
        rainButton.setTitleColor(UIColor.white, for: .normal)
        rainButton.tintColor = .white
        
        fanButton.layer.borderColor = UIColor.white.cgColor
        fanButton.setTitleColor(UIColor.white, for: .normal)
        fanButton.tintColor = .white
        
        /* Change colour of sender button and play the correct audio */
        switch (sender.tag){
        case 0:
            let fireRed = UIColor(red:222/255, green:89/255, blue:89/255, alpha:1)
            fireButton.layer.borderColor = fireRed.cgColor
            fireButton.setTitleColor(fireRed, for: .normal)
            fireButton.tintColor = fireRed
            currentAudio.pause()
            currentAudio = fireAudio
        case 1:
            let rainBlue = UIColor(red:87/255, green:154/255, blue:255/255, alpha:1)
            rainButton.layer.borderColor = rainBlue.cgColor
            rainButton.setTitleColor(rainBlue, for: .normal)
            rainButton.tintColor = rainBlue
            currentAudio.pause()
            currentAudio = rainAudio
        case 2:
            let fanGreen = UIColor(red:99/255, green:201/255, blue:99/255, alpha:1)
            fanButton.layer.borderColor = fanGreen.cgColor
            fanButton.setTitleColor(fanGreen, for: .normal)
            fanButton.tintColor = fanGreen
            currentAudio.pause()
            currentAudio = fanAudio
        default:
            break
        }
        
        timeLeft = currentTimer*3600
        currentAudio.currentTime = 0
        currentAudio.numberOfLoops = currentTimer*12
        mediaControl(playButton)
    }
    
    @IBAction func mediaControl(_ sender: UIButton) {
        playButton.isHidden = true
        pauseButton.isHidden = true
        if (sender.tag == 0){
            currentMedia = pauseButton
            currentAudio.play()
            if (timer == nil){
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(runTimer), userInfo: nil, repeats: true)
            }
        } else {
            currentMedia = playButton
            currentAudio.pause()
            timer?.invalidate()
            timer = nil
        }
        currentMedia.isHidden = false
    }
    
}
