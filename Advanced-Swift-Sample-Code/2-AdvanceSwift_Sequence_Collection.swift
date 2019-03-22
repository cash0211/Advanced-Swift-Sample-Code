//
//  AdvanceSwift_Collection_Sequence.swift
//  SwiftTips
//
//  Created by cash on 09/07/2018.
//  Copyright © 2018 cash. All rights reserved.
//

import UIKit

class AdvanceSwift_Collection_Sequence: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func linkList() {
        let emptyList = List<Int>.end
        let oneElementList = List.node(1, next: emptyList)
        // node(1, next: List<Swift.Int>.end)
    }
}

///  一个简单的链表枚举
enum List<Element> {
    case end
    indirect case node(Element, next: List<Element>)
}
// 在这里使用 indirect 关键字可以告诉编译器这个枚举值 node 应该被看做引用。


extension List {
    /// 在链表前方添加一个值为 `x` 的节点，并返回这个链表
    func cons(_ x: Element) -> List {
        return .node(x, next: self)
    }
}
// 一个拥有 3 个元素的链表 (3 2 1)
let list = List<Int>.end.cons(1).cons(2).cons(3)
/*
 node(3, next: List<Swift.Int>.node(2, next: List<Swift.Int>.node(1, next: List<Swift.Int>.end))) */


extension List: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self = elements.reversed().reduce(.end) { partialList, element in
            partialList.cons(element)
        }
    }
}
let list2: List = [3,2,1]
/*
 node(3, next: List<Swift.Int>.node(2, next: List<Swift.Int>.node(1, next: List<Swift.Int>.end))) */


extension List {
    mutating func push(_ x: Element) {
        self = self.cons(x)
    }
    
    mutating func pop() -> Element? {
        switch self {
        case .end: return nil
        case let .node(x, next: tail):
            self = tail
            return x
        }
    }
}

// 这正是结构体上的可变方法所做的事情，它们其实接受一个隐式的 inout 的 self 作为参数，这样它们就能够改变 self 所持有的值了。
class ListOperation: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func list() {
        var stack: List<Int> = [3,2,1]
        var a = stack
        var b = stack
        
        let _ = a.pop() // Optional(3)
        let _ = a.pop() // Optional(2)
        let _ = a.pop() // Optional(1)
        
        let _ = stack.pop() // Optional(3)
        stack.push(4)
        
        let _ = b.pop() // Optional(3)
        let _ = b.pop() // Optional(2)
        let _ = b.pop() // Optional(1)
        
        let _ = stack.pop() // Optional(4)
        let _ = stack.pop() // Optional(2)
        let _ = stack.pop() // Optional(1)
    }
    
    func someMethod() {
        let list: List = ["1", "2", "3"]
        for x in list{
            print("\(x) ", terminator: "")
        } // 1 2 3
        let _ = list.joined(separator: ",")         // 1,2,3
        let _ = list.contains("2")                  // true
        let _ = list.flatMap { Int($0) }            // [1, 2, 3]
        let _ = list.elementsEqual(["1", "2", "3"]) // true
    }
}
// 事实上，你可以单纯地将迭代器声明为满足 Sequence 来将它转换为一个序列，因为 Sequence 提供了一个默认的 makeIterator 实现，对于那些满足协议的迭代器类型，这个方法将返回 self 本身。
extension List: IteratorProtocol, Sequence {
    mutating func next() -> Element? {
        return pop()
    }
}

// ****************************************************************** //

// 集合类型

// 队列
/// 一个能够将元素入队和出队的类型
protocol Queue {
    /// 在 `self` 中所持有的元素的类型
    associatedtype Element
    /// 将 `newElement` 入队到 `self`
    mutating func enqueue(_ newElement: Element)
    /// 从 `self` 出队一个元素
    mutating func dequeue() -> Element?
}

/// 一个高效的 FIFO 队列，其中元素类型为 `Element`
struct FIFOQueue<Element>: Queue {
    private var left: [Element] = []
    private var right: [Element] = []
    
    /// 将元素添加到队列最后
    /// - 复杂度: O(1)
    mutating func enqueue(_ newElement: Element) {
        right.append(newElement)
    }
    
    /// 从队列前端移除一个元素
    /// 当队列为空时，返回 nil
    /// - 复杂度: 平摊 O(1)    /// 这里有个关于时间复杂度的分析
    mutating func dequeue() -> Element? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
}

// ***************************** Collection 介绍 ************************************* //

/*
protocol Collection: Sequence {
    associatedtype Element // inherited from Sequence
    associatedtype Index: Comparable
    
    associatedtype IndexDistance: SignedInteger = Int
//    associatedtype Iterator: IteratorProtocol = IndexingIterator<Self>
//        where Iterator.Element == Element
    
//    associatedtype SubSequence: Sequence
//        where Element == SubSequence.Element,
//            SubSequence == SubSequence.SubSequence
    /* ... */
//    associatedtype Indices: Sequence = DefaultIndices<Self>
//        where Index == Indices.Element,
//            Indices == Indices.SubSequence,
//            Indices.Element == Indices.Index,
//            Indices.Index == SubSequence.Index
    /* ... */
    
    var first: Element? { get }
//    var indices: Indices { get }
    var isEmpty: Bool { get }
    var count: IndexDistance { get }
    
    func makeIterator() -> Iterator
    func prefix(through: Index) -> SubSequence
    func prefix(upTo: Index) -> SubSequence
    func suffix(from: Index) -> SubSequence
    func distance(from: Index, to: Index) -> IndexDistance
    func index(_: Index, offsetBy: IndexDistance) -> Index
    func index(_: Index, offsetBy: IndexDistance, limitedBy: Index) -> Index?
    
    subscript(position: Index) -> Element { get }
    subscript(bounds: Range<Index>) -> SubSequence { get }
}
 */

/*
// Collection 的协议扩展为我们提供了默认的实现
extension Collection where Iterator == IndexingIterator<Self> {
    /// 返回一个基于集合元素的迭代
    func makeIterator() -> IndexingIterator<Self>
}
 */



// ***************************** Sequence conformance ********************************** //

protocol Collectionz: Sequence {
    /// 一个表示集合中位置的类型
    associatedtype Index: Comparable
    /// 一个非空集合中首个元素的位置
    var startIndex: Index { get }
    /// 集合中超过末位的位置---也就是比最后一个有效下标值大 1 的位置
    var endIndex: Index { get }
    /// 返回在给定索引之后的那个索引值
    func index(after i: Index) -> Index
    /// 访问特定位置的元素
    subscript(position: Index) -> Element { get }
}

extension FIFOQueue: Collectionz {
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return left.count + right.count }
    
    public func index(after i: Int) -> Int {
        precondition(i < endIndex)
        return i + 1
    }
    
    public subscript(position: Int) -> Element {
        get {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                return left[left.count - position - 1]
            } else {
                return right[position - left.count]
            }
        }
        set {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                left[left.count - position - 1] = newValue
            } else {
                return right[position - left.count] = newValue
            }
        }
    }
}

class queueOperation: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func queue() {
        var q = FIFOQueue<String>()
        for x in ["1", "2", "foo", "3"] {
            q.enqueue(x)
        }
        
        for sin in q {
            print(sin, terminator: " ")
        } // 1 2 foo 3
        
        var a = Array(q) // ["1", "2", "foo", "3"]
        a.append(contentsOf: q[2...3])
//      a // ["1", "2", "foo", "3", "foo", "3"]
        
let _ = q.map { $0.uppercased() } // ["1", "2", "FOO", "3"]
let _ = q.flatMap { Int($0) }     // [1, 2, 3]
let _ = q.filter { $0.count > 1 } // ["foo"]
        
let _ = q.sorted() // ["1", "2", "3", "foo"]
let _ = q.joined(separator: " ") // 1 2 foo 3
        
let _ = q.isEmpty // false
let _ = q.count   // 4
let _ = q.first   // Optional("1")
    }
}

// ***************************** ExpressibleByArrayLiteral ********************************** //

extension FIFOQueue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        left = elements.reversed()
        right = []
    }
}

class queueExpressible: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func expressible() {
        let queue: FIFOQueue = [1,2,3]  // FIFOQueue<Int>(left: [3, 2, 1], right: [])
        let _ = queue
    }
}


// ***************************** 集合类型中的默认迭代器类型 ********************************** //

/*  不过编译器 还不允许循环关联类型约束
public struct IndexingIterator<Elements: _IndexableBase> : IteratorProtocol, Sequence
{
    internal let _elements: Elements
    internal var _position: Elements.Index
    
    init(_elements: Elements) {
        self._elements = _elements
        self._position = _elements.startIndex
    }
    
    public mutating func next() -> Elements.Element? {
        if _position == _elements.endIndex { return nil }
        let element = _elements[_position]
        _elements.formIndex(after: &_position)
        return element
    }
}
*/

/*
 extension FIFOQueue: Collection {
    ...
    typealias Indices = CountableRange<Int>
    var indices: CountableRange<Int> {
        return startIndex..<endIndex
    }
 }
 */

// ***************************** 自定义集合索引 ********************************** //

extension Substring {
    var nextWordRange: Range<Index> {
        let start = drop(while: { $0 == " "})
        let end = start.index(where: { $0 == " "}) ?? endIndex
        return start.startIndex..<end
    }
}

struct WordsIndex: Comparable {
    fileprivate let range: Range<Substring.Index>
    fileprivate init(_ value: Range<Substring.Index>) {
        self.range = value
    }
    
    static func <(lhs: Words.Index, rhs: Words.Index) -> Bool {
        return lhs.range.lowerBound < rhs.range.lowerBound
    }
    
    static func ==(lhs: Words.Index, rhs: Words.Index) -> Bool {
        return lhs.range == rhs.range
    }
}

struct Words: Collection {
    let string: Substring
    let startIndex: WordsIndex
    
    init(_ s: String) {
        self.init(s[...])
    }
    
    private init(_ s: Substring) {
        self.string = s
        self.startIndex = WordsIndex(string.nextWordRange)
    }
    
    var endIndex: WordsIndex {
        let e = string.endIndex
        return WordsIndex(e..<e)
    }
}

extension Words {
    subscript(index: WordsIndex) -> Substring {
        return string[index.range]
    }
}

extension Words {
    func index(after i: WordsIndex) -> WordsIndex {
        guard i.range.upperBound < string.endIndex
            else { return endIndex }
        let remainder = string[i.range.upperBound...]
        return WordsIndex(remainder.nextWordRange)
    }
}

//  Array(Words(" hello world test ").prefix(2)) // ["hello", "world"]



// ***************************** Slices ******************************* //

/*
let words: Words = Words("one two three")
let onePastStart = words.index(after: words.startIndex)
let firstDropped = words[onePastStart..<words.endIndex]
Array(firstDropped) // ["two", "three"]

let firstDropped2 = words.suffix(from: onePastStart)
// 或者
let firstDropped3 = words[onePastStart...]
 */

// Slices
// Slice 是基于任意集合类型的一个轻量级封装
struct Slice<Base: Collection>: Collection {
    typealias Index = Base.Index
    typealias IndexDistance = Base.IndexDistance
    typealias SubSequence = Slice<Base>
    
    let collection: Base
    
    var startIndex: Index
    var endIndex: Index
    
    init(base: Base, bounds: Range<Index>) {
        collection = base
        startIndex = bounds.lowerBound
        endIndex = bounds.upperBound
    }
    
    func index(after i: Index) -> Index {
        return collection.index(after: i)
    }
    
    subscript(position: Index) -> Base.Element {
        return collection[position]
    }
    
    subscript(bounds: Range<Base.Index>) -> Slice<Base> {
        return Slice(base: collection, bounds: bounds)
    }
}

extension Words {
    subscript(range: Range<WordsIndex>) -> Words {
        let start = range.lowerBound.range.lowerBound
        let end = range.upperBound.range.upperBound
        return Words(string[start..<end])
    }
}


// ***************************** 切片与原集合共享索引 ******************************* //
class ss {
    let s = {
        let cities = ["New York", "Rio", "London", "Berlin", "Rome", "Beijing", "Tokyo", "Sydney"]
        let slice = cities[2...4]
        _ = cities.startIndex // 0
        _ = cities.endIndex // 8
        _ = slice.startIndex // 2
        _ = slice.endIndex // 5
    }
}

// ***************************** 泛型 PrefixIterator  ******************************* //

struct PrefixIterator<Base: Collection>: IteratorProtocol, Sequence {
    let base: Base
    var offset: Base.Index
    
    init(_ base: Base) {
        self.base = base
        self.offset = base.startIndex
    }
    
    mutating func next() -> Base.SubSequence? {
        guard offset != base.endIndex else { return nil }
        base.formIndex(after: &offset)
        return base.prefix(upTo: offset)
    }
}

class PrefixIteratorClass  {
    func test() {
        let numbers = [1,2,3]
let _ = Array(PrefixIterator(numbers))
        // [ArraySlice([1]), ArraySlice([1, 2]), ArraySlice([1, 2, 3])]
    }
}

// ***************************** 专门的集合类型 ******************************* //

// BidirectionalCollection

extension BidirectionalCollection {
    /// 集合中的最后⼀个元素。
    public var last: Element? {
        return isEmpty ? nil : self[index(before: endIndex)]
    }
}

// 这里的 reversed 方法不会直接将集合反转，而是返回一个延时加载的表示方式:
// ReverseCollection 会持有原来的集合，并且使用逆向的索引。
extension BidirectionalCollection {
    /// 返回集合中元素的逆序表示⽅方式似乎数组
    /// - 复杂度: O(1)
    /*
    public func reversed() -> ReversedCollection<Self> {
        return ReversedCollection(self)
    }
     */
}

// RandomAccessCollection

// MutableCollection
/*
extension FIFOQueue: MutableCollection {
    typealias Index = Int
    public var xxStartIndex: Int { return 0 }
    public var xxEndIndex: Int { return left.count + right.count }
    
    public func xxIndex(after i: Int) -> Int {
        return i + 1
    }
    
    
    public subscript(position: Int) -> Element {
        get {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                return left[left.count - position - 1]
            } else {
                return right[position - left.count]
            }
        }
        set {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                left[left.count - position - 1] = newValue
            } else {
                return right[position - left.count] = newValue
            }
        }
    }
}
 */

class MutableCollectionx : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var playlist: FIFOQueue = ["Shake It Off", "Blank Space", "Style"]
let _ = playlist.first // Optional("Shake It Off")
        playlist[0] = "You Belong With Me"
let _ = playlist.first // Optional("You Belong With Me")
    }
}

// RangeReplaceableCollection
extension FIFOQueue: RangeReplaceableCollection {
    mutating func replaceSubrange<C: Collection>(_ subrange: Range<Int>,
                                                 with newElements: C) where C.Element == Element {
        right = left.reversed() + right
        left.removeAll()
        right.replaceSubrange(subrange, with: newElements)
    }
}

// 现在标准库中有十二种不同类型的集合，它们是三种遍历方式 (前向，双向和随机存取) 以及四种变更方式 (不变，可变，范围可替换，可变且范围可替换) 的组合。
/*
extension MutableCollection
    where Self: RandomAccessCollection, Element: Comparable {
    /// 原地对集合进行排序
    public mutating func sort() { ... }
}
 */


extension FIFOQueue: TextOutputStreamable {
    func write<Target: TextOutputStream>(to target: inout Target) {
        target.write("[")
        target.write(map { String(describing: $0) }.joined(separator: ","))
        target.write("]")
    }
}
/*
var textRepresentation = ""
let queue: FIFOQueue = [1,2,3]
queue.write(to: &textRepresentation)
textRepresentation // [1,2,3]
 */









