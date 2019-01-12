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
            for segment in segments {
                segment.view.removeFromSuperview()
                segment.separator.view.removeFromSuperview()
            }
            segments.removeAll()
            
            for _ in segmentsDuration {
                let segment = SSegment()
                addSubview(segment.view)
                segments.append(segment)
            }
            updateColors()
            
            setNeedsLayout()
        }
    }
    
    
    var topColor = UIColor.gray {
        didSet {
            updateColors()
        }
    }
    
    
    
    var padding: CGFloat = 2.0
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.view.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentAnimationIndex]
                let layer = segment.view.layer
                let pausedTime = layer.timeOffset
                layer.speed = 1.0
                layer.timeOffset = 0.0
                layer.beginTime = 0.0
                let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
                layer.beginTime = timeSincePause
            }
        }
    }
    
    private var segments = [SSegment]()
    private var maxDuration: TimeInterval = 5.0
    private var currentAnimationIndex = 0
    
    
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
        self.layer.cornerRadius = 0.5 * self.bounds.height
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
 
        
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.width = width
            segment.view.frame = segFrame
            
            let cr = frame.height / 2
            segment.view.layer.cornerRadius = cr
        }
        
    }
    
    public func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    private func animate(animationIndex: Int = 0) {
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        self.isPaused = false // no idea why we have to do this here, but it fixes everything :D
        

        CATransaction.begin()
        
        let anim = CABasicAnimation(keyPath: "bounds.size.width")
        anim.duration = 2
        
        var fromBounds = nextSegment.view.bounds
        fromBounds.size.width = 0
        var toBounds = nextSegment.view.bounds
        toBounds.size.width = nextSegment.width
        anim.fromValue = 0
        anim.toValue = nextSegment.width
        
        CATransaction.setCompletionBlock { [weak self] in
            self?.next()
        }
        
        nextSegment.view.layer.add(anim, forKey: "bounds")
        CATransaction.commit()
    }
    
    private func updateColors() {
        for segment in segments {
            segment.view.backgroundColor = topColor
        }
    }
    
    private func next() {
        let newIndex = self.currentAnimationIndex + 1
        if newIndex < self.segments.count {
            self.animate(animationIndex: newIndex)
        } else {
    
        }
    }
    
    func skip() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.view.frame.size.width = currentSegment.width
        currentSegment.view.layer.removeAllAnimations()
        self.next()
    }
    
    func rewind() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.view.layer.removeAllAnimations()
        currentSegment.view.frame.size.width = 0
        let newIndex = max(currentAnimationIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.view.frame.size.width = 0
        self.animate(animationIndex: newIndex)
    }
    
    
}

fileprivate class SSegment {
    let view = UIView()
    var duration: CGFloat = 0.0
    var width: CGFloat = 0.0
    
    let separator = SSeparator()
    init() {
        view.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
    }
}

fileprivate class SSeparator {
    let view = UIView()
    var width: CGFloat = 1.0
    init() {
        
    }
}


