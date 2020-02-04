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
//      let port2U = NWEndpoint.Port.init(integerLiteral: 1984)
//      communication.listenUDP(port: port2U)
      communication.listenUDP(zeus: "pong")
      player = "ying"
      globalVariable.score = "pong"
      print("1984")
    } else {
      communication.stopListening()
//      let port2U = NWEndpoint.Port.init(integerLiteral: 4891)
//      communication.listenUDP(port: port2U)
      communication.listenUDP(zeus: "ping")
      player = "yang"
      globalVariable.score = "ping"
      print("4891")
    }
  }
  }
}

struct ContentView: View {

  let dingPublisher = PassthroughSubject<Void, Never>()

  @ObservedObject var globalVariable:BlobModel = BlobModel.sharedInstance
  @State var model = ToggleModel()
  @State var disable = false
  @State var refresh = false
  @State var timeToDie = ""
  // timer is a State so that I can it, else it would be considered immutable
  @State var youLose: Timer?
  @State var volley = ""
  @State var hit = false
  @State var game = 1
  @State var game1 = ""
  @State var game2 = ""
  @State var game3 = ""
  @State var game4 = ""
  @State var game5 = ""
  @State var game6 = ""
  @State var game7 = ""

  @State var remoteWin = 0
  @State var localWin = 0
  @State var localLose = 0
  @State var remoteLose = 0
  @State var newGame = false
  
  
  var body: some View {
    
    VStack {
      Button(action: {
        communication.findUDP()
      }) {
        Text("search")
      }
      Button(action: {
        self.disable = false
      }) {
        Text("reset")
      }
      Toggle(player, isOn: $model.state).frame(width: 128, height: 64, alignment: .center)
      Text("\(globalVariable.score)")
        .onAppear {
          communication.listenUDP(zeus: "pong")
        }.onReceive(pingPublisher) { ( data ) in
          print("data ",data)
          self.hit = false
          self.disable = false
          self.volley = ""
          var countDown = Float(data)
          if countDown! > 4 {
            countDown = 4
          }
          self.youLose = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { timer in
            countDown = countDown! - 0.1
            self.timeToDie = String(countDown!)
            if countDown! < 0.0 && !self.disable {
                self.disable = true
                self.youLose?.invalidate()
                self.volley = "You Lose"
                self.globalVariable.score = "lose"
                self.winWin(game: self.game,leader: "x")
                if self.model.state {
                  makeConnect(zeus: "pong", message: "win")
                } else {
                  makeConnect(zeus: "ping", message: "win")
                }
            }
          })
        }
      
      Button(action: {
        self.disable = true
        self.youLose?.invalidate()
        self.refresh = !self.refresh
        if !self.hit {
          self.hit = true
          if self.model.state {
            makeConnect(zeus: "pong", message: "ping")
          } else {
            makeConnect(zeus: "ping", message: "pong")
          }
        }
      }) {
        Text("whack")
          .disabled(disable)
      }
      Text(timeToDie)
      Text(volley).onReceive(winPublisher, perform: {
        self.hit = false
        self.volley = "You Win"
        self.disable = false
        self.winWin(game: self.game,leader: "o")
        self.globalVariable.score = ""
      })
      HStack {
        Text(game1)
        Text(game2)
        Text(game3)
        Text(game4)
        Text(game5)
        Text(game6)
        Text(game7)
      }
      Button(action: {
        self.reset()
        self.disable = false
        self.remoteWin = 0
        self.localWin = 0
        self.volley = ""
        self.newGame = false
        self.game = 1
        self.timeToDie = ""
        self.globalVariable.score = ""
        if self.model.state {
          makeConnect(zeus: "pong", message: "game")
        } else {
          makeConnect(zeus: "ping", message: "game")
        }
      }) {
        Text("new game").disabled(newGame ? false: true)
      }.onReceive(gamePublisher) { (_) in
        self.reset()
        self.disable = false
        self.remoteWin = 0
        self.localWin = 0
        self.volley = ""
        self.newGame = false
        self.game = 1
        self.timeToDie = ""
        self.globalVariable.score = ""
      }
    }
    
  }
  
  func reset() {
    self.game1 = ""
    self.game2 = ""
    self.game3 = ""
    self.game4 = ""
    self.game5 = ""
    self.game6 = ""
    self.game7 = ""
  }
  
  func winWin(game: Int, leader: String) {
    switch self.game {
      case 1:
        self.game1 = leader
      case 2:
        self.game2 = leader
      case 3:
        self.game3 = leader
      case 4:
        self.game4 = leader
      case 5:
        self.game5 = leader
      case 6:
        self.game6 = leader
      case 7:
        self.game7 = leader
      default:
        break
    }
  
    self.game = self.game + 1
    if leader == "o" && !self.model.state {
      remoteWin = remoteWin + 1
    }
    if leader == "o" && self.model.state {
      localWin = localWin + 1
    }
    if leader == "x" && !self.model.state {
      remoteLose = remoteLose + 1
    }
    if leader == "x" && self.model.state {
      localLose = localLose + 1
    }

    if game == 7 {
      newGame = true
      if self.model.state {
        self.volley = "game over yang wins " + " " + String(localWin) + " ying wins " + String(localLose)
      } else {
        self.volley = "game over ying wins " + " " + String(remoteWin) + " yang wins " + String(remoteLose)
      }
    }
  }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView(globalVariable: globalVariable)
    }
}

func makeConnect(zeus: String, message: String) {
  print("port/message ",zeus,message)
    communication.connectToUDP(name: zeus)
    communication.sendUDP(message)
}


