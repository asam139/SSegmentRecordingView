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
                let separator = SSeparator()
                separator.layer.lineWidth = separatorWidth
                segment.separator = separator
                
                segments.append(segment)
                separators.append(separator)
                
                layer.addSublayer(segment.layer)
                layer.addSublayer(separator.layer)
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
    
    // MARK: - Private
    
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
                let segment = segments[index]
                if (index <= currentIndex) {
                    segment.layer.strokeEnd = 1.0
                } else {
                    segment.layer.strokeEnd = 0.0
                }
                
                let separator = separators[index]
                if (index < currentIndex) {
                    separator.layer.strokeEnd = 1.0
                } else {
                    separator.layer.strokeEnd = 0.0
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
    
    
    //MARK: - Animate
    
    public func startAnimation() {
        animate()
    }
    
    private func animate(animationIndex: Int = 0) {
        guard animationIndex < segmentsDuration.count else {
            currentIndex = animationIndex <= segmentsDuration.count ? currentIndex + 1 : segmentsDuration.count
            return
        }
        currentIndex = animationIndex
        
        let segment = segments[currentIndex]
        CATransaction.begin()
        CATransaction.setCompletionBlock { [weak self] in
            self?.next()
        }
        
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.duration = segmentsDuration[animationIndex]
        anim.fromValue = 0.0
        anim.toValue = 1.0
        segment.layer.add(anim, forKey: "bounds")
        CATransaction.commit()
    }
    
    private func next() {
        let newIndex = currentIndex + 1
        animate(animationIndex: newIndex)
    }
}

fileprivate class SSegment {
    let layer = CAShapeLayer()
    weak var separator: SSeparator?
    init() {
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


