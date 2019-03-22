//
//  AdvanceSwift_Struct&Class.swift
//  SwiftTips
//
//  Created by cash on 2019/3/6.
//  Copyright © 2019 cash. All rights reserved.
//

import UIKit
import Foundation

// 写时复制 (昂贵方式)
struct MyData {
    fileprivate var _data: NSMutableData
    fileprivate var _dataForWriting: NSMutableData {
        mutating get {
            _data = _data.mutableCopy() as! NSMutableData
            return _data
        }
    }
    init() {
        _data = NSMutableData()
    }
    
    init(_ data: NSData) {
        _data = data.mutableCopy() as! NSMutableData
    }
}

extension MyData {
    mutating func append(_ byte: UInt8) {
        var mutableByte = byte
        _dataForWriting.append(&mutableByte, length: 1)
    }
}

class AdvanceSwift_Struct_Class {
    func operation() {
        let theData = NSData(base64Encoded: "wAEP/w==")!
        var x = MyData(theData)
        let y = x
let _ = x._data === y._data // true
        x.append(0x55)
let _ = y // <c0010fff>
let _ = x._data === y._data // false
        
        // 多次复制，效率低
        var buffer = MyData(NSData())
        for byte in 0..<5 as CountableRange<UInt8> {
            buffer.append(byte)
        }
    }
}

// 写时复制 (高效方式)

final class Box<A> {
    var unbox: A
    init(_ value: A) { self.unbox = value }
}

struct MyData2 {
    private var _data: Box<NSMutableData>
    var _dataForWriting: NSMutableData {
        mutating get {
            if !isKnownUniquelyReferenced(&_data) {
                _data = Box(_data.unbox.mutableCopy() as! NSMutableData)
                print("Making a copy")
            }
            return _data.unbox
        }
    }
    
    init() {
        _data = Box(NSMutableData())
    }
    
    init(_ data: NSData) {
        _data = Box(data.mutableCopy() as! NSMutableData)
    }
}

extension MyData2 {
    mutating func append(_ byte: UInt8) {
        var mutableByte = byte
        _dataForWriting.append(&mutableByte, length: 1)
    }
}

class AdvanceSwift_Struct_Class2 {
    func operation() {
        var x = Box(NSMutableData())
let _ = isKnownUniquelyReferenced(&x) // true
        
        let y = x
let _ = isKnownUniquelyReferenced(&x) // false
    }
    
    func operation2() {
        var bytes = MyData()
        var copy = bytes
        for byte in 0..<5 as CountableRange<UInt8> {
            print("Appending 0x\(String(byte, radix: 16))")
            bytes.append(byte)
        }
        /*
         Appending 0x0
         Making a copy
         Appending 0x1
         Appending 0x2
         Appending 0x3
         Appending 0x4
         */
let _ = bytes // <00010203 04>
let _ = copy // <>
    }
}

// 写时复制的陷阱

final class Empty { }

struct COWStruct {
    var ref = Empty()
    mutating func change() -> String {
        if isKnownUniquelyReferenced(&ref) {
            return "No copy"
            
        } else {
            return "Copy"
        }
        // 进⾏实际改变
    }
}

struct ContainerStruct<A> {
    var storage: A
    subscript(s: String) -> A {
        get { return storage }
        set { storage = newValue }
    }
}

class AdvanceSwift_Struct_Class3 {
    func operation() {
        var array = [COWStruct()]
let _ = array[0].change() // No copy
        
        var otherArray = [COWStruct()]
        var x = array[0]
let _ = x.change() // Copy
        
        var d = ContainerStruct(storage: COWStruct())
let _ = d.storage.change() // No copy
let _ = d["test"].change() // Copy
    }
}

// 闭包和可变性
func uniqueIntegerProvider() -> AnyIterator<Int> {
    var i = 0
    return AnyIterator {
        i += 1
        return i
    }
}


// 闭包和内存
class AdvanceSwift_Struct_Class4 {
    func operation() {
        let handle = FileHandle(forWritingAtPath: "out.html")
        let request = URLRequest(url: URL(string: "https://www.objc.io")!)
        URLSession.shared.dataTask(with: request) { (data, _, _) in
            guard let theData = data else { return }
            // 闭包将对 handle 进⾏行行强引⽤用
            handle?.write(theData)
        }.resume()
    }
}

// 捕获列表
class View {
    var window: Window
    init(window: Window) {
        self.window = window
    }
    deinit {
        print("Deinit View")
    }
}

class Window {
    weak var rootView: View?
    var onRotate: (() -> ())?
    deinit {
        print("Deinit Window")
    }
}

class AdvanceSwift_Struct_Class5 {
    func operation() {
        var window: Window? = Window()
        var view: View? = View(window: window!)
        window?.rootView = view
        window?.onRotate = { [weak view, weak myWindow=window, x=5*5] in
            print("We now also need to update the view: \(view)")
            print("Because the window \(myWindow) changed")
        }
    }
}

