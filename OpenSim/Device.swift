//
//  Device.swift
//  SimPholders
//
//  Created by Luo Sheng on 11/9/15.
//  Copyright © 2015 Luo Sheng. All rights reserved.
//

import Foundation

struct Device {
    
    enum State: String {
        case Shutdown = "Shutdown"
        case Unknown = "Unknown"
        case Booted = "Booted"
    }
    
    let UDID: String
    let type: String
    let name: String
    let runtime: Runtime
    let state: State
    let applications: [Application]
    
    init(UDID: String, type: String, name: String, runtime: String, state: State) {
        self.UDID = UDID
        self.type = type
        self.name = name
        self.runtime = Runtime(name: runtime)
        self.state = state
        
        let applicationPath = try! URLHelper.deviceURLForUDID(self.UDID).appendingPathComponent("data/Containers/Bundle/Application")
        do {
            let contents = try FileManager.default().contentsOfDirectory(at: applicationPath, includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles])
            self.applications = contents.map { Application(url: $0) }.filter { $0 != nil }.map { $0! }
        } catch {
            self.applications = []
        }
    }
    
    var fullName:String {
        get {
            return "\(self.name) (\(self.runtime))"
        }
    }
    
    func containerURLForApplication(_ application: Application) -> URL? {
        let URL = URLHelper.containersURLForUDID(UDID)
        do {
            let directories = try FileManager.default().contentsOfDirectory(at: URL, includingPropertiesForKeys: nil, options: .skipsSubdirectoryDescendants)
            if let matchingURL = directories.filter({ dir -> Bool in
                if let contents = NSDictionary(contentsOf: try! dir.appendingPathComponent(".com.apple.mobile_container_manager.metadata.plist")),
                   identifier = contents["MCMMetadataIdentifier"] as? String
                where identifier == application.bundleID {
                    return true
                }
                return false
            }).first {
                return matchingURL
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
}
