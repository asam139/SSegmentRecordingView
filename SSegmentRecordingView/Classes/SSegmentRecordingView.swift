//
//  SSegmentRecordingView.swift
//  SSegmentRecordingView
//
//  Created by Saul Moreno Abril on 11/01/2019.
//

import UIKit

@objc public class SSegmentRecordingView: UIView {
    //MARK: - Public objects
    
    /**
        Segment color. Default is `.cyan`
    **/
    @objc public var segmentColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1) {
        didSet {
            updateSegmentColors()
        }
    }

    /**
        Separator color. Default is `.white`.
    **/
    @objc public var separatorColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) {
        didSet {
            updateSeparatorColors()
        }
    }
    
    /**
        Set up initial segments

        - Parameter durations: initial time of each segment
    **/
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
            
            _ = newSegment(duration: duration)
        }
        
        // Set current to last
        currentIndex = durations.count
    }
    
    
    /**
        Get current total duration (sum of all segments)
    **/
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
                segment.layer.removeAllAnimations()
                if (index < currentIndex) {
                    segment.state = .closed
                } else {
                    segment.state = .opened
                }
            }
        }
    }
    
    //MARK: - Public initialization methods
    
    @objc public init(frame: CGRect = CGRect.zero, duration: TimeInterval = 5.0) {
        super.init(frame: frame)
        self.maxDuration = duration
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
        configure()
    }
    
    //MARK: - Configure
    private func configure() {
        self.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.251927594)
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 0.5 * self.bounds.height
    }
    
    //MARK: - Public methods for start, update, pause and close segments
    
    @objc public func startNewSegment() {
        let segment = newSegment(duration: 0.0)
        segment.state = .opened
        currentIndex = segments.count - 1
    }
    
    @objc public func updateSegment(duration: TimeInterval) {
        var duration = duration
        let segment = segments[currentIndex]
        let delta = (duration - segment.duration)
        let current = currentDuration
        
        if current >= maxDuration {
            // Reached max
            print("Reached max: \(currentDuration)")
            return
        } else if current + delta >= maxDuration {
            // Adjust to get exact max duration
            duration += maxDuration - current - delta
        }
        segment.duration = duration
        
        guard let newPaths = pathsAt(index: currentIndex) else {
            return
        }
        let oldSegPath = segment.layer.path
        
        // Update model layer tree to final value
        segment.layer.path = newPaths.segment
        segment.separator.layer.path = newPaths.separator
        
        CATransaction.begin()
        let anim = CABasicAnimation(keyPath: "path")
        anim.duration = delta
        anim.fromValue = oldSegPath
        anim.toValue = newPaths.segment
        segment.layer.add(anim, forKey: "path")
        CATransaction.commit()
    }
    
    @objc public func updateSegment(delta: TimeInterval) {
        let segment = segments[currentIndex]
        updateSegment(duration: segment.duration + delta)
    }
    
    @objc public func pauseSegment() {
        let segment = segments[currentIndex]
        segment.state = .paused
    }
    
    @objc public func closeSegment() {
        let segment = segments[currentIndex]
        segment.state = .closed
    }
    
    //MARK: - Layout sublayers
    override public func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        var xOffset: CGFloat = 0
        for segment in segments {
            let percent = CGFloat(segment.duration/maxDuration)
            let width = frame.width * percent
            
            segment.layer.lineWidth = frame.height
            segment.layer.frame = layer.bounds
            
            // Segment path
            let paths = pathsForPoints(initX: xOffset, finalX: xOffset + width)
            segment.layer.path = paths.segment
            segment.separator.layer.path = paths.separator
            
            xOffset += width
        }
    }
    
    //MARK: -  Segments utils
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
    
    private func newSegment(duration: TimeInterval = 0.0) -> SSegment {
        let segment = SSegment(duration: duration)
        segment.separator.layer.lineWidth = separatorWidth
        segment.layer.strokeColor = segmentColor.cgColor
        segment.separator.layer.strokeColor = separatorColor.cgColor
        
        segments.append(segment)
        layer.addSublayer(segment.layer)
        layer.addSublayer(segment.separator.layer)
        
        return segment
    }
    
    //MARK: - Colors utils
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
    
    //MARK: - Paths utils
    
    private func pathsAt(index: Int) -> PathsTupla? {
        guard index < segments.count else {
            return nil
        }
        
        var paths:PathsTupla? = nil
        var xOffset: CGFloat = 0
        for (i, segment) in segments.enumerated() {
            let width = frame.width * CGFloat(segment.duration/maxDuration)
            // Segment path
            let finalXOffset = xOffset + width
            if (index == i) {
                paths = pathsForPoints(initX: xOffset, finalX: finalXOffset)
                break
            }
            xOffset = finalXOffset
        }
        
        return paths
    }
    
    private func pathsForPoints(initX: CGFloat, finalX: CGFloat) -> PathsTupla {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: initX, y: 0.5 * frame.height))
        bezierPath.addLine(to: CGPoint(x: finalX, y: 0.5 * frame.height))
        let segmentPath = bezierPath.cgPath

        // Segment path
        bezierPath.removeAllPoints()
        bezierPath.move(to: CGPoint(x: finalX, y: 0))
        bezierPath.addLine(to: CGPoint(x: finalX, y: frame.height))
        let separatorPath = bezierPath.cgPath

        return (segmentPath, separatorPath)
    }
}

fileprivate enum SSegmentState : Int {
    /// Segment is closed
    case closed
    /// Segment is opened
    case opened
    /// Segment is paused.
    case paused
}

fileprivate class SSegment {
    //MARK: - Properties
    var duration: TimeInterval = 0.0
    let layer = CAShapeLayer()
    let separator: SSeparator = SSeparator()
    
    var state: SSegmentState = .closed {
        didSet {
            
            switch state {
            case .closed:
                layer.strokeEnd = 1.0
                separator.layer.strokeEnd = 1.0
                separator.isBlinking = false
                break
            case .opened:
                layer.strokeEnd = 1.0
                separator.layer.strokeEnd = 0.0
                separator.isBlinking = false
                break
            case .paused:
                layer.strokeEnd = 1.0
                separator.layer.strokeEnd = 1.0
                separator.isBlinking = true
                
                break
            }
        }
    }
    
    //MARK: - Initializers
    
    init(duration: TimeInterval = 0.0) {
        self.duration = duration
        state = .closed
        layer.fillColor = UIColor.clear.cgColor
    }
}

fileprivate class SSeparator {
    //MARK: - Properties
    let layer = CAShapeLayer()
    
    //MARK: - Initializers
    
    init() {
        layer.fillColor = UIColor.clear.cgColor
        layer.zPosition = 10
    }
    
    //MARK: - Blink
    
    var blinkDuration: TimeInterval = 2.0 {
        didSet {
            updateBlinking()
        }
    }
    var isBlinking: Bool = false {
        didSet {
            updateBlinking()
        }
    }
    
    private func updateBlinking() {
        if !isBlinking {
            layer.removeAllAnimations()
            layer.opacity = 1.0
            return
        }
        
        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1
        fadeOut.toValue = 0.1
        fadeOut.duration = 0.5 * blinkDuration
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.1
        fadeIn.toValue = 1
        fadeIn.duration = 0.5 * blinkDuration
        fadeIn.beginTime = 0.5 * blinkDuration
        
        let group = CAAnimationGroup()
        group.duration = blinkDuration
        group.repeatCount = Float.infinity
        group.animations = [fadeOut, fadeIn]
        
        layer.add(group, forKey: "blink")
    }
}

fileprivate typealias PathsTupla = (segment: CGPath, separator: CGPath)


