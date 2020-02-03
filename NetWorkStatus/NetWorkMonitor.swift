//
//  MonitorTask.swift
//

import Foundation

open class NetWorkMonitor: NSObject {
    let statusItemView: StatusItemView
    init(statusItemView view: StatusItemView) {
        statusItemView = view
    }
    
    let interval: Double = 2
    var preBytesIn: Double = -1
    var preBytesOut: Double = -1
    
    func start() {
        Thread(target: self, selector: #selector(startUpdateTimer), object: nil).start()
    }
    
    @objc func startUpdateTimer() {
        Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(updateNetWorkData), userInfo: nil, repeats: true)
        RunLoop.current.run()
    }
    
    // nettop -x -k state -k interface -k rx_dupe -k rx_ooo -k re-tx -k rtt_avg -k rcvsize -k tx_win -k tc_class -k tc_mgt -k cc_algo -k P -k C -k R -k W -k arch -l 1 -t wifi -t wired
    // nettop -x -l 1 -J bytes_in,bytes_out -t external
    @objc func updateNetWorkData() {
        let task = Process()
        task.launchPath = "/usr/bin/nettop"
        task.arguments = ["-x", "-l", "1", "-J", "bytes_in,bytes_out", "-t", "external"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        task.launch()
        
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = pipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            self.handleNetWorkData(outputString)
        }
    }
    
    
    func handleNetWorkData(_ string: String) {
        var bytesIn: Double = 0
        var bytesOut: Double = 0
        
        let pattern = "\\.\\d+\\s+(\\d+)\\s+(\\d+)\\n"
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let results = regex.matches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count))
            for result in results {
                bytesIn += Double((string as NSString).substring(with: result.range(at: 1)))!
                bytesOut += Double((string as NSString).substring(with: result.range(at: 2)))!
            }
            bytesIn /= interval
            bytesOut /= interval
            
            if (preBytesOut != -1) {
                statusItemView.setRateData(up: bytesOut-preBytesOut, down: bytesIn-preBytesIn)
            }
            preBytesOut = bytesOut
            preBytesIn = bytesIn
        }
        catch {}
    }

}
