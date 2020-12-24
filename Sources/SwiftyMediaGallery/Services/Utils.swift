//
//  Utils.swift
//  SwiftyMediaGallery
//
//  Created by nati on 14/08/2020.
//  Copyright © NatiTK. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Photos

class Utils{
    
    class func getFreeMemory(){
        var pagesize: vm_size_t = 0
        let host_port: mach_port_t = mach_host_self()
        var host_size: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)
        host_page_size(host_port, &pagesize)

        var vm_stat: vm_statistics = vm_statistics_data_t()
        withUnsafeMutablePointer(to: &vm_stat) { (vmStatPointer) -> Void in
            vmStatPointer.withMemoryRebound(to: integer_t.self, capacity: Int(host_size)) {
                if (host_statistics(host_port, HOST_VM_INFO, $0, &host_size) != KERN_SUCCESS) {
                    print("Error: Failed to fetch vm statistics")
                }
            }
        }

        let mem_used: Int64 = Int64(vm_stat.active_count +
             vm_stat.inactive_count +
             vm_stat.wire_count) * Int64(pagesize)
        let mem_free: Int64 = Int64(vm_stat.free_count) * Int64(pagesize)
        print("\(mem_free / 1000 / 1000) memory free");
        print("\(mem_used / 1000 / 1000) memory used");
    }
    
    class func galleryStoryboard() -> UIStoryboard {
        let storyboard = UIStoryboard(name: "Gallery", bundle:Bundle(for: Self.self))
        return storyboard
    }

    class func setAudioSession(withSpeaker : Bool = false)
    {
        var options : AVAudioSession.CategoryOptions =  [.allowBluetooth, .allowBluetoothA2DP,.mixWithOthers]
        if withSpeaker {
            options.insert(.defaultToSpeaker)
        }
        try? AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options:options)
        try? AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
    }
    
}

