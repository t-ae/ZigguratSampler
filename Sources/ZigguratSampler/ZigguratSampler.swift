import Foundation

public struct ZigguratSampler {
    
    let numLayers: Int
    let xs: [Double]
    let ys: [Double]
    
    public init(numLayers: Int = 256) {
        self.numLayers = numLayers
        
        // search
        var bestResult: (xs: [Double], ys: [Double], score: Double)!
        var x0: Double = 1
        while true {
            if let result = ZigguratSampler.constructZiggurat(x0, numLayers: numLayers) {
                bestResult = result
                print("Initial: \(bestResult.score), x0=\(x0)")
                break
            }
            x0 *= 2
        }
        
        var delta = x0 / 2
        for _ in 0..<32 {
            if let result = ZigguratSampler.constructZiggurat(x0 - delta, numLayers: numLayers) {
                x0 -= delta
                bestResult = result
                print("Update: \(bestResult.score) x0=\(x0)")
            }
            delta /= 2
        }
        self.xs = bestResult.xs
        self.ys = bestResult.ys
    }
    
    static func constructZiggurat(_ x0: Double, numLayers: Int) -> (xs: [Double], ys: [Double], score: Double)? {
        var xs = [Double](repeating: .nan, count: numLayers + 1)
        var ys = [Double](repeating: .nan, count: numLayers)
        
        let y0 = pdf(x0)
        let f0 = pdf(0)
        
        let area = x0 * y0
        
        // each (xs[i-1], ys[i]) defines the right-top of layer
        xs[0] = x0
        ys[0] = y0
        
        for i in 1..<numLayers {
            let height = area / xs[i-1]
            ys[i] = ys[i-1] + height
            guard ys[i] <= f0 else {
                return nil
            }
            xs[i] = pdf_inv(ys[i])
        }
        
        return (xs, ys, ys.last! / f0)
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
            let layer = Int.random(in: 0..<numLayers)
            let x = Double.random(in: -xs[layer]..<xs[layer])
            
            if abs(x) < xs[layer] {
                return x
            } else if layer == 0 {
                // sample from tail
                let x = -log(Double.random(in: Double.leastNonzeroMagnitude..<1)) / xs[0]
                let y = -log(Double.random(in: Double.leastNonzeroMagnitude..<1))
                if 2*y >= x*x {
                    return [x + xs[0], -x - xs[0]].randomElement()!
                }
            } else {
                let y = Double.random(in: ys[layer-1]..<ys[layer])
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
