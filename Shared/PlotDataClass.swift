//
//  PlotDataClass.swift
//  SwiftUICorePlotExample
//  Shared
//
//

import Foundation
import SwiftUI
import CorePlot

class PlotDataClass: NSObject, ObservableObject {
    
    @Published var plotData = [plotDataType]()
    @Published var changingPlotParameters: ChangingPlotParameters = ChangingPlotParameters()
    @Published var calculatedText = ""
    //In case you want to plot vs point number
    @Published var pointNumber = 1.0
    
    init(fromLine line: Bool) {
        
        
        //Must call super init before initializing plot
        super.init()
       
        
        //Intitialize the first plot
        self.plotBlank()
        
       }
    
    
    
    func plotBlank()
    {
        plotData = []
        
        //set the Plot Parameters
        // want temp on x, domain size on y?
        changingPlotParameters.yMax = 4.0
        changingPlotParameters.yMin = -1.0
        changingPlotParameters.xMax = 2.5       // go 0.5 further on both ends for this specific project
        changingPlotParameters.xMin = 0.0
        changingPlotParameters.xLabel = "x"
        changingPlotParameters.yLabel = "y"
        changingPlotParameters.lineColor = .red()
        changingPlotParameters.title = " y = x"
        
    }
    
    func zeroData(){
            
            plotData = []
            pointNumber = 1.0
            
        }
        
        func appendData(dataPoint: [plotDataType])
        {
          
            plotData.append(contentsOf: dataPoint)
            pointNumber += 1.0
            
            
            
        }
    
    

}


