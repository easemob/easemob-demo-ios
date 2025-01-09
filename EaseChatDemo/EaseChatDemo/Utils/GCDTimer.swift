//
//  GCDTimer.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import Foundation
import Dispatch

public protocol GCDTimer {
    func resume()
    func suspend()
    func cancel()
}

public class GCDTimerMaker {
    
    @discardableResult
    static func exec(_ task: (() -> ())?,
                     interval: TimeInterval,
                     repeats: Bool = true,
                     async: Bool = true) -> GCDTimer? {
        
        guard let task = task else { return nil }
        
        return TimerMaker(task,
                         deadline: .now(),
                         repeating: repeats ? .milliseconds(Int(interval * 1000)) : .never,
                         async: async)
    }
}

private class TimerMaker:NSObject, GCDTimer {
    
    enum TimerState {
        case initialized
        case running
        case suspended
        case cancelled
    }
    
    private let queue = DispatchQueue(label: "com.timer.state", attributes: .concurrent)
    private var _state: TimerState = .initialized
    private var state: TimerState {
        get { queue.sync { _state } }
        set { queue.async(flags: .barrier) { self._state = newValue } }
    }
    
    private var timer: DispatchSourceTimer?
    
    convenience init(_ exec: @escaping (() -> ()),
                    deadline: DispatchTime,
                    repeating interval: DispatchTimeInterval = .never,
                    leeway: DispatchTimeInterval = .milliseconds(100),
                    async: Bool = true) {
        self.init()
        
        let queue = async ? DispatchQueue.global() : DispatchQueue.main
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: deadline,
                       repeating: interval,
                       leeway: leeway)
        
        timer?.setEventHandler { [weak self] in
            guard self?.state == .running else { return }
            exec()
        }
    }
    
    deinit {
        cancel()
    }
    
    func resume() {
        queue.async(flags: .barrier) {
            guard self._state != .running && self._state != .cancelled else { return }
            self._state = .running
            self.timer?.resume()
        }
    }
    
    func suspend() {
        queue.async(flags: .barrier) {
            guard self._state == .running else { return }
            self._state = .suspended
            self.timer?.suspend()
        }
    }
    
    func cancel() {
        queue.async(flags: .barrier) {
            guard self._state != .cancelled else { return }
            self._state = .cancelled
            self.timer?.cancel()
            self.timer = nil
        }
    }
}


