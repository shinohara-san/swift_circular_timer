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
    var time = 60
    
    override func viewDidLoad() {
        super.viewDidLoad()
        drawBackLayer()
        timeLabel.text = "1:00"
    }
    
    
    @IBAction func startButtonTapped(_ sender: Any) {
        cancelButton.isEnabled = true
        cancelButton.alpha = 1.0 //最初は少し暗いけどスタート押したら通常の濃さで表示される
        
        if !isTimerStarted{
            drawForeLayer() //アニメーション。前の赤い方の円を描く
            startResumedAnimation() //アニメーションの処理
            startTimer()
            isTimerStarted = true
            startButton.setTitle("Pause", for: .normal)
            startButton.setTitleColor(UIColor.orange, for: .normal)
        } else {
            pauseAnimation() //Animation
            timer.invalidate()
            isTimerStarted = false
            startButton.setTitle("Resume", for: .normal)
            startButton.setTitleColor(UIColor.green, for: .normal)
        }
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        //fix when cancel tapped start button text reset
        stopAnimation() //アニメーションを止める
        cancelButton.isEnabled = false
        cancelButton.alpha = 0.5
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(.green, for: .normal)
        timer.invalidate()
        time = 60
        isTimerStarted = false
        timeLabel.text = "1:00"
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        if time < 1 { //0になったら
            cancelButton.isEnabled = false
            cancelButton.alpha = 0.5
            startButton.setTitle("Start", for: .normal)
            startButton.setTitleColor(.green, for: .normal)
            timer.invalidate()
            time = 60
            isTimerStarted = false
            timeLabel.text = "1:00"
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
    
    //後ろの白い縁の円
    func drawBackLayer(){
        //円を描いている
        backProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY),
                                              radius: 120,
                                              startAngle: -90.degreesToRadians,
                                              endAngle: 270.degreesToRadians,
                                              clockwise: true).cgPath
        backProgressLayer.strokeColor = UIColor.white.cgColor //円の縁の色
        backProgressLayer.lineWidth = 15 //円の縁の太さ
        backProgressLayer.fillColor = UIColor.clear.cgColor //円の内側の色
        view.layer.addSublayer(backProgressLayer)
    }
    
    //前の、赤の、動く方の円
    func drawForeLayer(){
        foreProgressLayer.path = UIBezierPath(arcCenter: CGPoint(x: view.frame.midX, y: view.frame.midY),
                                              radius: 120,
                                              startAngle: -90.degreesToRadians,
                                              endAngle: 270.degreesToRadians,
                                              clockwise: true).cgPath
        foreProgressLayer.strokeColor = UIColor.red.cgColor
        foreProgressLayer.fillColor = UIColor.clear.cgColor
        foreProgressLayer.lineWidth = 15
        view.layer.addSublayer(foreProgressLayer)
    }
    
    func startResumedAnimation(){
        //        Startを押したときにタイマーが走っていない時に発動→animationが始まっていたらresumeでまだだったらstartが発火
        //        ※timerStartedとanimeStartedをごっちゃにしない
        if !isAnimationStarted {
            startAnimation()
        } else {
            resumeAnimation() //Pauseボタンを押すと再びアニメーションがスタート
        }
    }
    
    func startAnimation(){
        resetAnimation() //内部的に一旦リセットしてanimationをスタートさせる
        print("Start時: \(foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil).stringFromTimeInterval())")
        foreProgressLayer.strokeEnd = 0.0 //0からスタート
        animatation.keyPath = "strokeEnd"
        animatation.fromValue = 0
        animatation.toValue = 1 //0から1
        animatation.duration = 60
        animatation.delegate = self //追記。これがないとanimationDidStop内の関数(0になったらforeProgressLayerを消すやつ)が発火しない
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
    
    func pauseAnimation(){ //タイマー走っている&&start(pause)が押されて発動
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        print("pauseAnimation: \(pausedTime.stringFromTimeInterval())") //この値が2行下で代入後、アニメーションが再スタートした際に使われる
        foreProgressLayer.speed = 0.0 //0でないと赤い部分がなくなって再スタートでまた最初から赤がスタートする
        foreProgressLayer.timeOffset = pausedTime
    }
    
    func resumeAnimation(){ //Startを押した時にtimerは走っていない&&アニメはスタートしてる
        let pausedTime = foreProgressLayer.timeOffset // pauseAnimationでpausedTimeを代入したforeProgressLayer.timeOffset???
        print("resumeAnimation: \(pausedTime.stringFromTimeInterval())")
        foreProgressLayer.speed = 1.0 //2.0だと再スタートした際に赤アニメーションが最初からになる
        foreProgressLayer.timeOffset = 0.0 //一旦リセットして次で再設定?
        foreProgressLayer.beginTime = 0.0//一旦リセットして次で再設定?
        let timeSincePaused = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        print("引かれる方: \(foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil).stringFromTimeInterval())")
        print("timeSincePaused: \(timeSincePaused.stringFromTimeInterval())")
        foreProgressLayer.beginTime = timeSincePaused //停止したところからスタート?
    }
    
    func stopAnimation(){  //cancelボタンを押した時とanimationDidStopのとき
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0 //?
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        foreProgressLayer.removeAllAnimations()
        isAnimationStarted = false
    }
    
    //これを追加したらタイマー残り0の時に赤い部分が消える?? startAnimationにdelegate追加
    //
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }
}

extension Int{
    var degreesToRadians : CGFloat{
        return CGFloat(self) * .pi/180
        //        角度(CGFloat(self))を扇形の弧の長さに変換する拡張
        //        https://juken-mikata.net/how-to/mathematics/radian.html
    }
}

//確認用
extension TimeInterval{
    
    func stringFromTimeInterval() -> String {
        
        let time = NSInteger(self)
        
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
        
    }
}
