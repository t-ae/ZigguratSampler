import XCTest
@testable import ZigguratSampler

final class ZigguratSamplerTests: XCTestCase {
    func testInit() {
        let sampler = ZigguratSampler()
        _ = sampler.next()
    }
    
    func testMoments() {
        let sampler = ZigguratSampler()
        
        let count = 10_000_000
        var sum: Double = 0
        var sum2: Double = 0
        for _ in 0..<count {
            let r = sampler.next()
            sum += r
            sum2 += r*r
        }
        let mean = sum / Double(count)
        let std = sqrt(sum2/Double(count) - mean*mean)
        XCTAssertEqual(mean, 0, accuracy: 1e-3)
        XCTAssertEqual(std, 1, accuracy: 1e-2)
    }
    
    func testPdf() {
        for x in stride(from: 0.1, to: 4.0, by: 0.1) {
            let y = ZigguratSampler.pdf(x)
            let x2 = ZigguratSampler.pdf_inv(y)
            XCTAssertEqual(x, x2, accuracy:  1e-8)
        }
    }
    
    func testPerformance() {
        let sampler = ZigguratSampler()
        let count = 1_000_000
        var x = [Double](repeating: 0, count: count)
        measure {
            for i in 0..<count {
                x[i] = sampler.next()
            }
        }
    }
    
    func testPerformance_box_muller() {
        let count = 1_000_000
        var x = [Double](repeating: 0, count: count)
        measure {
            for i in 0..<count/2 {
                var u1: Double
                repeat {
                    u1 = Double.random(in: 0..<1)
                } while u1 == 0
                
                var u2: Double
                repeat {
                    u2 = Double.random(in: 0..<2 * .pi)
                } while u2 == 0
                
                let r = sqrt(-2 * log(u1))
                x[2*i+0] = r * sin(u2)
                x[2*i+1] = r * cos(u2)
            }
        }
    }
    
    func testPerformance_polar() {
        let count = 1_000_000
        var x = [Double](repeating: 0, count: count)
        measure {
            for i in 0..<count/2 {
                var u1: Double
                var u2: Double
                var r: Double
                repeat {
                    u1 = .random(in: -1..<1)
                    u2 = .random(in: -1..<1)
                    r = u1*u1 + u2*u2
                } while r >= 1 || r == 0
                let l = sqrt(-2*log(r) / r)
                x[2*i+0] = l * u1
                x[2*i+1] = l * u2
            }
        }
    }
}
