//
//  AdvanceSwift_Optional.swift
//  SwiftTips
//
//  Created by cash on 26/07/2018.
//  Copyright © 2018 cash. All rights reserved.
//

import UIKit

// Optional
/*
extension Collection where Element: Equatable { func index(of element: Element) -> Optional<Index> {
        var idx = startIndex
        while idx != endIndex {
            if self[idx] == element {
                return .some(idx)
            }
            formIndex(after: &idx)
        }
        // 没有找到，返回 .none
        return .none
    }
}
 */

// 因为可选值 (optional) 在 Swift 中非常基础，所以有很多让它看起来更简单的语法: Optional<Index> 可以被写为 Index?;可选值遵守 ExpressibleByNilLiteral 协议，因 此你可以用 nil 来替代 .none;像上面 idx 这样的非可选值将在需要的时候自动 “升级” 为可选值，这样你就可以直接写 return idx，而不用 return .some(idx)。这个语法糖 实际上掩盖了 Optional 类型的真正本质。请时刻牢记，可选值并不是什么魔法，它就 是一个普通的枚举值。如果它不存在于语言中的话，你也完全可以自己定义一个。


class AdvanceSwift_Optional_2: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var array = ["one","two","three"]
        switch array.index(of: "four") {
        case .some(let idx):
            array.remove(at: idx)
        case .none:
            break // 什么都不做
        }
        
        switch array.index(of: "four") {
        case let idx?:
            array.remove(at: idx)
        case nil: break // 什么都不做
        }
        
        // 有用的例子
        let scanner = Scanner(string: "lisa123")
        var username: NSString?
        let alphas = CharacterSet.alphanumerics
        
        if scanner.scanCharacters(from: alphas, into: &username),
            let name = username {
            print(name)
        }
        
        // like compactMap
        let stringNumbers = ["1", "2", "three"]
        let maybeInts = stringNumbers.map { Int($0) } // [Optional(1), Optional(2), nil]
        for case let i? in maybeInts {
            // i 将是 Int 值，⽽不是 Int?
            print(i, terminator: " ")
            let _ = i
        }
        // 1 2
        
        // 或者只对 nil 值进⾏行行循环
        for case nil in maybeInts {
            // 将对每个 nil 执⾏行行⼀一次
            print("No value")
        }
        // No value
        
        
        // 这里使用了 x? 这个模式，它只会匹配那些非 nil 的值。这个语法是 .Some(x) 的简写形式，所以该循环还可以被写为:
        for case let .some(i) in maybeInts {
            print(i)
        }
        
        // 基于 case 的模式匹配可以让我们把在 switch 的匹配中用到的规则同样地应用到 if，for 和 while 上去。最有用的场景是结合可选值，
        let j = 5
        if case 0..<10 = j  {
            print("\(j) 在范围内")
        } // 5 在范围内
    }
}

func ~=(pattern: Pattern, value: String) -> Bool {
    return value.range(of: pattern.s) != nil
}

// case 本质
// 因为 case 匹配可以通过重载 ~= 运算符来进行扩展，所以你可以将 if case 和 for case 进行一些有趣的扩展:
struct Pattern {
    let s: String
    init(_ s: String) { self.s = s }
}

// 可选值是值类型，解包一个可选值做的事情是将它里面的值复制出来。
// 提前退出可以帮助我们在这个函数稍后的部分避免嵌套或者重复的检查。

// URL 和 NSString 的 pathExtension 属性
extension String {
    var fileExtension: String? {
        guard let period = index(of: ".") else {
            return nil
        }
        let extensionStart = index(after: period)
        return String(self[extensionStart...])
    }
}

// 可选链
extension Int {
    var half: Int? {
        guard self < -1 || self > 1 else { return nil }
        return self / 2
    }
}

extension Array {
    subscript(guarded idx: Int) -> Element? {
        guard (startIndex..<endIndex).contains(idx) else {
            return nil
        }
        return self[idx]
    }
}
// array[guarded: 5] ?? 0 // 0

class AdvanceSwift_Optional_3: UIViewController {
    
    func viewDidLoad0() {
        let s = "Taylor Swift"
        if case Pattern("Swift") = s {
            print("\(String(reflecting: s)) contains \"Swift\"")
        }
        // "Taylor Swift" contains "Swift"
    }
    
    func viewDidLoad2() {
        "hello.txt".fileExtension // Optional("txt")
    }
    
    func viewDidLoad3() {
        // ??
        let i: Int? = nil
        let j: Int? = nil
        if let n = i ?? j {
            // 和 if i != nil || j != nil 类似
            print(n)
        }

        // 因为可选值是链接的，如果你要处理的是双重嵌套的可选值，并且想要使用 ?? 操作符的话，你需要特别小心 a ?? b ?? c 和 (a ?? b) ?? c 的区别。
        // 前者是合并操作的链接，而后者是先解包括号内的内容，然后再处理外层:
        let s1: String?? = nil          // nil
let _ = (s1 ?? "inner") ?? "outer"      // inner
        let s2: String?? = .some(nil)   // Optional(nil)
let _ = (s2 ?? "inner") ?? "outer"      // outer
    }
}

// 在字符串插值中使用可选值
class AdvanceSwift_Optional_4: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bodyTemperature: Double? = 37.0
        let bloodGlucose: Double? = nil
        
        print("Body temperature: \(bodyTemperature ??? "n/a")") // Body temperature: 37.0
        print("Blood glucose level: \(bloodGlucose ??? "n/a")") // Blood glucose level: n/a
    }
}

infix operator ???: NilCoalescingPrecedence
                                // @autoclosure 标注确保了只有当需要的时候，我们才会对第二个表达式进行求值。
public func ???<T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    switch optional {
    case let value?: return String(describing: value)
    case nil: return defaultValue()
    }
}


// 数组第一个作为初始值的 reduce 方法
extension Array {
    func reduce(_ nextPartialResult: (Element, Element) -> Element) -> Element? {
        // 如果数组为空， first 将是 nil
        guard let fst =  first else { return nil }
        return dropFirst().reduce(fst, nextPartialResult)
    }
}
// [1, 2, 3, 4].reduce(+) // Optional(10)

// 因为可选值为 nil 时，可选值的 map 也会返回 nil -> version_2
extension Array {
    func reduce_alt(_ nextPartialResult: (Element, Element) -> Element) -> Element? {
        return first.map {
            dropFirst().reduce($0, nextPartialResult)
        }
    }
}

// Optional flatMap
extension Optional {
    func flatMap<U>(transform: (Wrapped) -> U?) -> U? {
        if let value = self, let transformed = transform(value) {
            return transformed
        }
        return nil
    }
}

// 使用 sequence_flatMap 过滤 nil
class AdvanceSwift_Optional_5: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let numbers = ["1", "2", "3", "foo"]
        var sum = 0   // 可选值模式匹配
        for case let i? in numbers.map({ Int($0) }) {
            sum += i
        }
        // sum // 6
let _ = numbers.flatMap { Int($0) }.reduce(0, +) // 6
    }
    
    // dict 置 nil
    func dictWithNil() {
        var dictWithNils: [String: Int?] = [ "one": 1,
                                             "two": 2,
                                             "none": nil
                                            ]
        
        dictWithNils["two"]  = Optional(nil)
        dictWithNils["two"]  = .some(nil)
        dictWithNils["two"]? = nil // 是因为 "two" 这个键已经存在于字典中了，所以它使用了可选链的方式来在获取成功后对值进行设置。
        // dictWithNils // ["none": nil, "one": Optional(1), "two": nil]
    }
    
    // 可选值的数组实现一个 ==
    /*
    func ==<T: Equatable>(lhs: [T?], rhs: [T?]) -> Bool {
        return lhs.elementsEqual(rhs) { $0 == $1 }
    }
     */
}

// 在这两个函数里，我们都使用了 lazy 来将数组的实际创建推迟到了使用前的最后一刻。这是一个小的优化，
// 不过如果在处理很大的数组时，这么做可以避免不必要的中间结果的缓冲区内存申请。

func flatten<S: Sequence, T>
    (source: S) -> [T] where S.Element == T? {
    let filtered = source.lazy.filter { $0 != nil }
    return filtered.map { $0! }
}

extension Sequence {
    func flatMap<U>(transform: (Element) -> U?) -> [U] {
        return flatten(source: self.lazy.map(transform))
    }
}

// 可选值判等
// == 有一个接受两个可选值的版本
func ==<T: Equatable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case (nil, nil): return true
    case let (x?, y?): return x == y
    case (_?, nil), (nil, _?): return false
    }
}

// 可选值比较
class AdvanceSwift_Optional_6: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let ages = [
            "Tim": 53,"Angela":54,"Craig":44,
            "Jony": 47, "Chris": 37, "Michael": 34,
        ]
        
let _ = ages.keys
            .filter { name in ages[name]! < 50 }
            .sorted()
        // ["Chris", "Craig", "Jony", "Michael"]
        
        // 去除 !
let _ = ages.filter { (_, age) in age < 50 }
            .map { (name, _) in name }
            .sorted()
        // ["Chris", "Craig", "Jony", "Michael"]
    }
}


// 改进强制解包的错误信息
infix operator !!
func !! <T>(wrapped: T?, failureText: @autoclosure () -> String) -> T {
    if let x = wrapped { return x }
    fatalError(failureText())
}
// let s = "foo"
// let i = Int(s) !! "Expecting integer, got \"\(s)\""


// 我们将这个操作符定义为对失败的解包进行断言，并且在断言不触发的发布版本中将值替换为默认值:
infix operator !?
func !?<T: ExpressibleByIntegerLiteral>
    (wrapped: T?, failureText: @autoclosure () -> String) -> T
{
    assert(wrapped != nil, failureText())
    return wrapped ?? 0
}
// let s = "20"
// let i = Int(s) !? "Expecting integer, got \"\(s)\""

func !?<T: ExpressibleByArrayLiteral>
    (wrapped: T?, failureText: @autoclosure () -> String) -> T
{
    assert(wrapped != nil, failureText())
    return wrapped ?? []
}

func !?<T: ExpressibleByStringLiteral>
    (wrapped: T?, failureText: @autoclosure () -> String) -> T
{
    assert(wrapped != nil, failureText)
    return wrapped ?? ""
}
// 多元组
func !?<T>(wrapped: T?,
           nilDefault: @autoclosure () -> (value: T, text: String)) -> T
{
    assert(wrapped != nil, nilDefault().text)
    return wrapped ?? nilDefault().value
}
// 调试版本中断言，发布版本中返回 5
// Int(s) !? (5, "Expected integer")

// 你可以写一个非泛型的版本来检测一个可选链调用碰到 nil，且并没有进行完操作的情况:
func !?(wrapped: ()?, failureText: @autoclosure () -> String) {
    assert(wrapped != nil, failureText)
}
var output: String? = nil
// output?.write("something") !? "Wasn't expecting chained nil here"



