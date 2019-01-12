//
//  SSegmentRecordingView.swift
//  SSegmentRecordingView
//
//  Created by Saul Moreno Abril on 11/01/2019.
//

import UIKit

@objc public class SSegmentRecordingView: UIView {
    
    // MARK: - Public
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
    
    @objc public func setInitialSegments(durations:[TimeInterval]) {
        // Clear old views
        clearSegments()
        
        // Create segments and sepators
        var time: TimeInterval = 0
        for (_, duration) in durations.enumerated() {
            if (maxDuration < time + duration) {
                break;
            }
            time += duration
            
            let segment = SSegment(duration: duration)
            segment.separator.layer.lineWidth = separatorWidth
            
            segments.append(segment)
            
            layer.addSublayer(segment.layer)
            layer.addSublayer(segment.separator.layer)
        }
        updateColors()
        
        // Set current to last
        currentIndex = durations.count
    }
    
    @objc public var currentDuration : TimeInterval {
        return segments.reduce(0, { (result, segment) in
            return result + segment.duration
        })
    }
    
    // MARK: - Private
    
    private var maxDuration: TimeInterval = 5.0
    private var segments = [SSegment]()
    private var separatorWidth: CGFloat = 2.5 {
        didSet {
            segments.forEach { (segment) in
                segment.separator.layer.lineWidth = separatorWidth
            }
        }
    }
    private var currentIndex = 0 {
        didSet {
            for (index, segment) in segments.enumerated() {
                if (index < currentIndex) {
                    segment.isOpened = false
                } else {
                    segment.isOpened = true
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
        for segment in segments {
            let percent = CGFloat(segment.duration/maxDuration)
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
            segment.separator.layer.path = bezierPath.cgPath
            
            xOffset = finalXOffset
        }
    }
    
    //MARK: -  Segments
    
    private func clearSegments() {
        for segment in segments {
            segment.layer.removeFromSuperlayer()
        }
        segments.removeAll()
        
        segments.forEach { (segment) in
            segment.layer.removeFromSuperlayer()
            segment.separator.layer.removeFromSuperlayer()
        }
    }
    
    
    //MARK: - Colors
    private func updateSegmentColors() {
        segments.forEach { (segment) in
            segment.layer.strokeColor = segmentColor.cgColor
        }
    }
    
    private func updateSeparatorColors() {
        segments.forEach { (segment) in
            segment.separator.layer.strokeColor = separatorColor.cgColor
        }
    }
    
    private func updateColors() {
        updateSegmentColors()
        updateSeparatorColors()
    }
    
    
    //MARK: - Animate
    
    public func startAnimation() {
        animate()
    }
    
    private func animate(animationIndex: Int = 0) {
        guard animationIndex < segments.count else {
            return
        }
        currentIndex = animationIndex
        
        let segment = segments[currentIndex]
        // Update model layer tree to final value
        segment.layer.strokeEnd = 1.0
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            segment.isOpened = false
            self?.next()
        }
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = segment.duration
        anim.fromValue = 0.0
        anim.toValue = 1.0
        segment.layer.add(anim, forKey: "strokeEnd")
        CATransaction.commit()
    }
    
    private func startNewSegment() {
        
    }
    
    func updateSegment(duration: TimeInterval) {
        
    }
    
    func closeSegment() {
        
    }
    
    private func next() {
        let newIndex = currentIndex + 1
        animate(animationIndex: newIndex)
    }
}

fileprivate class SSegment {
    var duration: TimeInterval = 0.0
    let layer = CAShapeLayer()
    let separator: SSeparator = SSeparator()
    
    var isOpened: Bool = false {
        didSet {
            if isOpened {
                layer.strokeEnd = 0.0
                separator.layer.strokeEnd = 0.0
            } else {
                layer.strokeEnd = 1.0
                separator.layer.strokeEnd = 1.0
            }
        }
    }
    
    init(duration: TimeInterval = 0.0) {
        self.duration = duration
        isOpened = false
        layer.fillColor = UIColor.clear.cgColor
    }
}

fileprivate class SSeparator {
    let layer = CAShapeLayer()
    init() {
        layer.fillColor = UIColor.clear.cgColor
        layer.zPosition = 10
    }
}


