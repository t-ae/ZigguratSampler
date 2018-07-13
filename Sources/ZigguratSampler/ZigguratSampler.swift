import Foundation

public struct ZigguratSampler {
    
    static let numLayers: Int = 256
    
    let xs: [Double]
    let ys: [Double]
    
    public init() {
        (self.xs, self.ys) = ZigguratSampler.constructZiggurat()
    }
    
    static func constructZiggurat() -> (xs: [Double], ys: [Double]) {
        var xs = [Double](repeating: .nan, count: numLayers)
        var ys = [Double](repeating: .nan, count: numLayers)
        
        xs[0] = 3.6542
        ys[0] = pdf(xs[0])
        
        // Manually adjusted, between 1-Φ(0.365) and 1-Φ(0.366)
        let area = xs[0]*pdf(xs[0]) + 0.00012935
        
        for i in 1..<numLayers {
            let height = area / xs[i-1]
            ys[i] = ys[i-1] + height
            xs[i] = pdf_inv(ys[i])
        }
        
        // last becomes nan, specify manually
        xs[numLayers-1] = 0
        
        // last layer must cover top of pdf
        precondition(ys.last! >= pdf(0))

        return (xs, ys)
    }
    
    static func pdf(_ x: Double) -> Double {
        return exp(-x*x/2) / sqrt(2 * .pi)
    }
    
    // inverse of exp(-x^2/2) / sqrt(2pi)
    static func pdf_inv(_ y: Double) -> Double {
        return sqrt(-log(2 * .pi * y * y))
    }
    
    public func next<R: RandomNumberGenerator>(using: inout R) -> Double {
        while true {
            let layer = Int.random(in: 0..<ZigguratSampler.numLayers-1)
            let x = Double.random(in: -xs[layer]..<xs[layer])
            
            if abs(x) < xs[layer+1] {
                return x
            } else if layer == 0 {
                // sample from tail
                let x = -log(Double.random(in: Double.leastNonzeroMagnitude..<1)) / xs[0]
                let y = -log(Double.random(in: Double.leastNonzeroMagnitude..<1))
                if 2*y >= x*x {
                    return [x + xs[0], -x - xs[0]].randomElement()!
                }
            } else {
                let y = Double.random(in: ys[layer]..<ys[layer+1])
                if ZigguratSampler.pdf(x) > y {
                    return x
                }
            }
        }
    }
    
    public func next() -> Double {
        return next(using: &Random.default)
    }
}
