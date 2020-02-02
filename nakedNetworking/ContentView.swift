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
var player:String = "ying"

struct ToggleModel {
  var state: Bool = false {
  willSet {
    if state {
      communication.stopListening()
      let port2U = NWEndpoint.Port.init(integerLiteral: 1984)
      communication.listenUDP(port: port2U)
      player = "ying"
      globalVariable.score = "pong"
      print("1984")
    } else {
      communication.stopListening()
      let port2U = NWEndpoint.Port.init(integerLiteral: 4891)
      communication.listenUDP(port: port2U)
      player = "yang"
      globalVariable.score = "ping"
      print("4891")
    }
  }
  }
}

struct ContentView: View {

//    let subscriber = weatherPublisher
//      .sink {value in
//        print("boo")
//    }

  let dingPublisher = PassthroughSubject<Void, Never>()

  @ObservedObject var globalVariable:BlobModel = BlobModel.sharedInstance
  @State var model = ToggleModel()
  @State var disable = false
  @State var refresh = false
  // timer is a State so that I can it, else it would be considered immutable
  @State var timer: Timer?
  
  var body: some View {
    
    VStack {
      Toggle(player, isOn: $model.state).frame(width: 128, height: 64, alignment: .center)
      Text("\(globalVariable.score)")
        .onAppear {
          let port2U = NWEndpoint.Port.init(integerLiteral: 1984)
          communication.listenUDP(port: port2U)
        }.onReceive(pingPublisher) { ( data ) in
          print("data ",data)
          self.disable = false
          var countDown = Float(data)
          self.timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            countDown = countDown! - 0.1
              if countDown! < 0.0 {
                self.disable = true
                self.timer?.invalidate()
            }
          })
        }
      
      
      Button(action: {
        if self.model.state {
          makeConnect(port: "1984", message: "ping")
          self.disable = true
          self.refresh = !self.refresh
          self.timer?.invalidate()
        } else {
          makeConnect(port: "4891", message: "pong")
          self.disable = true
          self.refresh = !self.refresh
          self.timer?.invalidate()
        }
      }) {
        Text("whack")
          .disabled(disable)
          
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
  print("port/message ",port,message)
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
