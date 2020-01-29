//
//  ContentView.swift
//  nakedNetworking
//
//  Created by localadmin on 28.01.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import SwiftUI
import Network
import Foundation
import Combine


var text2S = "Hello World"



struct ContentView: View {

//    let subscriber = weatherPublisher
//      .sink {value in
//        print("boo")
//    }
  
    @ObservedObject var globalVariable:BlobModel
    
    
    var body: some View {
      Text("\(globalVariable.score)")
          .onAppear {
            let communication = Connect()
            let port2U = NWEndpoint.Port.init(integerLiteral: 1984)
            communication.listenUDP(port: port2U)
          }
//          .onReceive(weatherPublisher) { (newData) in
////            text2S = newData
////            print("\(text2S) blob \(self.nlob.score)")
////            self.nlob.score = newData
//
//          }
          
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView(globalVariable: globalVariable)
    }
}
