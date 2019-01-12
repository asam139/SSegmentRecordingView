//
//  SSegmentRecordingView.swift
//  SSegmentRecordingView
//
//  Created by Saul Moreno Abril on 11/01/2019.
//

import UIKit

@objc public class SSegmentRecordingView: UIView {
    
    // MARK: - Public
    
    @objc public var segmentsDuration:[TimeInterval] = [] {
        didSet {
            // Clear old views
            clearSegments()
            
            // Create segments and sepators
            var time: TimeInterval = 0
            for (_, duration) in segmentsDuration.enumerated() {
                if (maxDuration < time + duration) {
                    break;
                }
                time += duration
                
                let segment = SSegment()
                layer.addSublayer(segment.layer)
                segments.append(segment)
                
                let separator = SSeparator()
                separator.layer.lineWidth = separatorWidth
                separator.layer.zPosition = 10
                layer.addSublayer(separator.layer)
                separators.append(separator)
            }
            
            // Set current to last
            currentIndex = segmentsDuration.count > 0 ? segmentsDuration.count - 1 : 0
            
            updateColors()
            
            setNeedsLayout()
        }
    }
    
    @objc public var currentDuration : TimeInterval {
        return segmentsDuration.reduce(0, +)
    }
    
    @objc public var segmentColor = UIColor.cyan {
        didSet {
            updateSegmentColors()
        }
    }
    
    @objc public var separatorColor = UIColor.white {
        didSet {
            updateSeparatorColors()
        }
    }
    
    
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentIndex]
                let layer = segment.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    private var maxDuration: TimeInterval = 5.0
    private var segments = [SSegment]()
    private var separators = [SSeparator]()
    private var separatorWidth: CGFloat = 2.5 {
        didSet {
            for separator in separators {
                separator.layer.lineWidth = separatorWidth
            }
        }
    }
    private var currentIndex = 0 {
        didSet {
            for (index, _) in segmentsDuration.enumerated() {
                if (index <= currentIndex) {
                    let segment = segments[index]
                    segment.layer.strokeEnd = 1.0
                    
                } else {
                    let segment = segments[index]
                    segment.layer.strokeEnd = 0.0
                }
            }
        }
    }
    
    // MARK: - Initializers
    
    init(duration: TimeInterval = 5.0) {
        super.init(frame: CGRect.zero)
        self.maxDuration = duration
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    
    private func configure() {
        self.backgroundColor = UIColor.init(white: 1.0, alpha: 0.25)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 0.5 * self.bounds.height
    }
    
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        var xOffset: CGFloat = 0
        for (index, segment) in segments.enumerated() {
            let percent = CGFloat(segmentsDuration[index]/maxDuration)
            let width = frame.width * percent
            
            segment.layer.lineWidth = frame.height
            segment.layer.frame = layer.bounds
            
            // Segment path
            let finalXOffset = xOffset + width
            
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: xOffset, y: 0.5 * frame.height))
            bezierPath.addLine(to: CGPoint(x: finalXOffset, y: 0.5 * frame.height))
            segment.layer.path = bezierPath.cgPath
            
            // Segment path
            bezierPath.removeAllPoints()
            bezierPath.move(to: CGPoint(x: finalXOffset, y: 0))
            bezierPath.addLine(to: CGPoint(x: finalXOffset, y: frame.height))
            let separator = separators[index]
            separator.layer.path = bezierPath.cgPath
            
            xOffset = finalXOffset
        }
    }
    
    
    //MARK: -  Segments
    
    private func clearSegments() {
        for segment in segments {
            segment.layer.removeFromSuperlayer()
        }
        segments.removeAll()
    }
    
    
    
    //MARK: -  Separator
    
    private func clearSeparators() {
        for separator in separators {
            separator.layer.removeFromSuperlayer()
        }
        separators.removeAll()
    }
    
    //MARK: -
    
    private func clearAll() {
        clearSegments()
        clearSeparators()
    }
    
    //MARK: - Colors
    private func updateSegmentColors() {
        for segment in segments {
            segment.layer.strokeColor = segmentColor.cgColor
        }
    }
    
    private func updateSeparatorColors() {
        for separator in separators {
            separator.layer.strokeColor = separatorColor.cgColor
        }
    }
    
    private func updateColors() {
        updateSegmentColors()
        updateSeparatorColors()
    }
    
    
    //MARK: -
    
    public func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    private func animate(animationIndex: Int = 0) {
        guard animationIndex < segments.count else {
            return
        }
        currentIndex = animationIndex
        
        let nextSegment = segments[currentIndex]
        self.isPaused = false // no idea why we have to do this here, but it fixes everything :D
        

        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.next()
        }
        
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = 2.0
        anim.fromValue = 0.0
        anim.toValue = 1.0
        nextSegment.layer.add(anim, forKey: "bounds")
        CATransaction.commit()
    }
    

    private func next() {
        let newIndex = currentIndex + 1
        if newIndex < segments.count {
            animate(animationIndex: newIndex)
        } else {
    
        }
    }
    
    func skip() {
        let currentSegment = segments[currentIndex]
        //currentSegment.view.frame.size.width = currentSegment.view.frame.width
        currentSegment.layer.removeAllAnimations()
        self.next()
    }
    
    func rewind() {
        let currentSegment = segments[currentIndex]
        currentSegment.layer.removeAllAnimations()
        currentSegment.layer.strokeEnd = 0.0
        let newIndex = max(currentIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.layer.strokeEnd = 0.0
        animate(animationIndex: newIndex)
    }
    
    
}

fileprivate class SSegment {
    let layer = CAShapeLayer()
    init() {
        layer.fillColor = UIColor.clear.cgColor
    }
}

fileprivate class SSeparator {
    let layer = CAShapeLayer()
    init() {
        layer.fillColor = UIColor.clear.cgColor
    }
}


