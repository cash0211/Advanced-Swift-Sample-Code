//
//  AdvanceSwift_Function.swift
//  SwiftTips
//
//  Created by cash on 2019/3/8.
//  Copyright © 2019 cash. All rights reserved.
//

import UIKit

// 函数的灵活性
@objcMembers
final class Person: NSObject {
    let first: String
    let last: String
    let yearOfBirth: Int
    init(first: String, last: String, yearOfBirth: Int) {
        self.first = first
        self.last = last
        self.yearOfBirth = yearOfBirth
    }
}

let people = [
    Person(first: "Emily", last: "Young", yearOfBirth: 2002),
    Person(first: "David", last: "Gray", yearOfBirth: 1991),
    Person(first: "Robert", last: "Barnes", yearOfBirth: 1985),
    Person(first: "Ava", last: "Barnes", yearOfBirth: 2000),
    Person(first: "Joanne", last: "Miller", yearOfBirth: 1994),
    Person(first: "Ava", last: "Barnes", yearOfBirth: 1998),
]

let lastDescriptor = NSSortDescriptor(key: #keyPath(Person.last), ascending: true,
                                      selector: #selector(NSString.localizedStandardCompare(_:)))
let firstDescriptor = NSSortDescriptor(key: #keyPath(Person.first),
                                       ascending: true,
                                       selector: #selector(NSString.localizedStandardCompare(_:)))
let yearDescriptor = NSSortDescriptor(key: #keyPath(Person.yearOfBirth),
                                      ascending: true)

class AdvanceSwift_Function {
    func op() {
        
        let descriptors = [lastDescriptor, firstDescriptor, yearDescriptor]
        (people as NSArray).sortedArray(using: descriptors)
        /*
         [Ava Barnes (1998), Ava Barnes (2000), Robert Barnes (1985),
         David Gray (1991), Joanne Miller (1994), Emily Young (2002)]
         */
        
        var strings = ["Hello", "hallo", "Hallo", "hello"]
        strings.sort { $0.localizedStandardCompare($1) == .orderedAscending}
let _ = strings // ["hallo", "Hallo", "hello", "Hello"]
        
        
let _ = people.sorted { p0, p1 in
            let left = [p0.last, p0.first]
            let right = [p1.last, p1.first]
            return left.lexicographicallyPrecedes(right) {
                $0.localizedStandardCompare($1) == .orderedAscending
            }
        }
        /*
         [Ava Barnes (2000), Ava Barnes (1998), Robert Barnes (1985),
         David Gray (1991), Joanne Miller (1994), Emily Young (2002)] */
    }
}

// 函数作为数据

/// ⼀个排序断⾔，当且仅当第⼀个值应当排序在第⼆个值之前时，返回 `true`
typealias SortDescriptor<Value> = (Value, Value) -> Bool

let sortByYear: SortDescriptor<Person> = { $0.yearOfBirth < $1.yearOfBirth }
let sortByLastName: SortDescriptor<Person> = {
    $0.last.localizedStandardCompare($1.last) == .orderedAscending
}

class AdvanceSwift_Function2 {

    /// 通过⼀个排序断⾔，以及⼀个能给定某个值，就能对应产生应该⽤于排序断⾔的值的 `key` 函数，来构建一个 `SortDescriptor` 函数。
    func sortDescriptor1<Value, Key>(
        key: @escaping (Value) -> Key,
        by areInIncreasingOrder: @escaping (Key, Key) -> Bool)
        -> SortDescriptor<Value> {
            return { areInIncreasingOrder(key($0), key($1)) }
    }
    // key 函数描述了如何深入一个值，并提取出和一个特定的排序步骤相关的信息的方式。它和 Swift 4 引入的 Swift 原生键路径有很多相同之处。
    
    func op2() {
        let sortByYearAlt: SortDescriptor<Person> =
            sortDescriptor1(key: { $0.yearOfBirth }, by: <)
let _ = people.sorted(by: sortByYearAlt)
        /*
         [Robert Barnes (1985), David Gray (1991), Joanne Miller (1994),
         Ava Barnes (1998), Ava Barnes (2000), Emily Young (2002)] */
        
        
        // 所有的 Comparable 类型定义一个重载版本的函数:
        func sortDescriptor<Value, Key>(key: @escaping (Value) -> Key)
            -> SortDescriptor<Value> where Key: Comparable
        {
            return { key($0) < key($1) }
        }
        
        let sortByYearAlt2: SortDescriptor<Person> =
            sortDescriptor(key: { $0.yearOfBirth })
    }
    
    
    
    // 增加 ComparisonResult 这类函数的支持
    func sortDescriptor<Value, Key>(
        key: @escaping (Value) -> Key,
        ascending: Bool = true,
        by comparator: @escaping (Key) -> (Key) -> ComparisonResult)
        -> SortDescriptor<Value>
    {
        return { lhs, rhs in
            let order: ComparisonResult = ascending
                ? .orderedAscending
                : .orderedDescending
            return comparator(key(lhs))(key(rhs)) == order
        }
    }
    
    // 我们可以创建一个函数来将多个排序描述符合并为单个的排序描述符。
    func combine<Value>
        (sortDescriptors: [SortDescriptor<Value>]) -> SortDescriptor<Value> {
        return { lhs, rhs in
            for areInIncreasingOrder in sortDescriptors {
                if areInIncreasingOrder(lhs, rhs) { return true }
                if areInIncreasingOrder(rhs, lhs) { return false }
            }
            return false
        }
    }
    
    func op3() {
        let sortByFirstName: SortDescriptor<Person> =
            sortDescriptor(key: { $0.first }, by: String.localizedStandardCompare)
        let _ = people.sorted(by: sortByFirstName)
        /*
         [Ava Barnes (2000), Ava Barnes (1998), David Gray (1991),
         Emily Young (2002), Joanne Miller (1994), Robert Barnes (1985)] */
    
    
        let combined: SortDescriptor<Person> = combine(
            sortDescriptors: [sortByLastName, sortByFirstName, sortByYear]
        )
let _ = people.sorted(by: combined)
        /*
         [Ava Barnes (1998), Ava Barnes (2000), Robert Barnes (1985),
         David Gray (1991), Joanne Miller (1994), Emily Young (2002)] */
    }
}

// 自定义的运算符，来合并两个排序函数
infix operator <||> : LogicalDisjunctionPrecedence
func <||><A>(lhs: @escaping (A,A) -> Bool, rhs: @escaping (A,A) -> Bool)
    -> (A,A) -> Bool
{
    return { x, y in
        if lhs(x, y) { return true }
        if lhs(y, x) { return false }
        // 否则，它们就是⼀样的，所以我们检查第⼆个条件
        if rhs(x, y) { return true }
        return false
    }
}
/*
let combinedAlt = sortByLastName <||> sortByFirstName <||> sortByYear
people.sorted(by: combinedAlt)
/*
 [Ava Barnes (1998), Ava Barnes (2000), Robert Barnes (1985),
 David Gray (1991), Joanne Miller (1994), Emily Young (2002)] */
 */


// 处理可选值
func lift<A>(_ compare: @escaping (A) -> (A) -> ComparisonResult) -> (A?) -> (A?)
    -> ComparisonResult
{
    return { lhs in { rhs in
        switch (lhs, rhs) {
        case (nil, nil): return .orderedSame
        case (nil, _): return .orderedAscending
        case (_, nil): return .orderedDescending
        case let (l?, r?): return compare(l)(r)
        }}
    }
}
/*
let compare = lift(String.localizedStandardCompare)
let result = files.sorted(by: sortDescriptor(key: { $0.fileExtension },
                                             by: compare))
result  // ["one", "file.c", "file.h", "test.h"]
 */



/// 局部函数和变量捕获

// merge 需要一些临时的存储空间。
extension Array where Element: Comparable {
    private mutating func merge(lo: Int, mi: Int, hi: Int) {
        var tmp: [Element] = []
        var i = lo, j = mi
        while i != mi && j != hi {
            if self[j] < self[i] {
                tmp.append(self[j])
                j += 1
            } else {
                tmp.append(self[i])
                i += 1
            }
        }
        
        tmp.append(contentsOf: self[i..<mi])
        tmp.append(contentsOf: self[j..<hi])
        replaceSubrange(lo..<hi, with: tmp)
    }
    mutating func mergeSortInPlaceInefficient() {
        let n = count
        var size = 1
        while size < n {
            for lo in stride(from: 0, to: n-size, by: size*2) {
                merge(lo: lo, mi: (lo+size), hi: Swift.min(lo+size*2,n))
            }
            size *= 2
        }
    }
}

// 另一种方法是，将 merge 定义为一个内部函数，并让它捕获在外层函数作用域中定义的存储:
extension Array where Element: Comparable {
    mutating func mergeSortInPlace() {
        // 定义所有 merge 操作所使⽤用的临时存储
        var tmp: [Element] = []
        // 并且确保它的⼤⼩足够
        tmp.reserveCapacity(count)
        
        func merge(lo: Int, mi: Int, hi: Int) {
            // 清空存储，但是保留留容量量不不变
            tmp.removeAll(keepingCapacity: true)
            // 和上⾯的代码一样
            var i = lo, j = mi
            while i != mi && j != hi {
                if self[j] < self[i] {
                    tmp.append(self[j])
                    j += 1
                } else {
                    tmp.append(self[i])
                    i+=1
                }
            }
            tmp.append(contentsOf: self[i..<mi])
            tmp.append(contentsOf: self[j..<hi])
            replaceSubrange(lo..<hi, with: tmp)
        }
        
        let n = count
        var size = 1
        while size < n {
            for lo in stride(from: 0, to: n-size, by: size*2) {
                merge(lo: lo, mi: (lo+size), hi: Swift.min(lo+size*2,n))
            }
            size *= 2
        }
    }
}

// 下标
extension Collection {
    subscript(indices indexList: Index...) -> [Element] {
        var result: [Element] = []
        for index in indexList {
            result.append(self[index])
        }
        return result
    }
}
// Array("abcdefghijklmnopqrstuvwxyz")[indices: 7, 4, 11, 11, 14]
// ["h", "e", "l", "l", "o"]


extension Dictionary {
    subscript<Result>(key: Key, as type: Result.Type) -> Result? {
        get {
            return self[key] as? Result
        }
        set {
            guard let value = newValue as? Value else {
                return
            }
            self[key] = value
        }
    }
}
// japan["coordinates", as: [String: Double].self]?["latitude"] = 36.0
// japan["coordinates"] // Optional(["latitude": 36.0, "longitude": 139.0])


// 键路径
struct Address {
    var street: String
    var city: String
    var zipCode: Int
}

struct Person2 {
    let name: String
    var address: Address
}

class AdvanceSwift_Function3 {
    func op() {
        let streetKeyPath = \Person2.address.street // WritableKeyPath<Person, String>
        let nameKeyPath = \Person2.name             // KeyPath<Person, String>
        
        let simpsonResidence = Address(street: "1094 Evergreen Terrace", city: "Springfield", zipCode: 97475)
        var lisa = Person2(name: "Lisa Simpson", address: simpsonResidence)
let _ = lisa[keyPath: nameKeyPath] // Lisa Simpson
        lisa[keyPath: streetKeyPath] = "742 Evergreen Terrace"
        
        // KeyPath<Person, String> + KeyPath<String, Int> = KeyPath<Person, Int>
        let nameCountKeyPath = nameKeyPath.appending(path: \.count)
        // Swift.KeyPath<Person, Swift.Int>
        
        
        // 可写键路径
        let getStreet: (Person2) -> String = { person in
            return person.address.street
        }
        
        let setStreet: (inout Person2, String) -> () = { person, newValue in
            person.address.street = newValue
        }
        
let _ = lisa[keyPath: streetKeyPath] // 742 Evergreen Terrace
let _ = getStreet(lisa)              // 742 Evergreen Terrace
    }
    
    /* 原始方式
    typealias SortDescriptor<Value> = (Value, Value) -> Bool
    func sortDescriptor<Value, Key>(key: @escaping (Value) -> Key) -> SortDescriptor<Value> where Key: Comparable {
        return { key($0) < key($1) }
    }
    let streetSD: SortDescriptor<Person> = sortDescriptor { $0.address.street }
     */
    
    /* KeyPath - 灵活度不够，不能使用忽略大小写的按区域设置的比较
    func sortDescriptor<Value, Key>(key: KeyPath<Value, Key>) -> SortDescriptor<Value> where Key: Comparable {
        return { $0[keyPath: key] < $1[keyPath: key] }
    }
    let streetSDKeyPath: SortDescriptor<Person> = sortDescriptor(key: \.address.street)
     */
}


/// 可写键路径

// <1> 首先，我们对所有 NSObject 的子类定义了这个方法，通过扩展 NSObjectProtocol 而不是 NSObject，我们可以使用 Self。
// <2> ReferenceWritableKeyPath 和 WritableKeyPath 很相似，不过它可以让我们对 (other 这样的) 使用 let 声明的引用变量进行写操作。为了避免不必要的操作，我们只在值发生改变时才对 other 进行写入。
// <3> 返回值 NSKeyValueObservation 是一个 token，调用者使用这个 token 来控制观察的生命周期: 属性观察会在这个 token 对象被销毁或者调用者调用了它的 invalidate 方法时停止。
extension NSObjectProtocol where Self: NSObject {
    func observe<A, Other>(_ keyPath: KeyPath<Self, A>,
                           writeTo other: Other,
                           _ otherKeyPath: ReferenceWritableKeyPath<Other, A>)
                           -> NSKeyValueObservation
                           where A: Equatable, Other: NSObjectProtocol
    {
        return observe(keyPath, options: .new) { _, change in
            guard let newValue = change.newValue,
                other[keyPath: otherKeyPath] != newValue else {
                    return // prevent endless feedback loop
            }
            other[keyPath: otherKeyPath] = newValue
        }
    }
}

extension NSObjectProtocol where Self: NSObject {
    func bind<A, Other>(_ keyPath: ReferenceWritableKeyPath<Self,A>,
                        to other: Other,
                        _ otherKeyPath: ReferenceWritableKeyPath<Other,A>)
                        -> (NSKeyValueObservation, NSKeyValueObservation)
                           where A: Equatable, Other: NSObject
    {
        let one = observe(keyPath, writeTo: other, otherKeyPath)
        let two = other.observe(otherKeyPath, writeTo: self, keyPath)
        return (one, two)
    }
}

final class Sample: NSObject {
    @objc dynamic var name: String = ""
}

class MyObj: NSObject {
    @objc dynamic var test: String = ""
}

class AdvanceSwift_Function4 {
    func op() {
        let sample = Sample()
        let other = MyObj()
        let observation = sample.bind(\Sample.name, to: other, \.test)
        sample.name = "NEW"
let _ = other.test // NEW
        other.test = "HI"
let _ = sample.name // HI
    }
}

extension Array {
    func all(matching predicate: (Element) -> Bool) -> Bool {
        return withoutActuallyEscaping(predicate) { escapablePredicate in
            self.lazy.filter { !escapablePredicate($0) }.isEmpty
        }
    }
}
let areAllEven = [1,2,3,4].all { $0 % 2 == 0 } // false
let areAllOneDigit = [1,2,3,4].all { $0 < 10 } // true


