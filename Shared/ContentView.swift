//
//  ContentViewText.swift
//  metropolisWithCorePlot
//
//  Created by Matthew Adas on 4/23/21.
//

import SwiftUI
import CorePlot

typealias plotDataType = [CPTScatterPlotField : Double]

struct ContentView: View {
    
    @State var tempString = "1.0"
    @State var numElectronString = "100"
    
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
                
                /* think I'll take temp out actually and just plot it
                // do temp range 0.5 - 2.0 in tenths (0.5, 0.6, 0.7, ..., 2.0)
                HStack(alignment: .center) {
                    Text("temp:")
                        .font(.callout)
                        .bold()
                    TextField("temp", text: $tempString)
                        .padding()
                }.padding() */
                
                // need to plot for different temperatures here, different "action" than other tabs in the GUI, see plotForTempRange function
                //
                Button("Show Average Domain Size for Temp Range 0.5 to 2.0", action: plotForTempRange)
                    .padding()
                
            }
        }
    }
    
    
    func printValue() {
        
        for item in stateAnimation.spinUpData {
            print(item)
        }
    }
    
    func startTheFlipping() {
        
        stateAnimation.spinDownData = []
        stateAnimation.spinUpData = []
        
        //Create a Queue for the Calculation
        //We do this here so we can make testing easier.
        let randomQueue = DispatchQueue.init(label: "randomQueue", qos: .userInitiated, attributes: .concurrent)
        
        stateAnimation.xMin = 0.0
        //stateAnimation.xMax = 10.0*Double(numElectronString)! // if I change this, I need to change the following in flipRandomState: let M = 800*N
        stateAnimation.xMax = 250.0
        stateAnimation.yMin = 0.0
        stateAnimation.yMax = Double(numElectronString)!
        
        
        flip.stateAnimate = self.stateAnimation
        flip.randomNumber(randomQueue: randomQueue, tempStr: tempString, NStr: numElectronString )
        
    }
    /* */
     
     // do temp range 0.5 -> 2.0 in tenths (0.5, 0.6, 0.7, ..., 2.0)
    // temperature vs domain size
    // calculate states for different temperatures
    // compare size of domains
    // x: temp (0:10) do I need to go this high?
    // y: avg of avg domain size (calculate 10 domains to get avg domain size for each temp)
    func plotForTempRange() {
        
        var tempDouble = 0.5
        var sumAvgs = 0.0
        var plotData :[plotDataType] =  []
        var domainAverage = 0.0
        var tempStringForRangePlot = ""
        
        
        for _ in (1..<16) {
            
            // now how do I coreplot?
            //Create a Queue for the Calculation
            //We do this here so we can make testing easier.
            let randomQueue = DispatchQueue.init(label: "randomQueue", qos: .userInitiated, attributes: .concurrent)
            
            tempStringForRangePlot = String(tempDouble)
            var oneAvgDomainSize = 0.0
            print(tempDouble) //currently goes to 2.0
            // average of 10 results of the same temp
            for _ in (1..<11) {
                
                oneAvgDomainSize = flip.randomNumber(randomQueue: randomQueue, tempStr: tempStringForRangePlot, NStr: numElectronString )
                sumAvgs += oneAvgDomainSize
                print("sum domain avg", sumAvgs, "one average in loop", oneAvgDomainSize)
            }
            
            domainAverage = sumAvgs / 10 // finally the Y-AXIS value, average domain size promised for 10 iterations of one given temp
            
            // for plot now
            // y = domainAverage
            // x = tempDouble
            
            
            let dataPoint: plotDataType = [.X: tempDouble, .Y: domainAverage]
            plotData.append(contentsOf: [dataPoint])
            
            flip.plotDataModel = self.plotDataModel
            
            tempDouble += 0.1   // increase temp for CorePlot
            
            
            
        }
        print("last temp", tempDouble, "domain avg", domainAverage)
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
