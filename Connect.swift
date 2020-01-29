//
//  File.swift
//  nakedNetworking
//
//  Created by localadmin on 28.01.20.
//  Copyright © 2020 Mark Lucking. All rights reserved.
//

import Network
import Foundation
import SwiftUI
import Combine

let weatherPublisher = PassthroughSubject<String, Never>()

class BlobModel: ObservableObject {
  @Published var score: String = ""
}

var globalVariable = BlobModel()

class Connect: NSObject {

  private var talking: NWConnection?
  private var listening: NWListener?
  
  private var localEndPoint: String?
  private var remoteEndPoint: String?
  
  func listenUDP(port: NWEndpoint.Port) {
    do {
     self.listening = try NWListener(using: .udp, on: port)
     self.listening?.stateUpdateHandler = {(newState) in
     switch newState {
        case .ready:
          print("ready")
        default:
          break
        }
      }
      
      self.listening?.newConnectionHandler = {(newConnection) in
        newConnection.stateUpdateHandler = {newState in
          switch newState {
            case .ready:
              print("new connection")
              self.receive(on: newConnection)
            default:
              break
          }
        }
        newConnection.start(queue: DispatchQueue(label: "new client"))
      }
    } catch {
      print("unable to create listener")
    }
    
    self.listening?.start(queue: .main)
    
//    let trickNamePublisher = NotificationCenter.default.publisher(for: .newTrickDownloaded).map { notification in
//          return notification.userInfo?["data"] as! Data
//      }.decode(MagicTrick.self, JSONDecoder())
//       .catch {
//        print("fuck")
//      }.publisher(for: \.name)
//      .recieve(on: RunLoop.main)

    enum WeatherError: Error {
      case thingsJustHappen
    }

    
    
  }
  
  
  
  func receive(on connection: NWConnection) {
    connection.receiveMessage { (data, context, isComplete, error) in
    if let error = error {
      print(error)
      return
    }
    if let data = data, !data.isEmpty {
      let backToString = String(decoding: data, as: UTF8.self)
      print("b2S",backToString)
      DispatchQueue.main.async {
//          weatherPublisher.send(backToString)
        globalVariable.score = backToString
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
      
      
    }
    }
  }
  
  
  
}
