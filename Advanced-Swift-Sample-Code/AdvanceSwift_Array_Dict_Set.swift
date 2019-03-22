//
//  AdvanceSwiftViewController.swift
//  SwiftTips
//
//  Created by cash on 04/07/2018.
//  Copyright © 2018 cash. All rights reserved.
//

import UIKit

/// 数组
//  数组和可选值
//      → 想要迭代数组?                        for x in array
//      → 想要迭代除了第一个元素以外的数组其余部分? for x in array.dropFirst()
//      → 想要迭代除了最后5个元素以外的数组?       for x in array.dropLast(5)
//      → 想要列举数组中的元素和对应的下标?        for (num, element) in collection.enumerated()
//      → 想要寻找一个指定元素的位置?            if let idx = array.index { someMatchingLogic($0) }
//      → 想要对数组中的所有元素进行变形?         array.map { someTransformation($0) }
//      → 想要筛选出符合某个标准的元素?           array.flter{ someCriteria($0)> }

// 使用函数将行为参数化
//      → map 和 fatMap — 如何对元素进行变换
//      → filter — 元素是否应该被包含在结果中
//      → reduce — 如何将元素合并到一个总和的值中
//      → sequence — 序列中下一个元素应该是什么?
//      → forEach — 对于一个元素，应该执行怎样的操作

//      → sort，lexicographicCompare 和 partition — 两个元素应该以怎样的顺序进行排列
//      → index， first和 contains — 元素是否符合某个条件
//      → min 和 max — 两个元素中的最小/最大值是哪个
//      → elementsEqual 和 starts — 两个元素是否相等
//      → split — 这个元素是否是一个分割符

//      → prefix - 当判断为真的时候，将元素滤出到结果中。一旦不为真，就将剩余的抛弃。和  flter 类似，但是会提前退出。这个函数在处理无限序列或者是延迟计算 (lazily-computed) 的序列时会非常有用。
//      → drop - 当判断为真的时候，丢弃元素。一旦不为真，返回将其余的元素。和 pre x(while:) 类似，不过返回相反的集合。

//  不存在于标准库中
//      → accumulate — 累加，和 reduce 类似，不过是将所有元素合并到一个数组中，并保留合并时每一步的值。
//      → all(matching:) 和 none(matching:) — 测试序列中是不是所有元素都满足某个标准，以及是不是没有任何元素满足某个标准。它们可以通过 contains 和它进行了精心对应的否定形式来构建。
//      → count(where:) — 计算满足条件的元素的个数，和 filter 相似，但是不会构建数组。
//      → indices(where:) — 返回一个包含满足某个标准的所有元素的索引的列表，和 index(where:) 类似，但是不会在遇到首个元素时就停止。
//      -> contains(where:)


// https://github.com/apple/swift/blob/swift-4.0-branch/stdlib/public/core/Sequence.swift
// Element 是数组中包含的元素类型的占位符，T 是元素转换之后的类型的占位符。
extension Array {
    func map<T>(_ transform: (Element) -> T) -> [T] {
        var result: [T] = []
        result.reserveCapacity(count)
        for x in self {
            result.append(transform(x))
        }
        return result
    }
}

// filter
extension Array {
    func filter(_ isIncluded: (Element) -> Bool) -> [Element] {
        var result: [Element] = []
        for x in self where isIncluded(x) {
            result.append(x)
        }
        return result
    }
}

// reduce
extension Array {
    func reduce<Result>(_ initialResult: Result,
                        _ nextPartialResult: (Result, Element) -> Result) -> Result {
        var result = initialResult
        for x in self {
            result = nextPartialResult(result, x)
        }
        return result
    }
}

// 只使用 reduce 就能实现 map 和 filter: 时间复杂度 O(n2)
extension Array {
    func map2<T>(_ transform: (Element) -> T) -> [T] {
        return reduce([]) {
            $0 + [transform($1)]
        }
    }
    
    func filter2(_ isIncluded: (Element) -> Bool) -> [Element] {
        return reduce([]) {
            isIncluded($1) ? $0 + [$1] : $0
        }
    }
}

// 重写 filter
extension Array {
    //    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (_ partialResult: inout Result, Element) throws -> () ) rethrows -> Result
//    时间复杂度 O(n)。
    func filter3(_ isIncluded: (Element) -> Bool) -> [Element] {
        return reduce(into: []) { result, element in
            if isIncluded(element) {
                result.append(element)
            }
        }
    }
}

// ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

// flatMap
extension Array {
    func flatMap<T>(_ transform: (Element) -> [T]) -> [T] {
        var result: [T] = []
        for x in self {
            result.append(contentsOf: transform(x))
        }
        return result
    }
    
    // `flatMap` 的另一个常⻅使用情景是将`不同数组里的元素进行合并`
    func combine() {
        let suits = ["♠", "♥", "♣", "♦"]
        let ranks = ["J","Q","K","A"]
        let result = suits.flatMap { suit in
            ranks.map { rank in
                (suit, rank)
            }
        }
        let _ = result
    }
}

// ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

// forEach - 如果你想要对集合中的每个元素都调用一个函数的话，使用 forEach 会比较合适。
// theViews.forEach(view.addSubview)
extension Array where Element: Equatable {
    func index(of element: Element) -> Int? {
        for idx in self.indices where self[idx] == element {
            return idx
        }
        return nil
    }
}

// 错误
// 在 forEach 中的 return 并不能返回到外部函数的作用域之外，它仅仅只是返回到闭包本身之外，
extension Array where Element: Equatable {
    func index_foreach(of element: Element) -> Int? {
        self.indices.filter { idx in
            self[idx] == element
        }.forEach { idx in
            return idx
        }
        return nil
    }
}

// ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

// ArraySlice
//{
//    let slice = fibs[1...]
//    slice                     // [1, 1, 2, 3, 5]
//    type(of: slice)           // ArraySlice<Int>

//    let newArray = Array(slice)
//    type(of: newArray)        // Array<Int>
//}

// accumulate
// note: 这段代码假设了变形函数是以序列原有的顺序执行的。
extension Array {
    func accumulate<Result>(_ initialResult: Result,
                            _ nextPartialResult: (Result, Element) -> Result) -> [Result] {
        var running = initialResult
        return map { next in
            running = nextPartialResult(running, next)
            return running
        }
    }
}

// 翻转匹配
extension Sequence {
    func last(where predicate: (Element) -> Bool) -> Element? {
        for element in reversed() where predicate(element) {
            return element
        }
        return nil
    }
}

// 匹配
extension Sequence {
    public func all(matching predicate: (Element) -> Bool) -> Bool {
        // 对于一个条件，如果没有元素不满足它的话，那意味着所有元素都满足它:
        return !contains { !predicate($0) }
    }
}

// ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

/// 字典
// 有用的字典方法

// merge
/*
    var settings = defaultSettings
    let overriddenSettings: [String:Setting] = ["Name": .text("Jane's iPhone")]
    settings.merge(overriddenSettings, uniquingKeysWith: { $1 })
    settings
 */
// ["Name": Setting.text("Jane\'s iPhone"), "Airplane Mode": Setting.bool(false)]


// mapValues
/*
    let settingsAsStrings = settings.mapValues { setting -> String in
        switch setting {
        case .text(let text): return text
        case .int(let number): return String(number)
        case .bool(let value): return String(value)
        }
    }
    settingsAsStrings // ["Name": "Jane\'s iPhone", "Airplane Mode": "false"]
 */

// 计算序列中某个元素出现的次数，我们可以对每个元素进行映射，将它们和 1 对应起来，然后从 (元素，次数) 的键值对序列中创建字典。
// 如果遇到相同键下的两个值 (同样地元素若干次) 将次数用 + 累加起来。
extension Sequence where Element: Hashable {
    var frequencies: [Element:Int] {
        let frequencyPairs = self.map { ($0, 1) }
        return Dictionary(frequencyPairs, uniquingKeysWith: +)
    }
}
// let frequencies = "hello".frequencies // ["e": 1, "o": 1, "l": 2, "h": 1]
// frequencies.filter { $0.value > 1 } // ["l": 2]

// ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

/// Set

// IndexSet
func IndexSetGlobal() {
    do {
        var indicess = IndexSet()
        indicess.insert(integersIn: 1..<5)
        indicess.insert(integersIn: 11..<15)
        let evenIndices = indicess.filter { $0 % 2 == 0 } // [2, 4, 12, 14]
        let _ = evenIndices
    }
}

// CharacterSet
// 获取序列中所有的唯一元素，用 Set，并返回与输入顺序一致
extension Sequence where Element: Hashable {
    func unique() -> [Element] {
        var seen: Set<Element> = []
        return filter { element in
            if seen.contains(element) {
                return false
            } else {
                seen.insert(element)
                return true
            }
        }
    }
}
/*
 [1,2,3,12,1,3,4,5,6,4,6].unique() // [1, 2, 3, 12, 4, 5, 6]
 */

// ===== ===== ===== ===== ===== ===== ===== ===== ===== =====

/// Range

// PartialRange

let fromA   : PartialRangeFrom<Character> = Character("a")...
let throughZ: PartialRangeThrough<Character> = ...Character("z")
let upto10  : PartialRangeUpTo<Int> = ..<10
let fromFive: CountablePartialRangeFrom<Int> = 5...  // can travel
// 如果你在一个 for 循环中使用这种范围，你必须牢记要为循环添加一个 break 的退出条件，否则循环将无限进行下去 (或者当计数溢出的时候发生崩溃)。


// RangeExpression
/*
    public protocol RangeExpression {
        associatedtype Bound: Comparable
        func contains(_ element: Bound) -> Bool
        func relative<C: _Indexable>(to collection: C) -> Range<Bound>
        where C.Index == Bound
    }
 */
/*
 let arr = [1,2,3,4]
 arr[2...]  // [3, 4]
 arr[..<1]  // [1]
 arr[1...2] // [2, 3]
 */
/*
 arr[...]      // [1, 2, 3, 4]
 type(of: arr) // Array<Int>
 */












