//
//  ViewController.swift
//  mag
//
//  Created by 김태우 on 2021/07/13.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    @IBOutlet weak var mag_raw: UILabel!
    @IBOutlet weak var mag_cal: UILabel!
    
    let motionman = CMMotionManager()
    
    var updateMotionManagerHandler: CMMagnetometerHandler? = nil
    var updateDeviceMotionHandler: CMDeviceMotionHandler? = nil
    
    let updateInterval = 0.1
    
    var total_cal: Double = 0
    var total_raw: Double = 0
    
    let generator_light = UIImpactFeedbackGenerator(style: .light)
    let generator_med = UIImpactFeedbackGenerator(style: .medium)
    let generator_heavy = UIImpactFeedbackGenerator(style: .heavy)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if motionman.isMagnetometerAvailable {
            motionman.magnetometerUpdateInterval = updateInterval
            motionman.deviceMotionUpdateInterval = updateInterval
            
            updateMotionManagerHandler = {(magnetoData: CMMagnetometerData?,error:Error?) -> Void in
                self.outputMagnetDataByMotionManager(magnet: magnetoData!.magneticField)
            }
            
            updateDeviceMotionHandler = {(deviceMotion: CMDeviceMotion?, error: Error?) -> Void in
                self.outputMagnetDataByDeviceMotion(magnet: self.motionman.deviceMotion!.magneticField)
            }
        }
        
        start()
    
    }
        
    func outputMagnetDataByMotionManager(magnet: CMMagneticField) {
        total_raw = sqrt(pow(magnet.x, 2) + pow(magnet.y, 2) + pow(magnet.z, 2))
        mag_raw.text = String(format: "%10f", total_raw)
    }
    
    func outputMagnetDataByDeviceMotion(magnet: CMCalibratedMagneticField) {
        total_cal = sqrt(pow(magnet.field.x, 2) + pow(magnet.field.y, 2) + pow(magnet.field.z, 2))
        mag_cal.text = String(format: "%10f", total_cal)
    }
    
    func check_mag() {
        DispatchQueue(label: "vibration").async { [self] in
            while true {
                if (total_cal < 500 && total_raw <= 1000) {
                    vib_light()
                    sleep(1)
                }
                else if (total_cal >= 500 && total_cal < 1000) {
                    vib_med()
                    usleep(500000)
                }
                else if (total_cal >= 1000) {
                    vib_med()
                    usleep(250000)
                }
                else if (total_raw >= 4000 && total_cal == 0) {
                    vib_heavy()
                    usleep(100000)
                    vib_heavy()
                    usleep(250000)
                }
            }
        }
        
    }
    
    func vib_light() {
        generator_light.impactOccurred()
    }
    
    func vib_med() {
        generator_med.impactOccurred()
    }
    
    func vib_heavy() {
        generator_heavy.impactOccurred()
    }
    
    func start() {
        DispatchQueue(label: "main").async { [self] in
            
            motionman.startMagnetometerUpdates(to: OperationQueue.main, withHandler: updateMotionManagerHandler!)
            motionman.startDeviceMotionUpdates(using: CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical, to: OperationQueue.main,
                                               withHandler:updateDeviceMotionHandler!)
        }
        
        check_mag()
    }
}

