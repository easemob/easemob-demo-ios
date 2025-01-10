//
//  GCDTimer.swift
//  EaseChatDemo
//
//  Created by 朱继超 on 2024/3/5.
//

import Foundation


public protocol GCDTimer {
    // 启动
    func resume()
    // 暂停
    func suspend()
    // 取消
    func cancel()
}

public class GCDTimerMaker {
    
    static func exec(_ task: (() -> ())?, interval: Int, repeats: Bool = true, async: Bool = true) -> GCDTimer? {
        
        guard let _ = task else {
            return nil
        }
        
        return TimerMaker(task,
                          deadline: .now(),
                          repeating: repeats ? .seconds(interval):.never,
                          async: async)
        
    }
}

private class TimerMaker: GCDTimer {
    
    /// 当前 Timer 运行状态
    enum TimerState {
        case running
        case stopped
        case suspended
    }
    
    private var state: TimerState = .stopped
    private var timer: DispatchSourceTimer?
    private let stateQueue = DispatchQueue(label: "com.timer.state.queue") // 用于保护状态访问
    
    convenience init(
        _ exce: (() -> Void)?,
        deadline: DispatchTime,
        repeating interval: DispatchTimeInterval = .never,
        leeway: DispatchTimeInterval = .seconds(0),
        async: Bool = true
    ) {
        self.init()
        
        let queue = async ? DispatchQueue.global() : DispatchQueue.main
        timer = DispatchSource.makeTimerSource(queue: queue)
        
        timer?.schedule(deadline: deadline, repeating: interval, leeway: leeway)
        
        timer?.setEventHandler {
            exce?()
        }
    }
    
    /// 开始计时器
    func resume() {
        stateQueue.sync {
            guard state != .running else { return }
            state = .running
            timer?.resume()
        }
    }
    
    /// 暂停计时器
    func suspend() {
        stateQueue.sync {
            guard state != .suspended else { return }
            state = .suspended
            timer?.suspend()
        }
    }
    
    /// 停止并释放计时器
    func cancel() {
        stateQueue.sync {
            guard let timer = timer,state != .stopped else { return }
            state = .stopped
            if timer.isCancelled { return }
            timer.cancel()
            
            // 清空事件处理程序以释放强引用
            timer.setEventHandler {}
            
            // 延迟释放 DispatchSourceTimer
            self.timer = nil
        }
    }
    
    deinit {
        cancel() // 确保释放时安全地清理计时器
    }
}


