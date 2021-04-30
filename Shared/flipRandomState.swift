//
//  flipRandomState.swift
//  metropolisAlgorithm
//
//  Created by Matthew Adas on 4/9/21.
//


import Foundation
import SwiftUI
import CorePlot


class FlipRandomState: ObservableObject {
    //@Published var start = DispatchTime.now() //Start time
    @Published var stop = DispatchTime.now()  //Stop tim
    var plotDataModel: PlotDataClass? = nil
    var avgDomain = 0.0
    //@State var initialStateTextString = "cold start (see code for \"hot start\" need to add a picker)"
    
    // but should I call IsingClass here or should this just be part of IsingClass, used here: "var ES = ising.energyCalculation(S: state, N: N)"
    @State var ising = IsingClass()
    //@ObservedObject var stateAnimate = StateAnimationClass(withData: true)
    var stateAnimate : StateAnimationClass? = nil
    
    
    
    //func randomNumber(randomQueue: DispatchQueue, tempStr: String, NStr: String, stateString: String)  {
    // new function with only length 20 arrays
    // return avgDomain for corePlot part
    func randomNumber(randomQueue: DispatchQueue, tempStr: String, NStr: String) -> Double  {
        
        var state: [Double] = []
        let temp = Double(tempStr)!
        let N = Int(NStr)!
        avgDomain = 0.0
        
        //var box = 0.0
        
        //      Java ex: double[] state = new double[N]; double[] test = state;
        // populate "numbers" with N = 1,000 1's (not sure if N will ever change or be user selectable)
        
        // create cold start, all spin up (red layer I think)
        state.removeAll()
        
        for _ in 0..<N {
            state.append(-1)
        }
        
        if stateAnimate == nil {
            
        }
        else {
            self.stateAnimate!.drawState(state: state, n: Double(0.0))
        }
        // If I change this, I need to change the following in ContentView: stateAnimate.xMax = 800.0*Double(numElectronString)!
        //let M = 10*N
        let M = 250
        // uncomment this for loop is for a "hot start" ...comment it out for a "cold start"
        /*
        self.initialStateTextString = "hot start"
         for _ in 0..<M {
            // sequence to choose random member of "numbers" array and multiply by -1
            let nthMember = Int.random(in: 0..<N)
            state[nthMember] *= -1
        }*/
        
        // trial energy
        var ES = ising.energyCalculation(S: state, N: N)
        
        // apply randomizer again to initial state
        var trialRandomFlip = state.map { $0 } // replace all elements one at a time
        //print("begin")
        
        // Start random flipping
        // var start = DispatchTime.now() // starting time of the integration
        randomQueue.async {
            //DispatchQueue.concurrentPerform(iterations: Int(iterations), execute: { index in
            //DispatchQueue.concurrentPerform(iterations: 1, execute: { index in
                for n in 1..<M {
                    
                    // plot initial state?
                    // keep updating state with each iteration of the loop
                    // ////////////////////////////////////////////////////////////
                    
                    // generate trial state by choosing 1 random electron at a time to flip
                    let nthMember = Int.random(in: 0..<N) // choose random electron in trial
                    trialRandomFlip[nthMember] *= -1      // flip chosen electron in trial
                    // fix state according to probability
                    let ET = self.ising.energyCalculation(S: trialRandomFlip, N: N)
                    
                    if ET < ES {
                        
                        state = trialRandomFlip.map { $0 } // .map { $0 } replace all elements one at a time
                        ES = ET
                        let drawStateArr = state.map { $0 }
                        
                        DispatchQueue.main.async{
                            //Update Display With Started Queue Thread On the Main Thread
                            //self.stateString = "\(state)"
                            if self.stateAnimate == nil{}
                            else{self.stateAnimate!.drawState(state: drawStateArr, n: Double(n))}
                            
                        }
                        
                        //print("less than", n)
                    }
                    
                    else {
                                            
                        let p = exp((ES-ET)/(self.ising.k * temp))
                        //print("p = ",p)
                        let randnum = Double.random(in: 0...1)
                        
                        if (p >= randnum) {
                            //print("rand =", randnum, "p =", p)
                            state = trialRandomFlip.map { $0 }     // .map { $0 } replace all elements one at a time
                            ES = ET                     // ES stays as is if probability of trial is too low
                            let drawStateArr = state.map { $0 }
                            //print("not less than", n)
                            DispatchQueue.main.async{
                                //self.stateAnimate!.drawState(state: state, n: Double(n))
                                //Update Display With Started Queue Thread On the Main Thread
                                //self.stateString = "\(state)"
                                if self.stateAnimate == nil {}
                                else{self.stateAnimate!.drawState(state: drawStateArr, n: Double(n))}
                            }
                            //print(ES)
                        }
                        
                        else {
                            trialRandomFlip = state.map { $0 }
                            
                            DispatchQueue.main.async{
                                //self.stateAnimate!.drawState(state: state, n: Double(n))
                                //Update Display With Started Queue Thread On the Main Thread
                                //self.stateString = "\(state)"
                                if self.stateAnimate == nil {}
                                else{self.stateAnimate!.drawState(state: state, n: Double(n))}
                            }
                        }
                        
                        
                    }
                    /*
                     DispatchQueue.main.async{
                         //Update Display With Started Queue Thread On the Main Thread
                         self.outputText += "started index \(index)" + "\n"
                     }
                     */
                    //print(ES)
                    //wait(timeout: 5)
                    // delay by some microseconds
                    usleep(10) // add a zero for a more readable speed at lower N
                    //print("\n this is the state \(state) \n and how many \(state.count)")
                
                
                }
            //print("it has finished, state at equilibrium: \(state)")
            
            // average domain size
            // count + in a row, count - in a row, average size
            // probably just make it into an observable object class right
            
            var counted = 0
            var domainSizesArr: [Int] = []
            
            var modArr = state         // modArr probably needs to start empty actually, and set equal to state either after or during the randomNumber function
            
            var lenModArr = modArr.count    // changes each time something is counted in modArr/finalArray ...yea idk what this will need to be changed to within the class yet

            //func countPosFunc(funcArr: [Int]) -> (Int, [Int]) {
            func countPosFunc(funcArr: [Double]) -> [Double] {
                counted = 0                     // reset to 0 each time the function runs
                let N = funcArr.count
                var modFinalArray: [Double] = []   // I mean I want to throw it out each time so I can generate a new one each time maybe?

                for item in (0...N-1) {
                    if funcArr[item] == 1.0 {
                        counted += 1
                        //totalCount += 1         // add to global variable totalCount
                    }
                    else {break}                // break the for loop and return counted instances of consecutive -1
                }

                // discard the array members already examined?
                
                if counted == N {return [0]} // do not continue reducing modArray if it is on it's final domain
                for item in (counted...N-1) {
                    modFinalArray.append(funcArr[item]) //?
                }
                lenModArr = modFinalArray.count
                //print(modFinalArray)
                return modFinalArray
            }

            func countNegFunc(funcArr: [Double]) -> [Double] {
                counted = 0
                let N = funcArr.count
                var modFinalArray: [Double] = []

                for item in (0...N-1) {
                    if funcArr[item] == -1.0 {
                        counted += 1
                        //totalCount += 1
                    }
                    else {break}
                }
                
                if counted == N {return [0]}
                for item in (counted...N-1){
                    modFinalArray.append(funcArr[item])
                }
                lenModArr = modFinalArray.count
                //print(modFinalArray)
                return modFinalArray
            }

            while lenModArr > 1 { // problem if I have a lonely spin at the very end, or maybe not since I'm typically working with large N anyway? Can't I afford to lose that last lonely spin?
                //print(lenModArr)
                modArr = countNegFunc(funcArr: modArr)
                if counted > 0 {domainSizesArr.append(counted)} //  obviously I only want to append non-zero size domains
                //print(modArr, counted)
                //print(lenModArr)
                modArr = countPosFunc(funcArr: modArr)
                if counted > 0 {domainSizesArr.append(counted)}
                //print(modArr, counted, totalCount)
                
            }
            
            
            // avg domain size
            // sum Of domains is just the length of the state array of course
            // is there still an issue here carried over from the possible missing lonely spin?
            let lengthOfDomainSizeArr = Double(domainSizesArr.count)
            
            if lengthOfDomainSizeArr == 0.0 {   // pass if length is 0
                //print("avg domain size: 1.0")
            }
            
            else {
                
                if state[0] == state[N-1] {
                    domainSizesArr[0] = domainSizesArr[0]+domainSizesArr[domainSizesArr.count-1]
                    domainSizesArr.popLast()
                }
                //print("sizes of domains: \(domainSizesArr)")
                let sumOfDomain = Double(state.count)
                self.avgDomain = sumOfDomain / lengthOfDomainSizeArr
                print("\navg domain size within async: \(self.avgDomain)")

            }
            
            
            
            //integralArray.append(self.calculateMonteCarloIntegral(dimensions: 1, guesses: Int32(guesses), index: index))
        //})
          
        // ex: 20x20 array
        // value [i,j] in 1D array = value[i + (j * number of elements in a row)]
        // 5,2 -> 5 + (2 * 20) = 45
        // [0, 1] in 20x20 matrix -> 20th element
                
        } // end of queue
        
        //  ////////////////////////////
        
        /*          // but i'm not plotting error I'm plotting temp and avg domain now
                    
        let dataPoint: plotDataType = [.X: 0.0, .Y: 0.0]
            plotDataModel!.appendData(dataPoint: [dataPoint])*/
        print("\navg domain size outside async: \(self.avgDomain)")
        return self.avgDomain
    }
    
    
}
