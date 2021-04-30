//
//  ContentViewText.swift
//  metropolisWithCorePlot
//
//  Created by Matthew Adas on 4/23/21.
//
// search "problem" for more problems
// working on "thermodynamic properties"

// see plotForTempRange for issues
// weird problem is that if I don't use the other button, domain size is always zero here. When I do use the other button, this function takes the avg domain size from that function. It then adds that one value over and over.

import SwiftUI
import CorePlot

typealias plotDataType = [CPTScatterPlotField : Double]

struct ContentView: View {
    
    @State var tempString = "1.0"
    @State var numElectronString = "20"
    @State var energyString = ""
    @State var magnetizeString = ""
    
    //@ObservedObject var ising = IsingClass() // actually not using IsingClass() here
    @ObservedObject var flip = FlipRandomState()
    @ObservedObject var stateAnimation = StateAnimationClass(withData: true)
    
    
    @EnvironmentObject var plotDataModel :PlotDataClass
    //@ObservedObject private var calculator = Calculator()
    @State var isChecked:Bool = false
    //@State var tempInput = ""
  
    

    var body: some View {
        
        VStack {
            
            Text("temp")
                .padding(.top)
                .padding(.bottom, 0)
            TextField("temperature", text: $tempString)
                .padding(.horizontal)
                .frame(width: 100)
                .padding(.top, 0)
                .padding(.bottom, 30)
            
            Text("total electrons (N)")
                .padding(.bottom, 0)
            TextField("number of electrons", text: $numElectronString)
                .padding(.horizontal)
                .frame(width: 100)
                .padding(.top, 0)
                .padding(.bottom, 30)
            
            Text("(broken) end energy")
                .padding(.bottom, 0)
            TextField("", text: $energyString)
                .padding(.horizontal)
                .frame(width: 100)
                .padding(.top, 0)
                .padding(.bottom, 30)
            
            Text("(broken) magnetization")
                .padding(.bottom, 0)
            TextField("", text: $magnetizeString)
                .padding(.horizontal)
                .frame(width: 100)
                .padding(.top, 0)
                .padding(.bottom, 30)
            
            
            // button
            Button("Generate random states", action: startTheFlipping)
                .padding()
            Button("get", action: printValue)
                .padding()
            
        }
        .tabItem { Text("Parameters") }
        
        VStack {
            drawingView(redLayer: $stateAnimation.spinUpData, blueLayer: $stateAnimation.spinDownData, xMin:$stateAnimation.xMin, xMax:$stateAnimation.xMax, yMin:$stateAnimation.yMin, yMax:$stateAnimation.yMax)
                //.fixedSize(horizontal: true, vertical: true)
                //.frame(width: 200.0, height: 20.0)
                
                // I removed this line is that bad?
                //.frame(minWidth: 400, idealWidth: 1800, maxWidth: 2800, minHeight: 400, idealHeight: 1800, maxHeight: 2800)
                .padding()
                .aspectRatio(1, contentMode: .fit)
                .drawingGroup()
                
                
             // Stop the window shrinking to zero.
             Spacer()
            Button("Generate random states", action: startTheFlipping)
                .padding()
            
        }
        .tabItem { Text("Animation") }
        
        
        
        VStack {
            
            // temperature vs domain size
            // calculate states for different temperatures
            // compare size of domains
            // x: temp (0:10)
            // y: avg of avg domain size (calculate 10 domains for each temp)
            
            CorePlot(dataForPlot: $plotDataModel.plotData, changingPlotParameters: $plotDataModel.changingPlotParameters)
                .setPlotPadding(left: 10)
                .setPlotPadding(right: 10)
                .setPlotPadding(top: 10)
                .setPlotPadding(bottom: 10)
                .padding()
            
            Divider()
            
            HStack{
                
                // in the GUI, see plotForTempRange function
                //
                Button("(doesn't work yet, and in fact is quite a strange mess) Show Average Domain Size for Temp Range 0.5 to 2.0", action: plotForDomainAndTemp)
                    .padding()
                
            }
        }
    }
    
    
    func printValue() {
        
        for item in stateAnimation.spinUpData {
            print(item)
        }
    }
    
    func startTheFlipping() {   // problem: how do I get thermodynamic properties (energy and magnetization) from here to GUI
        
        stateAnimation.spinDownData = []
        stateAnimation.spinUpData = []
        
        //Create a Queue for the Calculation
        //We do this here so we can make testing easier.
        let randomQueue = DispatchQueue.init(label: "randomQueue", qos: .userInitiated, attributes: .concurrent)
        
        stateAnimation.xMin = 0.0
        stateAnimation.xMax = 10.0*Double(numElectronString)! // if I change this, I need to change the following in flipRandomState: let M = 800*N
        //stateAnimation.xMax = 250.0
        stateAnimation.yMin = 0.0
        stateAnimation.yMax = Double(numElectronString)!
        
        
        flip.stateAnimate = self.stateAnimation
        flip.randomNumber(randomQueue: randomQueue, tempStr: tempString, NStr: numElectronString )
        energyString = String(flip.energyFromRandom)
        magnetizeString = String(flip.magnitizationFromRandom)
    }
    /* */
     
     // do temp range 0.5 -> 2.0 in tenths (0.5, 0.6, 0.7, ..., 2.0)
    // temperature vs domain size
    // calculate states for different temperatures
    // compare size of domains
    // x: temp (0:10) do I need to go this high?
    // y: avg of avg domain size (calculate 10 domains to get avg domain size for each temp)
    
    // weird problem is that if I don't use the other button, domain size is always zero here. When I do use the other button, this function takes the avg domain size from that function. It then adds that one value over and over.
    func plotForDomainAndTemp() {
        
        var tempDouble = 0.5
        var sumAvgs = 0.0
        var plotData :[plotDataType] =  []
        var domainAverage = 0.0
        var tempStringForPlot = ""
        var oneAvgDomainSize = 0.0
        
        // now how do I coreplot?
        //Create a Queue for the Calculation
        //We do this here so we can make testing easier.
        //let randomQueue = DispatchQueue.init(label: "randomQueue", qos: .userInitiated, attributes: .concurrent)
        //let randomQueue = DispatchQueue(label: "tempRange")
        
        stateAnimation.xMin = 0.0
        //stateAnimation.xMax = 10.0*Double(numElectronString)! // if I change this, I need to change the following in flipRandomState: let M = 800*N
        stateAnimation.xMax = 250.0
        stateAnimation.yMin = 0.0
        stateAnimation.yMax = Double(numElectronString)!
        
        
        for _ in (1..<16) {
            
            tempStringForPlot = String(tempDouble)
            
            //print(tempDouble) //currently goes to 2.0
            // average of 10 results of the same temp
            for _ in (1..<11) {
                
                oneAvgDomainSize = flip.plotDomainAvgAndTemp(NStr: numElectronString, tempStr: tempStringForPlot)
                sumAvgs += oneAvgDomainSize
                //print("value returned from randomNumber()", oneAvgDomainSize)
                
            }
            
            domainAverage = sumAvgs / 10 // finally the Y-AXIS value, average domain size promised for 10 iterations of one given temp
            
            // for core plot
            let dataPoint: plotDataType = [.X: tempDouble, .Y: domainAverage] // problem: x & y are swapping occasionally so that's weird
            print("temp", tempDouble)
            print("domainAv", domainAverage)
            print("(x,y) =", dataPoint, "\n")
            
            plotData.append(contentsOf: [dataPoint])
            
            flip.plotDataModel = self.plotDataModel
            
            tempDouble += 0.1   // increase temp for CorePlot
            
        }
        
        print("domain avg", domainAverage)
        
    }
    
    /*
     func calculateSin_X(){
             
             let x = Double(xInput)
             xInput = "\(x!)"
             
             var sin_x = 0.0
             let actualsin_x = sin(x!)
             var errorCalc = 0.0
             
             //pass the plotDataModel to the sinCalculator
             sinCalculator.plotDataModel = self.plotDataModel
             
             //tell the sinCalculator to plot Data or Error
             sinCalculator.plotError = self.isChecked
             
             //Calculate the new plotting data and place in the plotDataModel
             sin_x = sinCalculator.calculate_sin_x(x: x!)
             
             print("The sin(\(x!)) = \(sin_x)")
             print("computer calcuates \(actualsin_x)")
             
             sinOutput = "\(sin_x)"
             
             computerSin = "\(actualsin_x)"
             
             if(actualsin_x != 0.0){
                 
                 var numerator = sin_x - actualsin_x
                 
                 if(numerator == 0.0) {numerator = 1.0E-16}
                 
                 errorCalc = log10(abs((numerator)/actualsin_x))
                 
             }
             else {
                 errorCalc = 0.0
             }
             
             error = "\(errorCalc)"
         }
     */

   
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
