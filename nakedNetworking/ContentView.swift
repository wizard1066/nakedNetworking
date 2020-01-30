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

let communication = Connect()

struct ContentView: View {

//    let subscriber = weatherPublisher
//      .sink {value in
//        print("boo")
//    }
  
  @ObservedObject var globalVariable:BlobModel = BlobModel.sharedInstance
  @State var status = true
  
  var body: some View {
    VStack {
      Toggle(isOn: $status) {
        Text("")
      }.frame(width: 64.0, height: 44.0, alignment: .center)

      Text("\(globalVariable.score)")
        .onAppear {
          if self.status {
            let port2U = NWEndpoint.Port.init(integerLiteral: 1984)
            communication.listenUDP(port: port2U)
          } else {
            let port2U = NWEndpoint.Port.init(integerLiteral: 4891)
            communication.listenUDP(port: port2U)
          }
      }
      Button(action: {
        if self.status {
          makeConnect(port: "4891", message: "ping")
        } else {
          makeConnect(port: "1984", message: "pong")
        }
      }) {
        Text("smoke")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView(globalVariable: globalVariable)
    }
}

func makeConnect(port: String, message: String) {
  let host = NWEndpoint.Host.init("192.168.1.255")
  let port = NWEndpoint.Port.init(port)
  
  communication.connectToUDP(hostUDP: host, portUDP: port!)
  communication.sendUDP(message)
}


//          .onReceive(weatherPublisher) { (newData) in
////            text2S = newData
////            print("\(text2S) blob \(self.nlob.score)")
////            self.nlob.score = newData
//
//          }
