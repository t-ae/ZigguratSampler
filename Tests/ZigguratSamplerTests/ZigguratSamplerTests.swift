import XCTest
@testable import ZigguratSampler

final class ZigguratSamplerTests: XCTestCase {
    func testInit() {
        let sampler = ZigguratSampler()
        _ = sampler.next()
    }
    
    func testInit_specifyLayers() {
        let sampler = ZigguratSampler(numLayers: 32)
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
                let u1 = Double.random(in: .leastNonzeroMagnitude..<1)
                let r = sqrt(-2 * log(u1))
                let u2 = Double.random(in: .leastNonzeroMagnitude..<2 * .pi)
                x[2*i+0] = r * sin(u2)
                x[2*i+1] = r * cos(u2)
            }
        }
    }
}
