//
//  AdvanceSwift_String.swift
//  SwiftTips
//
//  Created by cash on 2019/3/12.
//  Copyright © 2019 cash. All rights reserved.
//

import UIKit

class AdvanceSwift_String: NSObject {
    func op() {
        let single = "Pok\u{00E9}mon" // Pokémon
        let double = "Poke\u{0301}mon" // Pokémon
        
let _ = (single, double) // ("Pokémon", "Pokémon")
        
let _ = single.count // 7
let _ = double.count // 7
        
let _ = single == double // true
        
let _ = single.utf16.count // 7
let _ = double.utf16.count // 8
        
        let nssingle = single as NSString
let _ = nssingle.length // 7
        
        let nsdouble = double as NSString
let _ = nsdouble.length // 8
        nssingle == nsdouble // false
        
let _ = single.utf16.elementsEqual(double.utf16) // false
    }
}

extension StringTransform {
    static let toUnicodeName = StringTransform(rawValue: "Any-Name")
}

extension Unicode.Scalar {
    /// 标量的 Unicode 名字，比如 "LATIN CAPITAL LETTER A".
    var unicodeName: String {
        // 强制解包是安全的，因为这个变形不可能失败
        let name = String(self).applyingTransform(.toUnicodeName, reverse: false)!
        // 变形后的字符串以 "\\N{...}" 作为名字开头，将它们去掉。
        let prefixPattern = "\\N{"
        let suffixPattern = "}"
        let prefixLength = name.hasPrefix(prefixPattern) ? prefixPattern.count : 0
        let suffixLength = name.hasSuffix(suffixPattern) ? suffixPattern.count : 0
        return String(name.dropFirst(prefixLength).dropLast(suffixLength))
    }
}

// skinTone.unicodeScalars.map { $0.unicodeName }
// ["GIRL", "EMOJI MODIFIER FITZPATRICK TYPE-4"]


// 双向索引，而非随机访问
extension String {
    var allPrefixes2: [Substring] {
        return [""] + self.indices.map { index in self[...index] }
    }
}
// hello.allPrefixes2  // ["", "H", "He", "Hel", "Hell", "Hello"]



/// 子字符串
let sentence = "The quick brown fox jumped over the lazy dog."

extension String {
    func wrapped(after: Int = 70) -> String {
        var i = 0
        let lines = self.split(omittingEmptySubsequences: false) {
            character in
            switch character {
            case "\n",
                 " " where i >= after:
                i = 0
                return true
            default:
                i += 1
                return false
            }
        }
        return lines.joined(separator: "\n")
    }
}
// sentence.wrapped(after: 15)
/*
 The quick brown
 fox jumped over
 the lazy dog.
 */

extension Collection where Element: Equatable {
    func split<S: Sequence>(separators: S) -> [SubSequence]
        where Element == S.Element
        {
            return split { separators.contains($0)
        }
    }
}
// "Hello, world!".split(separators: ",! ")
// ["Hello", "world"]


class AdvanceSwift_String2: NSObject {
    func enumerateSubstrings() {
        let sentence = """
            The quick brown fox jumped \
            over the lazy dog.
            """
        var words: [String] = []
        sentence.enumerateSubstrings(in: sentence.startIndex..., options: .byWords) { (word, range, _, _) in
            guard let word = word else { return }
            words.append(word)
        }
let _ = words
        // ["The", "quick", "brown", "fox", "jumped", "over", "the", "lazy", "dog"]
    }
    
    func nsRange_effectiveRange() {
        let text = "   Click here for more info."
        let linkTarget =
            URL(string: "https://www.youtube.com/watch?v=DLzxrzFCyOs")!
        
        // 尽管使用了 `let`，对象依然是可变的 (引⽤语义)
        let formatted = NSMutableAttributedString(string: text)
        
        // 修改文本的部分属性
        if let linkRange = formatted.string.range(of: "Click here") {
            // 将 Swift 范围转换为 NSRange
            // 注意范围的起始值为 3，因为⽂文本前⾯面的颜⽂文字⽆无法在单个 UTF-16 编码单元中被表示
            let nsRange = NSRange(linkRange, in: formatted.string) // {3, 10}
            //添加属性
            formatted.addAttribute(.link, value: linkTarget, range: nsRange)
        }
    
        /// effectiveRange
        
        // 查询单词 "here" 开始的属性
        if let queryRange = formatted.string.range(of: "here"),
            // 获取在 UTF-16 视图中的索引
            let utf16Index = String.Index(queryRange.lowerBound,
                                          within: formatted.string.utf16) {
            // 将索引转为 UTF-16 整数偏移量量
            let utf16Offset = utf16Index.encodedOffset
            
            // 准备⽤用来接收受属性影响的范围 (effectiveRange) 的 NSRangePointer
            var attributesRange = UnsafeMutablePointer<NSRange>.allocate(capacity: 1)
            defer {
                attributesRange.deinitialize(count: 1)
                attributesRange.deallocate()
            }
            
            //执⾏查询
            let attributes = formatted.attributes(at: utf16Offset,
                                                  effectiveRange: attributesRange)
let _ =     attributesRange.pointee // {3, 10}
            
            // 将 NSRange 转换回 Range<String.Index>
            if let effectiveRange = Range(attributesRange.pointee, in: formatted.string) {
                // 属性所跨越的⼦字符串
let _ =         formatted.string[effectiveRange] // Click here
            }
            
            let code = "struct Array<Element>: Collection { }"
let _ =     code.words() // ["struct", "Array", "Element", "Collection"]
        }
    }
}

// 好消息是，即使经过了这样相对较多的管道，words 中的字符串切片依然只是原字符串的视图
// 所以它还是会比 components(separatedBy:) 高效得多 (这个方法将返回一个字符串数组，所以需要进行复制)。
extension String {
    func words(with charset: CharacterSet = .alphanumerics) -> [Substring] {
        return self.unicodeScalars.split {
            !charset.contains($0)
        }.map(Substring.init)
    }
}

/// 简单的正则表达式匹配器

/// 简单的正则表达式类型，支持 ^ 和 $ 锚点,
///并且匹配 . 和 *
public struct Regex {
    private let regexp: String
    
    /// 从⼀个正则表达式字符串构建进行
    public init(_ regexp: String) {
        self.regexp = regexp
    }
}

extension Regex {
    /// 当字符串参数匹配表达式是返回 true
    public func match(_ text: String) -> Bool {
        
        // 如果表达式以 ^ 开头，那么它只从头开始匹配输⼊
        if regexp.first == "^" {
            return Regex.matchHere(regexp: regexp.dropFirst(), text: text[...])
        }
        
        // 否则，在输⼊入的每个部分进行搜索，直到发现匹配
        var idx = text.startIndex
        while true {
            if Regex.matchHere(regexp: regexp[...],
                               text: text.suffix(from: idx))
            {
                return true
            }
            guard idx != text.endIndex else { break }
            text.formIndex(after: &idx)
        }
        return false
    }
}

extension Regex {
    /// 从⽂本开头开始匹配正则表达式
    public static func matchHere(regexp: Substring, text: Substring) -> Bool {
        //空的正则表达式可以匹配所有
        if regexp.isEmpty {
            return true
        }
        
        // 所有跟在 * 后面的字符都需要调⽤ matchStar
        if let c = regexp.first, regexp.dropFirst().first == "*" {
            return matchStar(character: c, regexp: regexp.dropFirst(2), text: text)
        }
        
        // 如果已经是正则表达式的最后一个字符，⽽且这个字符是 $，
        // 那么当且仅当剩余字符串的空时才匹配
        if regexp.first == "$" && regexp.dropFirst().isEmpty {
            return text.isEmpty
        }
        
        // 如果当前字符匹配了，那么从输⼊字符串和正则表达式中将其丢弃，
        // 然后继续进⾏接下来的匹配
        if let tc = text.first, let rc = regexp.first, rc == "." || tc == rc {
            return matchHere(regexp: regexp.dropFirst(), text: text.dropFirst())
        }
        
        // 如果上⾯都不成立，就意味着没有匹配
        return false
    }
    
    /// 在⽂本开头查找零个或多个 `c` 字符，
    /// 接下来是正则表达式的剩余部分
    private static func matchStar
        (character c: Character, regexp: Substring, text: Substring) -> Bool
    {
        var idx = text.startIndex
        while true { // a * matches zero or more instances
            if matchHere(regexp: regexp, text: text.suffix(from: idx)) {
                return true
            }
            if idx == text.endIndex || (text[idx] != c && c != ".") {
                return false
            }
            text.formIndex(after: &idx)
        }
    }
}
// Regex("^h..lo*!$").match("hellooooo!") // true

extension Regex: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        regexp = value
    }
}
// let r: Regex = "^h..lo*!$"

class AdvanceSwift_String3: NSObject {
    func findMatches(in strings: [String], regex: Regex) -> [String] {
        return strings.filter { regex.match($0) }
    }
    
    func op() {
let _ = findMatches(in: ["foo","bar","baz"], regex: "^b..") // ["bar", "baz"]
    }
}

extension Regex: CustomStringConvertible {
    public var description: String {
        return "/\(regexp)/"
    }
}

// String(reflecting:)
extension Regex: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "{expression: \(regexp)}"
    }
}


/// 文本输出流
struct ArrayStream: TextOutputStream {
    var buffer: [String] = []
    mutating func write(_ string: String) {
        buffer.append(string)
    }
}

extension Data: TextOutputStream {
    mutating public func write(_ string: String) {
        self.append(contentsOf: string.utf8)
    }
}

class AdvanceSwift_String4 {
    func op() {
        var stream = ArrayStream()
        print("Hello", to: &stream)
        print("World", to: &stream)
let _ = stream.buffer // ["", "Hello", "\n", "", "World", "\n"]
        
        var utf8Data = Data()
        let string = "café"
let _ = utf8Data.write(string) // ()
    }
}


/// 幻影 (phantom) 类型

protocol StringViewSelector {
    associatedtype View: Collection
    
    static var caret: View.Element { get }
    static var asterisk: View.Element { get }
    static var period: View.Element { get }
    static var dollar: View.Element { get }
    
    static func view(from s: String) -> View
}

struct UTF8ViewSelector: StringViewSelector {
    static var caret: UInt8 { return UInt8(ascii: "^") }
    static var asterisk: UInt8 { return UInt8(ascii: "*") }
    static var period: UInt8 { return UInt8(ascii: ".") }
    static var dollar: UInt8 { return UInt8(ascii: "$") }
    
    static func view(from s: String) -> String.UTF8View { return s.utf8 }
}

struct CharacterViewSelector: StringViewSelector {
    static var caret: Character { return "^" }
    static var asterisk: Character { return "*" }
    static var period: Character { return "." }
    static var dollar: Character { return "$" }
    
    static func view(from s: String) -> String { return s }
}

struct Regex2<V: StringViewSelector>
    where V.View.Element: Equatable,
    V.View.SubSequence: Collection
{
    let regexp: String
    /// 从正则表达式字符串串中构建
    init(_ regexp: String) {
        self.regexp = regexp
    }
}

extension Regex2 {
    /// 当表达式匹配字符串串时返回 true
    func match(_ text: String) -> Bool {
        let text = V.view(from: text)
        let regexp = V.view(from: self.regexp)
        
        // 如果正则以 ^ 开头，它只从开头进⾏匹配
        if regexp.first == V.caret {
            return Regex2.matchHere(regexp: regexp.dropFirst(), text: text[...])
        }
        
        // 否则，在输⼊内逐位搜索匹配，直到找到匹配内容
        var idx = text.startIndex
        while true {
            if Regex2.matchHere(regexp: regexp[...], text: text.suffix(from: idx)) {
                return true
            }
            guard idx != text.endIndex else { break }
            text.formIndex(after: &idx)
        }
        return false
    }

    /// 从⽂本开头匹配正则表达式字符串
    private static func matchHere(
        regexp: V.View.SubSequence, text: V.View.SubSequence) -> Bool
    {
        // ...
        return false
    }
    // ...
}

func benchmark<V: StringViewSelector>(_: V.Type, pattern: String, text: String)
    -> TimeInterval
    where V.View.Element: Equatable, V.View.SubSequence: Collection
{
    let r = Regex2<V>(pattern)
    let lines = text.split(separator: "\n").map(String.init)
    var count = 0
    
    let startTime = CFAbsoluteTimeGetCurrent()
    for line in lines {
        if r.match(line) { count = count &+ 1 }
    }
    let totalTime = CFAbsoluteTimeGetCurrent() - startTime
    return totalTime
}
/*
let timeCharacter = benchmark(CharacterViewSelector.self, pattern: pattern, text: input)
let timeUnicodeScalar = benchmark(UnicodeScalarViewSelector.self, pattern: pattern, text: input)
let timeUTF16 = benchmark(UTF8ViewSelector.self, pattern: pattern, text: input)
let timeUTF8 = benchmark(UTF16ViewSelector.self, let pattern: pattern, text: input)
*/
