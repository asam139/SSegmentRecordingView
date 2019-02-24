// https://github.com/Quick/Quick

import Quick
import Nimble
import SSegmentRecordingView

class SSegmentRecordingViewSpec: QuickSpec {
    override func spec() {
        describe("a segment view") {
            var segmentView: SSegmentRecordingView!
            beforeEach {
                segmentView = SSegmentRecordingView()
            }
            
            describe("when starts") {
                it("is empty") {
                    print("aaaaa")
                    let count = segmentView.segmentsCount;
                    expect(count) == 0
                }
                
                it("is duration is zero") {
                    let duration = segmentView.currentDuration;
                    expect(duration) == 0
                }
            }
            
            describe("when is iniatilazed") {
                let durations = [1.0, 2.0]
                beforeEach {
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
            
            describe("when starts a new one") {
                var oldCount:Int!
                beforeEach {
                    oldCount = segmentView.segmentsCount
                    segmentView.startNewSegment()
                }
                
                it("its segments count increased") {
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
                
            }
            
            /*it("can do maths") {
                expect(1) == 2
            }

            it("can read") {
                expect("number") == "string"
            }

            it("will eventually fail") {
                expect("time").toEventually( equal("done") )
            }
            
            context("these will pass") {

                it("can do maths") {
                    expect(23) == 23
                }

                it("can read") {
                    expect("🐮") == "🐮"
                }

                it("will eventually pass") {
                    var time = "passing"

                    DispatchQueue.main.async {
                        time = "done"
                    }

                    waitUntil { done in
                        Thread.sleep(forTimeInterval: 0.5)
                        expect(time) == "done"

                        done()
                    }
                }
            }*/
        }
    }
}
