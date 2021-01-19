//
//  ViewController.swift
//  pomodoroapp
//
//  Created by umelabs on 2020/4/26.
//  Copyright © 2020 umelabs.dev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CAAnimationDelegate {

    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    //サークルアニメーション
    let foreProgressLayer = CAShapeLayer()
    let backProgressLayer = CAShapeLayer()
    let animatation = CABasicAnimation(keyPath: "strokeEnd")
    
    var isAnimationStarted = false
    
    var timer = Timer()
    var isTimerStarted = false
    var time = 1500
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawBackLayer()
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    @IBAction func startButtonTapped(_ sender: Any) {
        cancelButton.isEnabled = true
        cancelButton.alpha = 1.0
        if !isTimerStarted{
            drawForeLayer() //アニメーション
            startResumedAnimation() //アニメーションの処理
            startTimer()
            isTimerStarted = true
            startButton.setTitle("Pause", for: .normal)
            startButton.setTitleColor(UIColor.orange, for: .normal)
            
            
        }else {
            pauseAnimation() //Animation
            timer.invalidate()
            isTimerStarted = false
            startButton.setTitle("Resume", for: .normal)
            startButton.setTitleColor(UIColor.green, for: .normal)
        }
    }
    

    @IBAction func cancelButtonTapped(_ sender: Any) {
        //fix when cancel tapped start button text reset
        stopAnimation()
        cancelButton.isEnabled = false
        cancelButton.alpha = 0.5
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.green, for: .normal)
        timer.invalidate()
        time = 1500
        isTimerStarted = false
        timeLabel.text = "25:00"
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
   @objc func updateTimer(){
    if time < 1 {
        cancelButton.isEnabled = false
        cancelButton.alpha = 0.5
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.green, for: .normal)
        timer.invalidate()
        time = 1500
        isTimerStarted = false
        timeLabel.text = "25:00"
    } else {
        time -= 1
        timeLabel.text = formatTime()
    }
    
    }
    
    func formatTime()->String{
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
        
    }
    
    //後ろの円
    func drawBackLayer(){
        //円を描いている
        backProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY),
                                              radius: 100,
                                              startAngle: -90.degreesToRadians,
                                              endAngle: 270.degreesToRadians,
                                              clockwise: true).cgPath
        //その他
        backProgressLayer.strokeColor = UIColor.white.cgColor
        backProgressLayer.fillColor = UIColor.clear.cgColor
        backProgressLayer.lineWidth = 15
        view.layer.addSublayer(backProgressLayer)
    }
    
    //前の円
    func drawForeLayer(){
        //円を描いている
        foreProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY),
                                              radius: 100,
                                              startAngle: -90.degreesToRadians,
                                              endAngle: 270.degreesToRadians,
                                              clockwise: true).cgPath
        //その他
        foreProgressLayer.strokeColor = UIColor.red.cgColor
        foreProgressLayer.fillColor = UIColor.clear.cgColor
        foreProgressLayer.lineWidth = 15
        view.layer.addSublayer(foreProgressLayer)
    }
    
    func startResumedAnimation(){
        if !isAnimationStarted {
            startAnimation()
        } else {
            resumeAnimation()
        }
    }
    
    func startAnimation(){
        resetAnimation()
        foreProgressLayer.strokeEnd = 0.0 //0からスタート
        animatation.keyPath = "strokeEnd"
        animatation.fromValue = 0
        animatation.toValue = 1 //0から1
        animatation.duration = 1500
        animatation.delegate = self
//        ここから
        animatation.isRemovedOnCompletion = false
        animatation.isAdditive = true
        animatation.fillMode = CAMediaTimingFillMode.forwards
//        ここまでよくわからん
        foreProgressLayer.add(animatation, forKey: "strokeEnd")
        isAnimationStarted = true
        
        
    }
    
    func resetAnimation(){
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0 //?
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        isAnimationStarted = false
    }
    
    func pauseAnimation(){
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 0.0
        foreProgressLayer.timeOffset = pausedTime
    }
    
    func resumeAnimation(){
        let pausedTime = foreProgressLayer.timeOffset //?
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0 //?
        foreProgressLayer.beginTime = 0.0
        let timeSincePaused = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        foreProgressLayer.beginTime = timeSincePaused
    }
    
    func stopAnimation(){
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0 //?
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        foreProgressLayer.removeAllAnimations()
        isAnimationStarted = false
    }
    
    //これを追加したらタイマー残り0の時に赤い部分が消える?? startAnimationにdelegate追加
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }
}

extension Int{
    var degreesToRadians : CGFloat{
        return CGFloat(self) * .pi/180
    }
}
