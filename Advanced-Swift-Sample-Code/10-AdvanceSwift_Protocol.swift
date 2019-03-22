//
//  AdvanceSwift_Protocol.swift
//  SwiftTips
//
//  Created by cash on 2019/3/19.
//  Copyright © 2019 cash. All rights reserved.
//

import Foundation
import UIKit

// 面向协议编程

protocol Drawing {
    mutating func addEllipse(rect: CGRect, fill: UIColor)
    mutating func addRectangle(rect: CGRect, fill: UIColor)
}

extension CGContext: Drawing {
    func addEllipse(rect: CGRect, fill: UIColor) {
        setFillColor(fill.cgColor)
        fillEllipse(in: rect)
    }
    
    func addRectangle(rect: CGRect, fill fillColor: UIColor) {
        setFillColor(fillColor.cgColor)
        fill(rect)
    }
}

/*
struct SVG {
    var rootNode = XMLNode(tag: "svg")
    mutating func append(node: XMLNode) {
        rootNode.children.append(node)
    }
}

extension SVG: Drawing {
    mutating func addEllipse(rect: CGRect, fill: UIColor) {
        var attributes: [String:String] = rect.svgAttributes
        attributes["fill"] = String(hexColor: fill)
        append(node: XMLNode(tag: "ellipse", attributes: attributes))
    }
    
    mutating func addRectangle(rect: CGRect, fill: UIColor) {
        var attributes: [String:String] = rect.svgAttributes
        attributes["fill"] = String(hexColor: fill)
        append(node: XMLNode(tag: "rect", attributes: attributes))
    }
}
 
 var context: Drawing = SVG()
 let rect1 = CGRect(x: 0, y: 0, width: 100, height: 100)
 let rect2 = CGRect(x: 0, y: 0, width: 50, height: 50)
 context.addRectangle(rect: rect1, fill: .yellow)
 context.addEllipse(rect: rect2, fill: .blue)
 */

// 协议扩展

extension Drawing {
    mutating func addCircle(center: CGPoint, radius: CGFloat, fill: UIColor) {
        let diameter = radius * 2
        let origin = CGPoint(x: center.x - radius, y: center.y - radius)
        let size = CGSize(width: diameter, height: diameter)
        let rect = CGRect(origin: origin, size: size)
        addEllipse(rect: rect, fill: fill)
    }
}

// 类型抹消

struct ConstantIterator: IteratorProtocol {
    public mutating func next() -> Int? {
        return 1
    }
}

class IntIterator {
    var nextImpl: () -> Int?
    
    init<I: IteratorProtocol>(_ iterator: I) where I.Element == Int {
        var iteratorCopy = iterator
        self.nextImpl = { iteratorCopy.next() }
    }
}

extension IntIterator: IteratorProtocol {
    func next() -> Int? {
        return nextImpl()
    }
}

class AdvanceSwift_Protocol {
    func op() {
        var iter = IntIterator(ConstantIterator())
        iter = IntIterator([1,2,3].makeIterator())
    }
}

private class AnyIterator<A>: IteratorProtocol {
    var nextImpl: () -> A?
    
    init<I: IteratorProtocol>(_ iterator: I) where I.Element == A {
        var iteratorCopy = iterator
        self.nextImpl = { iteratorCopy.next() }
    }
    
    func next() -> A? {
        return nextImpl()
    }
}


// 标准库采用

class IteratorBox<Element>: IteratorProtocol {
    func next() -> Element? {
        fatalError("This method is abstract.")
    }
}

// 这个类的目的是将底层的迭代器存储在一个属性中。next 方法简单地将调用转给底层迭代器的 next 方法

// 现在是取巧的部分了。我们把 IteratorBoxHelper 变为 IteratorBox 的子类，IteratorBox 的泛 型参数为 I 的元素类型，
// 这样我们就可以把两个泛型参数进行约束:
class IteratorBoxHelper<I: IteratorProtocol>: IteratorBox<I.Element> {
    var iterator: I
    
    init(_ iterator: I) {
        self.iterator = iterator
    }
    
    override func next() -> I.Element? {
        return iterator.next()
    }
}

// “魔法” 发生在 IteratorBoxHelper 的初始化方法中。IteratorBox 不能直接将被封装的迭代器存 储在变量中，否则的话它就需要对具体的迭代器类型进行泛型化，这其实正是我们想要避免的。
// 现在的解决方式将这个属性 (以及它的具体类型) 隐藏在了子类中，这能够避免对具体的迭代器 类型使用泛型。这样一来，IteratorBox 就可以只对元素的类型进行泛型化了。

class AdvanceSwift_Protocol2 {
    func op() {
        // 现在，我们就可以创建一个 IteratorBoxHelper 类型的值，并且将它当作 IteratorBox 来用，这有效地抹消了 I 的类型:
        let iter: IteratorBox<Int> = IteratorBoxHelper(ConstantIterator())
    }
}


// 协议内幕

func f<C: CustomStringConvertible>(_ x: C) -> Int {
    return MemoryLayout.size(ofValue: x)
}

func g(_ x: CustomStringConvertible) -> Int {
    return MemoryLayout.size(ofValue: x)
}

class AdvanceSwift_Protocol3 {
    func op() {
let _ = f(5) // 8
let _ = g(5) // 40
    }
}
