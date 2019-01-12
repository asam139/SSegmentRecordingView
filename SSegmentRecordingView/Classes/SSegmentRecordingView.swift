//
//  SSegmentRecordingView.swift
//  SSegmentRecordingView
//
//  Created by Saul Moreno Abril on 11/01/2019.
//

import UIKit

@objc public class SSegmentRecordingView: UIView {
    
    // MARK: - Public
    
    
    var topColor = UIColor.gray {
        didSet {
            self.updateColors()
        }
    }
    
    var padding: CGFloat = 2.0
    var isPaused: Bool = false {
        didSet {
            if isPaused {
                for segment in segments {
                    let layer = segment.topSegmentView.layer
                    let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
                    layer.speed = 0.0
                    layer.timeOffset = pausedTime
                }
            } else {
                let segment = segments[currentAnimationIndex]
                let layer = segment.topSegmentView.layer
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
    private let duration: TimeInterval
    private var hasDoneLayout = false // hacky way to prevent layouting again
    private var currentAnimationIndex = 0
    
    
    // MARK: - Initializers
    
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        configure()
        
        for _ in 0..<numberOfSegments {
            let segment = SSegment()
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        
        
        
        self.updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.duration = 10
        super.init(coder: aDecoder)
        
        configure()
        
        for _ in 0..<3 {
            let segment = SSegment()
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        self.updateColors()
    }
    
    
    private func configure() {
        self.backgroundColor = UIColor.init(white: 1.0, alpha: 0.25)
        self.layer.cornerRadius = 0.5 * self.bounds.height
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.width = width
            segment.topSegmentView.frame = segFrame
            segment.topSegmentView.frame.size.width = 0
            
            let cr = frame.height / 2
            segment.topSegmentView.layer.cornerRadius = cr
        }
        hasDoneLayout = true
    }
    
    public func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    private func animate(animationIndex: Int = 0) {
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        self.isPaused = false // no idea why we have to do this here, but it fixes everything :D
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            nextSegment.topSegmentView.frame.size.width = nextSegment.width
        }) { (finished) in
            if !finished {
                return
            }
            self.next()
        }
    }
    
    private func updateColors() {
        for segment in segments {
            segment.topSegmentView.backgroundColor = topColor
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
        currentSegment.topSegmentView.frame.size.width = currentSegment.width
        currentSegment.topSegmentView.layer.removeAllAnimations()
        self.next()
    }
    
    func rewind() {
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        self.animate(animationIndex: newIndex)
    }
    
    
}

fileprivate class SSegment {
    let topSegmentView = UIView()
    var width: CGFloat = 0.0
    init() {
    
    }
}

fileprivate class SSeparator {
    let separatorView = UIView()
    var width: CGFloat = 0.0
    init() {
        
    }
}


