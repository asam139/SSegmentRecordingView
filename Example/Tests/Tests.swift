// https://github.com/Quick/Quick

import Quick
import Nimble
import SSegmentRecordingView

class SSegmentRecordingViewSpec: QuickSpec {
    override func spec() {
        describe("a segment view") {
            var segmentView: SSegmentRecordingView!
        
            
            it("is initialized correctly with max duration") {
                let maxDuration = 10.0
                segmentView = SSegmentRecordingView(frame: CGRect(x: 0, y: 0, width: 100, height: 8), duration: maxDuration)
                expect(segmentView.maxDuration) == maxDuration
            }
            
            describe("when starts") {
                beforeEach {
                    segmentView = SSegmentRecordingView()
                    segmentView.setInitialSegments(durations: [])
                }
                
                it("is empty") {
                    let count = segmentView.segmentsCount;
                    expect(count) == 0
                }
                
                it("is duration is zero") {
                    let duration = segmentView.currentDuration;
                    expect(duration) == 0
                }
                
                it("is max duration can be changed") {
                    let maxDuration = 10.0;
                    segmentView.maxDuration = maxDuration
                    expect(segmentView.maxDuration) == maxDuration
                }
                
                it("is segment color can be changed") {
                    let color = #colorLiteral(red: 1, green: 0.2705882353, blue: 0.2274509804, alpha: 1);
                    segmentView.segmentColor = color
                    expect(segmentView.segmentColor) == color
                }
                
                it("is sepator color can be changed") {
                    let color = #colorLiteral(red: 1, green: 0.8392156863, blue: 0.03921568627, alpha: 1);
                    segmentView.separatorColor = color
                    expect(segmentView.separatorColor) == color
                }
                
                it("is sepator width can be changed") {
                    let newWidth: CGFloat = 3.0;
                    segmentView.separatorWidth = newWidth
                    expect(segmentView.separatorWidth) == newWidth
                }
                
            }
            
            describe("when is initialized") {
                beforeEach {
                    segmentView = SSegmentRecordingView()
                }
                
                context("when durations is smaller than max duration") {
                    let maxDuration = 10.0
                    let durations = [maxDuration / 5.0, maxDuration / 5.0] // 2 + 4 < 10
                    beforeEach {
                        segmentView.maxDuration = maxDuration
                        segmentView.setInitialSegments(durations: durations)
                    }
                    
                    it("its segments matched") {
                        let count = segmentView.segmentsCount;
                        expect(count) == durations.count
                    }
                    
                    it("its duration matched") {
                        let duration = segmentView.currentDuration;
                        let totalDuration = durations.reduce(0, { (result, value) in
                            result + value
                        })
                        expect(duration) == totalDuration
                    }
                }
                
                context("when durations is greater than max duration") {
                    let maxDuration = 5.0
                    let durations = [maxDuration / 2.0, maxDuration] // 2.5 + 5 > 5
                    beforeEach {
                        segmentView.maxDuration = maxDuration
                        segmentView.setInitialSegments(durations: durations)
                    }
                    
                    it("its duration is less than equal the max") {
                        expect(segmentView.currentDuration) <= maxDuration
                    }
                }
            }
            
            describe("when starts a new segment") {
                var oldCount:Int!
                beforeEach {
                    segmentView = SSegmentRecordingView()
                    
                    oldCount = segmentView.segmentsCount
                    segmentView.startNewSegment()
                }
                
                it("segments count increased") {
                    let count = segmentView.segmentsCount;
                    expect(count) == oldCount + 1
                }
                
                
                describe("can be updated") {
                    beforeEach {
                        
                    }
                    
                    it("using new duration") {
                        let duration = 1.0
                        segmentView.updateSegment(duration: duration)
                        
                        expect(segmentView.currentSegmentDuration) == duration
                    }
                    
                    it("with delta") {
                        let currentDuration = segmentView.currentSegmentDuration
                        let delta = 0.5
                        segmentView.updateSegment(delta: delta)
                        
                        expect(segmentView.currentSegmentDuration) == currentDuration + delta
                    }
                    
                }
                
                describe("its state can be") {
                    beforeEach {
                         segmentView.updateSegment(duration: 1.0)
                    }
                    
                    it("paused") {
                        segmentView.pauseSegment()
                        expect(segmentView.currentSegmentState) == .paused
                    }
                    
                    it("closed") {
                        segmentView.closeSegment()
                        expect(segmentView.currentSegmentState) == .closed
                    }
                    
                    it("final") {
                        segmentView.updateSegment(duration: segmentView.maxDuration + 1)
                        expect(segmentView.currentSegmentState) == .final
                    }
                }
                
                it("can be removed") {
                    segmentView.removeSegment()
                    expect(segmentView.segmentsCount) == oldCount
                }
                
                it("can be reseted") {
                    segmentView.setInitialSegments(durations: [])
                    expect(segmentView.segmentsCount) == 0
                }
                
            }
        }
    }
}
