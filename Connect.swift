//
//  File.swift
//  nakedNetworking
//
//  Created by localadmin on 28.01.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import Network
import Foundation
import Combine


let pingPublisher = PassthroughSubject<String, Never>()
let winPublisher = PassthroughSubject<Void, Never>()
let gamePublisher = PassthroughSubject<Void, Never>()

class BlobModel: ObservableObject {
  static let sharedInstance = BlobModel()
  @Published var score: String = ""
}

var globalVariable = BlobModel()
var playing: NWEndpoint?

class Connect: NSObject {

  private var talking: NWConnection?
  private var listening: NWListener?
  private var browser: NWBrowser?
  private var localEndPoint: String?
  private var remoteEndPoint: String?
  
  private var startingTime: Date?
  private var endingTime: Date?
  

  
  func findUDP() {
    print("findUDP")
    let parameters = NWParameters()
    parameters.includePeerToPeer = true
    
    browser = NWBrowser(for: .bonjour(type: "_wow._udp", domain: nil), using: parameters)
    browser?.browseResultsChangedHandler = { foo, changes in
      for change in changes {
        switch change {
        case .added(let browseResult):
          playing = browseResult.endpoint
          print(browseResult.endpoint)
        default:
          print("anything else seen")
        }
      }
    }
    self.browser?.start(queue: .main)
  }
  
  
//  func listenUDP(port: NWEndpoint.Port) {
func listenUDP(zeus: String) {
    do {
//     self.listening = try NWListener(using: .udp, on: port)
     self.listening = try NWListener(using: .udp)
     self.listening?.service = NWListener.Service(name:zeus, type: "_wow._udp", domain: nil, txtRecord: nil)
//     self.listening?.service = NWListener.Service(type: "_wow._udp")
     self.listening?.stateUpdateHandler = {(newState) in
     switch newState {
        case .ready:
          print("ready")
        default:
          print("anything else seen newState")
        }
      }
      
      self.listening?.serviceRegistrationUpdateHandler = { (serviceChange) in
        switch(serviceChange) {
          case .add(let endpoint):
            switch endpoint {
              case let .service(name, foo1, foo2, foo3):
                print("Listening as \(name) \(foo1) \(foo2) \(foo3)")
              default:
                print("anything else seen endpoint")
              }
            default:
              print("anything else seen serviceChange")
          }
        }
      
      self.listening?.newConnectionHandler = {(newConnection) in
        newConnection.stateUpdateHandler = {newState in
          switch newState {
            case .ready:
              print("new connection")
              self.receive(on: newConnection)
            default:
              print("fuck newConnection failed")
          }
        }
        newConnection.start(queue: .main)
      }
    } catch {
      print("unable to create listener")
    }
    self.listening?.start(queue: .main)
  }
  
  func receive(on connection: NWConnection) {
    endingTime = Date()
    var string2Send: String = "8"
    if startingTime != nil {
      let answer = DateInterval(start: startingTime!, end: endingTime!)
      string2Send = String(answer.duration)
    }
    connection.receiveMessage { (data, context, isComplete, error) in
      if let error = error {
        print(error)
        return
      }
      if let data = data, !data.isEmpty {
        let backToString = String(decoding: data, as: UTF8.self)
        print("b2S",backToString)
        DispatchQueue.main.async {
          globalVariable.score = backToString
          if backToString == "ping" || backToString == "pong" {
            pingPublisher.send(string2Send)
          }
          if backToString == "win" {
            winPublisher.send()
          }
          if backToString == "game" {
            gamePublisher.send()
          }
        }
      }
    }
  }

  func stopListening() {
    self.listening?.cancel()
  }

//      let merlin = Wizard(grade: 5)
//      let grad = Notification.Name(rawValue: "graduated")
//      let cancellable = NotificationCenter.default.publisher(for: grad, object: merlin)
//          .map{ notification in
//            notification.userInfo?["NewGrade"] as? Int ?? 0
//          }
//
//      let gradeSubscriber = Subscribers.Assign(object: merlin, keyPath: \.grade)
//      cancellable.subscribe(gradeSubscriber)

      //    let trickNamePublisher = NotificationCenter.default.publisher(for: .newTrickDownloaded).map { notification in
      //          return notification.userInfo?["data"] as! Data
      //      }.decode(MagicTrick.self, JSONDecoder())
      //       .catch {
      //        print("fuck")
      //      }.publisher(for: \.name)
      //      .recieve(on: RunLoop.main)
      
//func connectToUDP(hostUDP:NWEndpoint.Host,portUDP:NWEndpoint.Port) {


func connectToUDP(name: String) {
  
//  let parameters = NWParameters()
//  parameters.includePeerToPeer = true
//  if let ipOptions = self.talking?.parameters.defaultProtocolStack.internetProtocol as? NWProtocolIP.Options {
//        ipOptions.version = .v4
//  }
//  print("bonjour ",bonjourUDP,parameters)
//  parameters.includePeerToPeer = true
//  self.talking = NWConnection(to: bonjourUDP, using: parameters)
  self.talking = NWConnection(to: .service(name: name, type: "_wow._udp", domain: "local", interface: nil), using: .udp)
  
//self.talking = NWConnection(host: hostUDP, port: portUDP, using: .udp)

    self.talking?.stateUpdateHandler = { (newState) in
      switch (newState) {
      case .ready:
        print("ready to send")
      case .failed(let error):
        print("failed error ",error)
      case .waiting(let error):
        print("waiting error",error)
      case .preparing:
        print("preparing X")
      case .setup:
        print("setup")
      default:
        print("something else")
      }
    }
    self.talking?.start(queue: .main)
}

  func sendUDP(_ content: String) {
        startingTime = Date()
        let contentToSendUDP = content.data(using: String.Encoding.utf8)
        self.talking?.send(content: contentToSendUDP, completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
          if (NWError == nil) {
            print("send ok")
          } else {
            print("ERROR! Error when data (Type: String) sending. NWError: \n \(NWError!) ")
          }
        })))
    }

}
