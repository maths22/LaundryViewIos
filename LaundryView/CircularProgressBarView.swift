//
//  CircularProgressBarView.swift
//  EmojiSend
//
//  Created by Oliver Elliott on 3/3/22.
//

import UIKit

class CircularProgressBarView: UIView {
    
    // - Properties -
    
    private var circleLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var underLayer = CAShapeLayer()
    private var startPoint = CGFloat((Double.pi/4)*3)
    private var endPoint = CGFloat( Double.pi / 4)
    private var isDone = false
    private var finishAnimationFrom = 0
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func createCircularPath() {
        // created circularPath for circleLayer and progressLayer
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0), radius: (frame.size.height/2)+3, startAngle: startPoint, endAngle: endPoint, clockwise: true)
        
        underLayer.path = circularPath.cgPath
        // ui edits
        underLayer.fillColor = UIColor.clear.cgColor
        underLayer.lineCap = .round
        underLayer.lineWidth = 7
        underLayer.strokeEnd = 1
        if #available(iOS 13.0, *) {
            underLayer.strokeColor = UIColor.tertiaryLabel.cgColor
        } else {
            underLayer.strokeColor = UIColor.gray.cgColor
        }
        // added progressLayer to layer
        layer.addSublayer(underLayer)
        
        
        // progressLayer path defined to circularPath
        progressLayer.path = circularPath.cgPath
        // ui edits
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineCap = .round
        progressLayer.lineWidth = 7
        progressLayer.strokeEnd = 0
        progressLayer.strokeColor = UIColor.systemBlue.cgColor
        // added progressLayer to layer
        layer.addSublayer(progressLayer)
    }
    
    func progressAnimation(duration: TimeInterval) {
        // created circularProgressAnimation with keyPath
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        // set the end time
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 1
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
    
    func startAnimation() {
        isDone = false
        self.alpha = 1
        // created circularProgressAnimation with keyPath
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        let duration = 0.4
        // set the end time
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = 0.8
        circularProgressAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
//        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
//            if !self.isDone {
//                self.middleAniamtion()
//            }
//        }
    }
    
    func animate(to value: Double) {
        isDone = false
        self.alpha = 1
        // created circularProgressAnimation with keyPath
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        let duration = 0.4
        // set the end time
        circularProgressAnimation.duration = duration
        circularProgressAnimation.toValue = value
        circularProgressAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
    }
    
//    private func middleAniamtion() {
//        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
//        let duration = 6.0
//        circularProgressAnimation.duration = duration
//        circularProgressAnimation.fromValue = 0.8
//        circularProgressAnimation.toValue = 0.9
//        circularProgressAnimation.timingFunction = CAMediaTimingFunction(name: .linear)
//        circularProgressAnimation.fillMode = .forwards
//        circularProgressAnimation.isRemovedOnCompletion = false
//        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
//        DispatchQueue.main.asyncAfter(deadline: .now() + duration-1) {
//            self.finishAnimationFrom = 0.9
//        }
//    }
    
    func finishAnimation() {
        isDone = true
        let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
        let duration = 0.5
        circularProgressAnimation.duration = duration
        circularProgressAnimation.fromValue = finishAnimationFrom
        circularProgressAnimation.toValue = 1
        circularProgressAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        circularProgressAnimation.fillMode = .forwards
        circularProgressAnimation.isRemovedOnCompletion = false
        progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: 0.3, delay: 0, animations: {
                self.progressLayer.strokeColor = UIColor.systemGreen.cgColor
            })
        }
        
    }
    
    func hide(completion: @escaping () -> ()) {
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.alpha = 0
        }, completion: {_ in
            completion()
        })
    }
    
}
