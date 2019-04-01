//
//  SSegmentRecordingView.swift
//  SSegmentRecordingView
//
//  Created by Saul Moreno Abril on 11/01/2019.
//

import UIKit

@objc @IBDesignable
public class SSegmentRecordingView: UIView {
    //MARK: - Public objects
    
    @objc @IBInspectable
    public var maxDuration: Double = 5.0 {
        didSet {
            setInitialSegments(durations: [])
        }
    }
    
    /**
        A color to fill segments. Default is `.cyan`,
    **/
    @objc @IBInspectable
    public var segmentColor: UIColor = #colorLiteral(red: 0, green: 0.9914394021, blue: 1, alpha: 1) {
        didSet {
            updateSegmentColors()
        }
    }

    /**
        A color to fill separators. Default is `.white`.
    **/
    @objc @IBInspectable
    public var separatorColor: UIColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) {
        didSet {
            updateSeparatorColors()
        }
    }
    
    /**
        A float to change line width for separators. Default is `2.5`.
    **/
    @objc @IBInspectable
    public var separatorWidth: CGFloat = 2.5 {
        didSet {
            segments.forEach { (segment) in
                segment.separator.layer.lineWidth = separatorWidth
            }
        }
    }
    
    /**
        Set up initial segments.

        - Parameter durations: initial time of each segment.
    **/
    @objc public func setInitialSegments(durations:[Double]) {
        // Clear old views
        clearSegments()
        
        // Create segments and sepators
        var time: Double = 0
        for (_, duration) in durations.enumerated() {
            if (maxDuration < time + duration) {
                break;
            }
            time += duration
            
            _ = newSegment(duration: duration)
        }
        
        // Set current index out of array
        currentIndex = durations.count
    }
    
    /**
     Get segments count
     **/
    @objc public var segmentsCount : Int {
        return segments.count
    }
    
    /**
        Get current total duration (sum of all segments)
    **/
    @objc public var currentDuration : Double {
        return segments.reduce(0, { (result, segment) in
            return result + segment.duration
        })
    }
    
    //MARK: - Public initialization methods
    
    @objc public init(frame: CGRect = CGRect.zero, duration: Double = 5.0) {
        super.init(frame: frame)
        self.maxDuration = duration
        sharedInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    public convenience init() {
        self.init(frame: CGRect.zero)
        sharedInit()
    }
    
    override public func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    //MARK: - Configure
    private func sharedInit() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 0.5 * self.bounds.height
        
        updateSegmentColors()
        updateSeparatorColors()
    }
    
    // MARK: - Private
    private var segments = [SSegment]()
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
    
    //MARK: - Public methods for start, update, pause and close segments
    
    /**
        A method that starts a new segment
    **/
    @objc public func startNewSegment() {
        if currentDuration >= maxDuration {
            return
        }
        
        let segment = newSegment(duration: 0.0)
        segment.state = .opened
        currentIndex = segments.count - 1
    }
    
    /**
        A method to update segment's duration

        - Parameter duration: new value duration
    **/
    @objc public func updateSegment(duration: Double) {
        guard currentIndex < segments.count else {
            return
        }
        
        let current = currentDuration
        guard current < maxDuration else {
            // Reached max
            return
        }
        
        var duration = duration
        let segment = segments[currentIndex]
        let delta = (duration - segment.duration)
        if current + delta >= maxDuration {
            // Adjust to get exact max duration
            duration += maxDuration - current - delta
            segment.duration = duration
            segment.state = .final
        } else {
            segment.duration = duration
            segment.state = .opened
        }
        
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
    
    /**
        A method to update segment's duration using a delta value

        - Parameter delta: delta value which can be positive or negative
    **/
    @objc public func updateSegment(delta: Double) {
        guard currentIndex < segments.count else {
            return
        }
        
        let segment = segments[currentIndex]
        updateSegment(duration: segment.duration + delta)
    }
    
    /**
        A method to pause segment showing a blink animation
    **/
    @objc public func pauseSegment() {
        guard currentIndex < segments.count else {
            return
        }
        
        let segment = segments[currentIndex]
        guard segment.state == .opened else {
            return
        }
        segment.state = .paused
    }
    
    /**
        A method to close segment
     **/
    @objc public func closeSegment() {
        guard currentIndex < segments.count else {
            return
        }
        
        let segment = segments[currentIndex]
        guard segment.state == .opened ||
              segment.state == .paused else {
            return
        }
        
        segment.state = .closed
    }
    
    /**
     A method to remove current segment
     **/
    @objc public func removeSegment() {
        guard currentIndex < segments.count else {
            return
        }
        
        // Clear segment
        clearSegmentAtIndex(index: currentIndex)
        
        // Adjust current index
        let count = segments.count
        if (currentIndex >= count) {
            currentIndex = count + 1
        }
    }
    
    /**
     Get duration of a segment
     **/
    @objc public func segmentDurationAt(index: Int) -> Double {
        guard currentIndex < segments.count else {
            return 0.0
        }
        
        let segment = segments[index]
        return segment.duration
    }
    
    /**
     Get duration of current segment
     **/
    @objc public var currentSegmentDuration: Double {
        return segmentDurationAt(index: currentIndex)
    }
    
    /**
     Get state of a segment
     **/
    @objc public func segmentStateAt(index: Int) -> SSegmentState {
        guard currentIndex < segments.count else {
            return .closed
        }
        
        let segment = segments[index]
        return segment.state
    }
    
    /**
     Get duration of current segment
     **/
    @objc public var currentSegmentState: SSegmentState {
        return segmentStateAt(index: currentIndex)
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
        segments.forEach { (segment) in
            segment.layer.removeFromSuperlayer()
            segment.separator.layer.removeFromSuperlayer()
        }
        segments.removeAll()
    }
    
    private func clearSegmentAtIndex(index: Int) {
        guard index < segments.count else {
            return
        }
        let segment = segments.remove(at: index)
        segment.layer.removeFromSuperlayer()
        segment.separator.layer.removeFromSuperlayer()
    }
    
    private func newSegment(duration: Double = 0.0) -> SSegment {
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

@objc public enum SSegmentState : Int {
    /// Segment is closed
    case closed
    /// Segment is opened
    case opened
    /// Segment is paused.
    case paused
    /// Segment is final.
    case final
}

fileprivate class SSegment {
    //MARK: - Properties
    var duration: Double = 0.0
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
            case .final:
                layer.strokeEnd = 1.0
                separator.layer.strokeEnd = 0.0
                separator.isBlinking = false
                break
            }
        }
    }
    
    //MARK: - Initializers
    
    init(duration: Double = 0.0) {
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
    
    var blinkDuration: Double = 2.0 {
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
        fadeOut.toValue = 0.5
        fadeOut.duration = 0.5 * blinkDuration
        
        let fadeIn = CABasicAnimation(keyPath: "opacity")
        fadeIn.fromValue = 0.5
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


