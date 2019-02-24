//
//  ViewController.swift
//  SSegmentRecordingView
//
//  Created by asam139 on 01/11/2019.
//  Copyright (c) 2019 asam139. All rights reserved.
//

import UIKit
import SSegmentRecordingView

class ViewController: UIViewController {
    
    @IBOutlet weak var segmentRecordingView: SSegmentRecordingView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Set initials segments
        segmentRecordingView.setInitialSegments(durations: [1.0])
        
        // Start new segment
        var duration: TimeInterval = 0.0
        segmentRecordingView.startNewSegment()
        var timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            duration += 0.1
            self.segmentRecordingView.updateSegment(duration: duration)
        }
        timer.fire()
        
        // Remove current segment
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0) {
            timer.invalidate()
            self.segmentRecordingView.removeSegment()
        }
        
        // Start new segment
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2.0) {
            self.segmentRecordingView.startNewSegment()
            duration = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                duration += 0.1
                self.segmentRecordingView.updateSegment(duration: duration)
            }
        }
        
        // Close current segment
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 5) {
            timer.invalidate()
            self.segmentRecordingView.closeSegment()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

