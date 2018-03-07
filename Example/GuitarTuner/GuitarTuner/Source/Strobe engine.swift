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




class StrobeLights: NSObject {
  var counter: Int = 0
  var timer: DispatchSourceTimer?
  var isStrobing: Bool
  var isLightOn: Bool
  var frequency: Double
  var start = DispatchTime.now()
  var end = DispatchTime.now()
  var active: Bool
  var device: AVCaptureDevice
  let torchLevelOn: Float = 1.0
  var torchLevelOff: Float = 0.001
  @ objc dynamic var torchLevel: Float = 0.5
  var keyPathToTorchLevel: String = "torchLevel"
  
  //var workItem: DispatchWorkItem?
  
  
  private func stopTimer() {
    timer?.cancel()
    timer = nil
  }
  
  
  
  
  override init (){
    self.isStrobing = false
    self.isLightOn = false
    self.counter = 0
    self.frequency = 100
    self.active = false
    self.device = AVCaptureDevice.default(for: AVMediaType.video)!
    super .init()
    self.device.addObserver(self, forKeyPath: #keyPath(torchLevel), options: .new, context: nil)
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
  private var myContext = 0.0
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    //https://stackoverflow.com/questions/24092285/is-key-value-observation-kvo-available-in-swift
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
    torchLevel = self.device.torchLevel
    if on == true {
      do {
        try device.lockForConfiguration()
      }
      catch {
        print("could not lock for configuration")
        return
      }
      do {
        try device.setTorchModeOn(level: torchLevelOn)
        print("torch on \(torchLevel)")
      }
      catch { print("could not set torchLevelOff")
        return
      }
      device.unlockForConfiguration()
    } else {
      do {
        try device.lockForConfiguration()
      }
      catch {
        print("could not lock for configuration")
        return
      }
      do {try device.setTorchModeOn(level: torchLevelOff)
        print("torch off \(torchLevel)")
        
      }
      catch { print("could not set torchLevelOff")
        return
      }
      device.unlockForConfiguration()
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

