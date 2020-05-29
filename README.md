
<p align="center" >
  <img src="https://raw.github.com/asam139/SSegmentRecordingView/master/assets/ssegmentrecordingview_logo.png" alt="SSegmentRecordingView" title="SSegmentRecordingView">
</p>


[![CI Status](https://img.shields.io/travis/asam139/SSegmentRecordingView.svg?style=flat)](https://travis-ci.org/asam139/SSegmentRecordingView)
[![codecov](https://codecov.io/gh/asam139/SSegmentRecordingView/branch/master/graph/badge.svg)](https://codecov.io/gh/asam139/SSegmentRecordingView)
[![Version](https://img.shields.io/cocoapods/v/SSegmentRecordingView.svg?style=flat)](https://cocoapods.org/pods/SSegmentRecordingView)
[![License](https://img.shields.io/cocoapods/l/SSegmentRecordingView.svg?style=flat)](https://cocoapods.org/pods/SSegmentRecordingView)
[![Platform](https://img.shields.io/cocoapods/p/SSegmentRecordingView.svg?style=flat)](https://cocoapods.org/pods/SSegmentRecordingView)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<p align="center" >
  <img src="https://raw.github.com/asam139/SSegmentRecordingView/master/assets/example.gif" alt="SSegmentRecordingViewGif" title="SSegmentRecordingViewGif">
</p>

```swift
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
```

## Installation
### Cocoapods
1. Add this line to your project's `Podfile` (for Swift 5.0)
```
pod 'SSegmentRecordingView'

```
2. Install the pod
```
$ pod install
```

### Swift Package Manager (available Xcode 11.2 and forward)

1. In Xcode, select File > Swift Packages > Add Package Dependency.
2. Follow the prompts using the URL for this repository.

## Contributions
If you have an idea for a new **SSegmentRecordingView** feature/functionality and want to add it to this repository, feel free to fork the project and create a pull request!

Also, feel free to create an issue if you have any suggestions or need any help ☺️

## License
### SSegmentRecordingView Framework
Copyright 2020 Saúl Moreno Abril, 93sauu@gmail.com

`SSegmentRecordingView` is licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
