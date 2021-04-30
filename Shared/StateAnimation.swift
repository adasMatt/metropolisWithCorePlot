//
//  stateAnimation.swift
//  Monte Carlo Integration
//
//  Created by Matt Adas on 4/2/21.
//

// /////////////////////////////////
// search: I removed this line is that bad?
// search: spinDownData ...for print statement
// /////////////////////////////////


import Foundation
import SwiftUI

class StateAnimationClass: NSObject, ObservableObject {

    // x values are simply "time step" (1000N) and y values are each member of the array (1 to N)
    @Published var spinUpData = [(xPoint: Double, yPoint: Double)]()
    @Published var spinDownData = [(xPoint: Double, yPoint: Double)]()
    //@ObservedObject var presentState = FlipRandomState()
   
    @Published var xMin = 0.0
    @Published var xMax = 100.0
    @Published var yMin = 0.0
    @Published var yMax = 100.0
    
    // this is a core plot thing that I don't need yet
    //var plotDataModel: PlotDataClass? = nil
    
    init(withData data: Bool) {
        
        super.init()
        
       // spinUpData = [(1.0, 5.0)]
        //spinDownData = [(3.5, 6.5), (4.0, 6.5)]
        
        print("initialized")
        
        // I removed this line is that bad?
        //spinUpData = []
        //spinDownData = []
    }
    
    func plotState (state: [Double], n: Double) {
        
        //let boundingBoxCalculator = BoundingBox() ///Instantiates Class needed to calculate the area of the bounding box.
        
        //boundingBoxCalculator.calculateSurfaceArea(numberOfSides: 2, lengthOfSide1: (xMax-xMin), lengthOfSide2:(yMax-yMin), lengthOfSide3: 0.0)
        
        var point = (xPoint: 0.0, yPoint: 0.0)
        
        // spinUpPoints (red), spinDownPoints (blue)
        var spinUpPoints : [(xPoint: Double, yPoint: Double)] = []
        var spinDownPoints : [(xPoint: Double, yPoint: Double)] = []
        
        point.xPoint = n        // always just M from flipRandomState.randomNumber()
                                // y points are 0...N-1
        
        // go through [state] and figure out spin UP and spin DOWN points
        for item in (0...state.count-1) {
            
            point.yPoint = Double(item)
            
            if (abs(state[item] - (-1.0))) < Double(-1.0).ulp {          // spin up, red
                spinUpPoints.append(point)
                //spinUpPoints.append((point.xPoint, point.yPoint+0.25))
            }
            
            else {
                spinDownPoints.append((point.xPoint, point.yPoint))
            }
            
        }
        
        //print("\n\n spin down data: \(spinDownPoints), \n\n spin up data: \(spinUpPoints)")
        
        spinUpData.append(contentsOf: spinUpPoints)
        spinDownData.append(contentsOf: spinDownPoints)
        
        
        
        
//        for item in self.spinUpData {
//        print(item)
//        }
        //Append the points to the arrays needed for the displays
        //Don't attempt to draw more than 250,000 points to keep the display updating speed reasonable.
        
        //if ((totalGuesses < 1000001) || (insideData.count == 0)){
        //    insideData.append(contentsOf: newInsidePoints)
        //    outsideData.append(contentsOf: newOutsidePoints)
        //}
        
        
        //return box
        
    }
    
}
