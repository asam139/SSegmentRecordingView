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
                addSubview(segment.view)
                segments.append(segment)
                
                let separator = SSeparator()
                addSubview(separator.view)
                separators.append(separator)
            }
            
            // Bring separators to front
            separators.forEach { (separator) in
                separator.view.superview?.bringSubviewToFront(separator.view)
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
    
    private var separatorWidth: CGFloat = 2.5
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
                let segment = segments[currentIndex]
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
    
    private var maxDuration: TimeInterval = 5.0
    private var segments = [SSegment]()
    private var separators = [SSeparator]()
    private var currentIndex = 0
    
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
    
    override public func layoutSubviews() {
        super.layoutSubviews()
 
        var xOffset: CGFloat = 0
        for (index, segment) in segments.enumerated() {
            let percent = CGFloat(segmentsDuration[index]/maxDuration)
            let width = frame.width * percent
            let segFrame = CGRect(x: xOffset, y: 0, width: width, height: frame.height)
            segment.view.frame = segFrame
            //segment.view.layer.cornerRadius = 0.5 * frame.height
            
            xOffset += width
            
            let sepFrame = CGRect(x: xOffset - 0.5 * separatorWidth, y: 0, width: separatorWidth, height: frame.height)
            let separator = separators[index]
            separator.view.frame = sepFrame
        }
    }
    
    //MARK: -  Segments
    
    private func clearSegments() {
        for segment in segments {
            segment.view.removeFromSuperview()
        }
        segments.removeAll()
    }
    
    
    
    //MARK: -  Separator
    
    private func clearSeparators() {
        for separator in separators {
            separator.view.removeFromSuperview()
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
            segment.view.backgroundColor = segmentColor
        }
    }
    
    private func updateSeparatorColors() {
        for separator in separators {
            separator.view.backgroundColor = separatorColor
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
        
        let nextSegment = segments[animationIndex]
        currentIndex = animationIndex
        self.isPaused = false // no idea why we have to do this here, but it fixes everything :D
        

        CATransaction.begin()
        
        let anim = CABasicAnimation(keyPath: "bounds.size.width")
        anim.duration = 2
        anim.fromValue = 0
        anim.toValue = nextSegment.view.frame.width
        
        CATransaction.setCompletionBlock { [weak self] in
            self?.next()
        }
        
        nextSegment.view.layer.add(anim, forKey: "bounds")
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
        currentSegment.view.frame.size.width = currentSegment.view.frame.width
        currentSegment.view.layer.removeAllAnimations()
        self.next()
    }
    
    func rewind() {
        let currentSegment = segments[currentIndex]
        currentSegment.view.layer.removeAllAnimations()
        currentSegment.view.frame.size.width = 0
        let newIndex = max(currentIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.view.frame.size.width = 0
        animate(animationIndex: newIndex)
    }
    
    
}

fileprivate class SSegment {
    let view = UIView()
    init() {
        view.layer.anchorPoint = CGPoint(x: 0, y: 0.5)
    }
}

fileprivate class SSeparator {
    let view = UIView()
    init() {
        
    }
}


