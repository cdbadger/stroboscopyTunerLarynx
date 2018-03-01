//
//  Strobe engine.swift
//  GuitarTuner
//
//  Created by Christopher Badger on 1/22/18.
//  Copyright © 2018 Vadym Markov. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Beethoven
import Pitchy





class StrobeLights {
  var counter: Int = 0
  var timer: DispatchSourceTimer?
  var isStrobing: Bool
  var isLightOn: Bool
  var frequency: Double
  var start = DispatchTime.now()
  var end = DispatchTime.now()
  var active: Bool
  var device: AVCaptureDevice
  var torchLevel: Float
  //var workItem: DispatchWorkItem?
  
  
  private func stopTimer() {
    timer?.cancel()
    timer = nil
  }
  
  
  
  
  init (){
    self.counter = 0
    self.isStrobing = false
    self.isLightOn = false
    self.frequency = 100
    
    self.active = false
    self.torchLevel = 0.001
    self.device = AVCaptureDevice.default(for: AVMediaType.video)!
      if self.device.hasTorch {
        if self.device.isTorchAvailable {
          do {
            try device.lockForConfiguration()
            // hopefully only do this once
            

//              do {
//                //try device.setTorchModeOn(level: 0.01)
//s
//              } catch { print("Could not set torch level") }
            device.unlockForConfiguration()
          } catch {
            print("Torch could not be used")
          }
        } else {
          print( "torch unavailable")
        }
      } else {
        print("torch unavailable")
      }
    }

  
  // Start Strobe process
  func toggleStrobe () {
    if isLightOn == true {
      self.isLightOn = false
      //device.unlockForConfiguration()
      stopTimer()
      print("Turning timer off")
      self.end = DispatchTime.now()
      let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
      let timeInterval = Double(nanoTime) / 1_000_000_000
      print("I counted this high \(counter) in this many seconds \(timeInterval) ")
      //toggleTorch(on: false)
      
      counter = 0
//      incrementCounter()
    } else {
      self.isLightOn = true
      
      // change made by removing frequecy --> 10
      do {
        try device.lockForConfiguration()
        // hopefully only do this once
        
        
        //              do {
        //                //try device.setTorchModeOn(level: 0.01)
        //
        //              } catch { print("Could not set torch level") }
        
      } catch {
        print("Torch could not be used")
      }
      //let workItem = DispatchWorkItem {
        //.... writing stuff in background ....
      
//        self.timer = Timer.scheduledTimer(timeInterval: 1/self.frequency, target: self, selector: #selector(self.incrementCounter), userInfo: nil, repeats: true)
      startTimer()
        print("Turning timer on")
//      }
//      DispatchQueue.global().async(execute: workItem)
      
      self.start = DispatchTime.now()
      //toggleTorch(on: true)
    }
  }
  
 
 
  // Increase counter by one
  
  @objc func incrementCounter () {
    self.toggleTorch(on: true)
    self.counter += 1
    //print("\(self.counter)")
    self.toggleTorch(on: false)
  }
  // Turns light on or off
  
  
  @objc func toggleTorch(on: Bool ) {
            if on == true {
              device.torchMode = .on
              
            } else {
              device.torchMode = .off
              
            }
  }
  private func startTimer() {
    let queue = DispatchQueue(label: "torch timer", qos: .userInteractive)
    
    timer?.cancel()        // cancel previous timer if any
    
    timer = DispatchSource.makeTimerSource(flags: .strict, queue: queue)
    let period = 1/self.frequency
//    timer?.schedule(deadline: .now(), repeating: .seconds(period), leeway: .strict)
    timer?.schedule(deadline: .now(), repeating: period, leeway: .nanoseconds(0))
    
    // or, in Swift 3:
    //
    // timer?.scheduleRepeating(deadline: .now(), interval: .seconds(5), leeway: .seconds(1))
    
    timer?.setEventHandler { [weak self] in // `[weak self]` only needed if you reference `self` in this closure and you want to prevent strong reference cycle
      self?.incrementCounter()
      
    }
    
    timer?.resume()
  }
}


//Start of code from Drew/Chris
/*
 enum StrobeError: Error {
  // Enum Values/Cases:
  case targetSimulator
  case torchNotAvailable
  case unknown
  
  // Initialization method
  init() {
    self = .unknown
  }
  
  // Return Value Type: String
  var description: String {
    switch self {
    case .targetSimulator: return "Application is running on Simulator"
    case .torchNotAvailable: return "Torch not available on this device to show strobe light. Please run this app on a device with a torch"
    case .unknown: return "Error unspecified"
    }
  }
}

class StrobeState {
  var counter: Int = 0
  var timer: Timer
  var isStrobing: Bool
  var isLightOn: Bool
  var frequency: Double
  var start = DispatchTime.now()
  var end = DispatchTime.now()
  var period: Double = 0.05
  fileprivate var defaultDevice: AVCaptureDevice!
  
  init (){
    self.counter = 0
    self.timer = Timer()
    self.isStrobing = false
    self.isLightOn = false
    self.frequency = 200
  }
  
  // Start Strobe process
  func toggleStrobe () {
    if isLightOn == true {
      self.isLightOn = false
      self.timer.invalidate()
      print("Turning timer off")
      self.end = DispatchTime.now()
      let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
      let timeInterval = Double(nanoTime) / 1_000_000_000
      print("I counted this high \(counter) in this many seconds \(timeInterval)")
      counter = 0
    } else {
      self.isLightOn = true
      self.timer = Timer.scheduledTimer(timeInterval: period, target: self, selector: #selector(StrobeState.incrementCounter), userInfo: nil, repeats: true)
      print("Turning timer on")
      self.start = DispatchTime.now()
    }
  }
  
  // Increase counter by one
  
  @objc func incrementCounter () {
    self.counter += 1
    print("\(self.counter)")
  }
  //If light off turn on, if on turn off
  func toggleLight () {
    if #available(iOS 10.0, *) {
      guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .unspecified)else {
      return
    }
    defaultDevice = device
  } else {
  // Fallback on earlier versions
  defaultDevice = AVCaptureDevice.default(for: AVMediaType.video)
  }
}
}

    extension StrobeState: PitchEngineDelegate {
      
      func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
        
        period = 1/pitch.frequency
        
        /*
         print("pitch : \(pitch.frequency) - percentage : \(offsetPercentage)")
         
         guard absOffsetPercentage > 1.0 else {
         return
         }
         */
      }
      
      func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
        print(error)
      }
      
      public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
        print("Below level threshold")
      }
}
*/
// End of Chris/Drew Code

/*
/// Start of Github code
//
enum Type {
  
  // Enum Cases/Values
  case slow
  case normal
  case fast
  
  // Initialization method
  init() {
    self = .normal
  }
  
  // Return Value Type: Double
  var rawValue: Double {
    switch self {
    case .slow: return 0.7
    case .normal: return 0.5
    case .fast: return 0.3
    }
  }
}

/*!
 @enum Error
 @abstract
 Return error when an error occur, default error type is unknow.
 */
enum StrobeError: Error {
  
  // Enum Values/Cases:
  case targetSimulator
  case torchNotAvailable
  case unknown
  
  // Initialization method
  init() {
    self = .unknown
  }
  
  // Return Value Type: String
  var description: String {
    switch self {
    case .targetSimulator: return "Application is running on Simulator"
    case .torchNotAvailable: return "Torch not available on this device to show strobe light. Please run this app on a device with a torch"
    case .unknown: return "Error unspecified"
    }
  }
}

/*!
 @class Strobe Light
 @abstract
 A Strobe class will turn on the device torach as a torch and strobe light.
 */

class StrobeLights: NSObject {
  
  // MARK: - Properties & Variables
  fileprivate var defaultDevice: AVCaptureDevice!
  fileprivate var timer = Timer()
  
  public private(set) var isStrobeLightOn: Bool = false
  var isLightOn: Bool?
  var type = Type()
  
  // declare period to be passed in for Type()
  var period: Double = 0.05
 
  //MARK: Shared Instance
  static let sharedInstance : StrobeLights = {
    let instance = StrobeLights()
    return instance
  }()
  
  // Default Initialization Method
  
 override init() {
    super.init()
    isLightOn = false
    period = 0.05
    
    if #available(iOS 10.0, *) {
      guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .unspecified)
        else {
          return
      }
      defaultDevice = device
    } else {
      // Fallback on earlier versions
  
      defaultDevice = AVCaptureDevice.default(for: AVMediaType.video)
    }
  }
 
  
  // Deinitialization Method
  deinit {
    timer.invalidate()
  }
}

extension StrobeLights: PitchEngineDelegate {
  func pitchEngine(_ pitchEngine: PitchEngine, didReceivePitch pitch: Pitch) {
    
    period = 1/pitch.frequency
    
    /*
 print("pitch : \(pitch.frequency) - percentage : \(offsetPercentage)")
    
    guard absOffsetPercentage > 1.0 else {
      return
    }
 */
  }
  
  func pitchEngine(_ pitchEngine: PitchEngine, didReceiveError error: Error) {
    print(error)
  }
  
  public func pitchEngineWentBelowLevelThreshold(_ pitchEngine: PitchEngine) {
    print("Below level threshold")
  }
}

// MARK: - Custom Methods
extension StrobeLights {
  
  /*
   @method startStrobeLight:error:
   */
  
  func startStrobeLight() throws -> String {
    
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      throw StrobeError.targetSimulator
    #else
      if defaultDevice.hasTorch {
        if isStrobeLightOn {
          if timer.isValid {
            if timer.isValid { timer.invalidate(); stopTorch(); isLightOn = false }
          } else {
            isLightOn = true
            timer = Timer.scheduledTimer(timeInterval: period, target: self, selector: #selector(self.toggleTorch), userInfo: nil, repeats: true)
          }
        } else {
          if timer.isValid { timer.invalidate(); stopTorch() }
          _ = toggleTorch()
          isLightOn = true
        }
      } else {
        throw StrobeError.torchNotAvailable
      }
    #endif
    throw StrobeError.unknown
  }

/*
 @method toggleTorch
 @abstract
 Set device torch on and off and return bool value
 @description
 This method will change the device torch mode on or off. If device torch mode is on the method will return true and if torch mode is off then method will return false.
 */

@objc fileprivate func toggleTorch() -> Bool {
  
  // Check if the default device has torch
  if  defaultDevice.hasTorch {
    // Lock your default device for configuration
    do {
      // unlock your device when done
      defer {
        defaultDevice.unlockForConfiguration()
      }
      try defaultDevice.lockForConfiguration()
      
      // Toggles the torchMode
      defaultDevice.torchMode = defaultDevice.torchMode == .on ? .off : .on
      
      // Sets the torch intensity to 100%, if torchMode is ON
      if defaultDevice.torchMode == .on {
        do {
          try defaultDevice.setTorchModeOn(level: 1)
        } catch {
          print(error.localizedDescription)
        }
      }
    } catch {
      print(error.localizedDescription)
    }
  }
  
  return defaultDevice.torchMode == .on
}

/*
 @method stopTorch:error:
 @abstract
 Stop the torch mode of Device Light
 @discussion
 This method sets the torch mode off if device light is on.
 It invalidate the timer if timer is valid
 It also change the isLightOn variable value from true to false
 */
func stopTorch() {
  
  #if (arch(i386) || arch(x86_64)) && os(iOS)
  #else
    // Invalidate timer, If timer is valid
    if timer.isValid { timer.invalidate() }
    
    if defaultDevice.hasTorch {
      do {
        // Unlock your device when done & change strobe light status from true to false
        defer {
          isLightOn = false
          defaultDevice.unlockForConfiguration()
        }
        try defaultDevice.lockForConfiguration()
        defaultDevice.torchMode = .off
      } catch {
        print(error.localizedDescription)
      }
    } else {
    }
  #endif
}
}
*/
