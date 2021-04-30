//
//  metropolisWithCorePlotApp.swift
//  Shared
//
//  Created by Matthew Adas on 4/23/21.
//

import SwiftUI

@main
struct metropolisWithCorePlotApp: App {
    
    @StateObject var plotDataModel = PlotDataClass(fromLine: true)
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ContentView()
                    .environmentObject(plotDataModel)
                    .tabItem {
                        Text("Plot")
                    }
                TextView()
                    .environmentObject(plotDataModel)
                    .tabItem {
                        Text("Text")
                    }
                            
                            
            }
            
        }
    }
}
