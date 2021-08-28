import Numerics

extension Real {
    static func sigmoid(_ x: Self) -> Self {
        1 / (1 + .exp(-x))
    }
}

// [layer][target node][source node]
// 3 layers: input (8 nodes), hidden (3 nodes), output (8 nodes)
var weights = [
    (0..<3).map { _ in
        (0..<8).map { _ in
            Double.random(in: -0.1...0.1)
        }
    },
    (0..<8).map { _ in
        (0..<3).map { _ in
            Double.random(in: -0.1...0.1)
        }
    }
]

let learningRate = 0.1
let numIterations = 10000
let trainingExamples = [
    [1.0, 0, 0, 0, 0, 0, 0, 0],
    [0, 1.0, 0, 0, 0, 0, 0, 0],
    [0, 0, 1.0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1.0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1.0, 0, 0, 0],
    [0, 0, 0, 0, 0, 1.0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1.0, 0],
    [0, 0, 0, 0, 0, 0, 0, 1.0],
]

func forward(inputs: [Double], weights: [[Double]]) -> [Double] {
    weights.map { nodeWeights in
        zip(inputs, nodeWeights)
            .map(*)
            .reduce(0, +)
    }.map(Double.sigmoid)
}

for _ in 0..<numIterations {
    for (xs, ts) in zip(trainingExamples, trainingExamples) {
        // propagate the input forward through the network
        let hidden = forward(inputs: xs, weights: weights[0])
        let output = forward(inputs: hidden, weights: weights[1])

        // propagate the errors backward through the network
        let outputErrors = zip(output, ts).map { (o, t) in
            o * (1 - o) * (t - o)
        }
        
        let hiddenErrors = hidden.enumerated().map { (h, o) -> Double in
            let err = zip(weights[1].map { $0[h] }, outputErrors).map(*).reduce(0, +)
            return o * (1 - o) * err
        }
        
        for j in 0..<3 {
            for i in 0..<8 {
                weights[0][j][i] += learningRate * hiddenErrors[j] * xs[i]
            }
        }
        
        for j in 0..<8 {
            for i in 0..<3 {
                weights[1][j][i] += learningRate * outputErrors[j] * hidden[i]
            }
        }
    }
}

extension Array where Element == Double {
    var digits: String {
        self.map { $0 < 0.5 ? "0" : "1" }.joined()
    }
}

for xs in trainingExamples {
    let hidden = forward(inputs: xs, weights: weights[0])
    let output = forward(inputs: hidden, weights: weights[1])
    print(xs.digits, hidden, output.digits, xs.digits == output.digits)
}
