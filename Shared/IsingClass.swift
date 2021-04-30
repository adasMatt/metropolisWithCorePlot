//
//  IsingClass.swift
//  metropolisAlgorithm
//
//  Created by Matthew Adas on 4/2/21.
//

// probably want to change some of these values, or make them user selectable huh :(


import Foundation
import SwiftUI

class IsingClass: ObservableObject {
    
    //var N = 1000
//    var B = -1.0                     // should be user selectable/input?
//    var mu = 0.33
//    var J = 1.0
//    var k = 1.0
    var B = 1.0                     // should be user selectable/input?
    var mu = 0.33
    var J = 1.0
    var k = 1.0
    
    func energyCalculation(S: [Double], N: Int) -> Double {
        var firstTerm = 0.0
        var secondTerm = 0.0
        
        for i in 0..<(N-1) {
            //numbers.append(1)
            firstTerm += Double(S[i] * S[i+1])
        }
        
        // boundary
        firstTerm += Double(S[0] * S[N-1])
        
        // multiply exchange energy
        firstTerm *= -J
        
        for i in 0..<N {
            secondTerm += Double(S[i])
        }
        
        secondTerm *= -B*mu
        
        return (firstTerm + secondTerm)
    }
        
}       


