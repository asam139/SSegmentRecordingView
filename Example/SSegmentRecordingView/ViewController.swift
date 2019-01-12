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
        
        segmentRecordingView.startAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

