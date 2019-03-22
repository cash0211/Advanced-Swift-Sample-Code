//
//  AdvanceSwift_Generic.swift
//  SwiftTips
//
//  Created by cash on 2019/3/17.
//  Copyright © 2019 cash. All rights reserved.
//

import Foundation

// 运算符的重载

// 幂运算⽐乘法运算优先级更⾼
precedencegroup ExponentiationPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}
infix operator **: ExponentiationPrecedence

func **(lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
}
func **(lhs: Float, rhs: Float) -> Float {
    return powf(lhs, rhs)
}

class AdvanceSwift_Generic {
    func op() {
        let _ = 2.0 ** 3.0 // 8.0
        
        let oneToThree = [1,2,3]
        let fiveToOne = [5,4,3,2,1]
let _ = oneToThree.isSubset(of: fiveToOne) // true
    }
}

// 使用泛型约束进行重载

// 时间复杂度是 O(nm)
extension Sequence where Element: Equatable {
    /// 当且仅当 `self` 中的所有元素都包含在 `other` 中，返回 true
    func isSubset(of other: [Element]) -> Bool {
        for element in self {
            guard other.contains(element) else {
                return false
            }
        }
        return true
    }
}

// O(n + m)
extension Sequence where Element: Hashable {
    /// 如果 `self` 中的所有元素都包含在 `other` 中，则返回 true
    func isSubset(of other: [Element]) -> Bool {
        let otherSet = Set(other)
        for element in self {
            guard otherSet.contains(element) else {
                return false
            }
        }
        return true
    }
}

// 实际上 isSubset 并不需要这么具体，在两个版本中只有两个函数调用，那就是两者中都有的 contains 以及 Hashable 版本中的 Set.init。

/*
extension Sequence where Element: Equatable {
    /// 根据序列列是否包含给定元素返回⼀一个布尔值。
    func contains(_ element: Element) -> Bool
}

struct Set<Element: Hashable>:
    SetAlgebra, Hashable, Collection, ExpressibleByArrayLiteral
{
    /// 通过⼀一个有限序列列创建新的集合。
    init<Source: Sequence>(_ sequence: Source)
        where Source.Element == Element
}
 */

extension Sequence where Element: Hashable {
    /// 如果 `self` 中的所有元素都包含在 `other` 中，则返回 true
    func isSubset<S: Sequence>(of other: S) -> Bool
        where S.Element == Element
    {
        let otherSet = Set(other)
        for element in self {
            guard otherSet.contains(element) else {
                return false
            }
        }
        return true
    }
}

//   [5,4,3].isSubset(of: 1...10) // true


/// 使用闭包对行为进行参数化
extension Sequence {
    func isSubset<S: Sequence>(of other: S,
                               by areEquivalent: (Element, S.Element) -> Bool) -> Bool
    {
        for element in self {
            guard other.contains(where: { areEquivalent(element, $0) }) else {
                return false
            }
        }
        return true
    }
}

class AdvanceSwift_Generic2 {
    func op2() {
        
let _ = [[1, 2]].isSubset(of: [[1, 2] as [Int], [3, 4]]) { $0 == $1 }  // true
        
        let ints = [1, 2]
        let strings = ["1", "2", "3"]
let _ = ints.isSubset(of: strings) { String($0) == $1 } // true
    }
}


// → 和 index(of:) 类似，我们返回一个可选值索引，nil 表示 “未找到”。
// → 它被定义两次，其中一次由用戶提供比较函数作为参数，另一次依赖于满足 Comparable 协议，来将它作为调用时的简便版本。
// → 序列元素的排序必须是严格弱序。也就是说，当比较两个元素时，要是两者互相都不能排在另一个的前面的话，它们就只能是相等的。


/// 泛型二分查找
extension RandomAccessCollection {
    public func binarySearch(for value: Element,
                             areInIncreasingOrder: (Element, Element) -> Bool) -> Index?
    {
        guard !isEmpty else { return nil }
        var left = startIndex
        var right = index(before: endIndex)
        while left <= right {
            let dist = distance(from: left, to: right)
            let mid = index(left, offsetBy: dist / 2)
            let candidate = self[mid]
            if areInIncreasingOrder(candidate, value) {
                left = index(after: mid)
            } else if areInIncreasingOrder(value, candidate) {
                right = index(before: mid)
            } else {
                // 由于 isOrderedBefore 的要求，
                // 如果两个元素互⽆无顺序关系，那么它们⼀定相等
                return mid
            }
        }
        //未找到
        return nil
    }
}

extension RandomAccessCollection where Element: Comparable {
    func binarySearch(for value: Element) -> Index? {
        return binarySearch(for: value, areInIncreasingOrder: <)
    }
}

// 集合随机排列

extension BinaryInteger {
    static func arc4random_uniform(_ upper_bound: Self) -> Self {
        precondition(
            upper_bound > 0 && UInt32(upper_bound) < UInt32.max, "arc4random_uniform only callable up to \(UInt32.max)")
        return Self(Darwin.arc4random_uniform(UInt32(upper_bound)))
    }
}

extension MutableCollection where Self: RandomAccessCollection {
    mutating func shuffle() {
        var i = startIndex
        let beforeEndIndex = index(before: endIndex)
        while i < beforeEndIndex {
            let dist = distance(from: i, to: endIndex)
            let randomDistance = IndexDistance.arc4random_uniform(dist)
            let j = index(i, offsetBy: randomDistance)
            self.swapAt(i, j)
            formIndex(after: &i)
        }
    }
}

extension Sequence {
    func shuffled() -> [Element] {
        var clone = Array(self)
        clone.shuffle()
        return clone
    }
}

class AdvanceSwift_Generic3 {
    func op() {
        var numbers = Array(1...10)
        numbers.shuffle()
let _ = numbers // [1, 3, 9, 8, 7, 5, 4, 6, 2, 10]
    }
}

// 只要它操作的集合也支持 RangeReplaceableCollection，就让它返回和它所随机的内容同样类型的集合
// 这个实现依赖了 RangeReplaceableCollection 的两个特性: <1> 可以创建一个新的空集合，<2> 可以将任意序列 (在这里，就是 self) 添加到空集合的后面。
extension MutableCollection
    where Self: RandomAccessCollection, Self: RangeReplaceableCollection
{
    func shuffled() -> Self {
        var clone = Self()
        clone.append(contentsOf: self)
        clone.shuffle()
        return clone
    }
}


// 提取共通功能

class webserviceURL: NSObject {
    class func appendingPathComponent(_ path: String) -> URL {
        return URL(string: path) ?? URL(string: "")!
    }
}

struct User {
    init(_ a: Any) {}
}

struct BlogPost {
    init(_ a: Any) {}
}

func loadResource<A>(at path: String, parse: (Any) -> A?, callback: (A?) -> ())
{
    let resourceURL = webserviceURL.appendingPathComponent(path)
    let data = try? Data(contentsOf: resourceURL)
    let json = data.flatMap {
        try? JSONSerialization.jsonObject(with: $0, options: []) }
    callback(json.flatMap(parse))
}

func jsonArray<A>(_ transform: @escaping (Any) -> A?) -> (Any) -> [A]? {
    return { array in
        guard let array = array as? [Any] else {
            return nil
        }
        return array.flatMap(transform)
    }
}

func loadUsers(callback: ([User]?) -> ()) {
    loadResource(at: "/users", parse: jsonArray(User.init), callback: callback)
}

func loadBlogPosts(callback: ([BlogPost]?) -> ()) {
    loadResource(at: "/posts", parse: jsonArray(BlogPost.init), callback: callback)
}

// 创建泛型数据类型
struct Resource<A> {
    let path: String
    let parse: (Any) -> A?
}

extension Resource {
    func loadSynchronously(callback: (A?) -> ()) {
        let resourceURL = webserviceURL.appendingPathComponent(path)
        let data = try? Data(contentsOf: resourceURL)
        let json = data.flatMap {
            try? JSONSerialization.jsonObject(with: $0, options: [])
        }
        callback(json.flatMap(parse))
    }
}

extension Resource {
    func loadAsynchronously(callback: @escaping (A?) -> ()) {
        let resourceURL = webserviceURL.appendingPathComponent(path)
        let session = URLSession.shared
        session.dataTask(with: resourceURL) { data, response, error in
            let json = data.flatMap {
                try? JSONSerialization.jsonObject(with: $0, options: [])
            }
            callback(json.flatMap(self.parse))
        }.resume()
    }
}

class AdvanceSwift_Generic4 {
    func op() {
        let usersResource: Resource<[User]>
            = Resource(path: "/users", parse: jsonArray(User.init))
        let postsResource: Resource<[BlogPost]>
            = Resource(path: "/posts", parse: jsonArray(BlogPost.init))
    }
}



