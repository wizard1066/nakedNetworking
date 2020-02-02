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

class BlobModel: ObservableObject {
  static let sharedInstance = BlobModel()
  @Published var score: String = ""
}

var globalVariable = BlobModel()

class Connect: NSObject {

  private var talking: NWConnection?
  private var listening: NWListener?
  
  private var localEndPoint: String?
  private var remoteEndPoint: String?
  
  private var startingTime: Date?
  private var endingTime: Date?
  
  
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
          pingPublisher.send(string2Send)
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
      
func connectToUDP(hostUDP:NWEndpoint.Host,portUDP:NWEndpoint.Port) {

self.talking = NWConnection(host: hostUDP, port: portUDP, using: .udp)

    self.talking?.stateUpdateHandler = { (newState) in
      switch (newState) {
      case .ready:
        break
      default:
        break
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
