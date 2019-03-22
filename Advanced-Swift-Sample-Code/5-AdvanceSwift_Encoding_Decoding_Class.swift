//
//  AdvanceSwift_Encoding&Decoding_Class.swift
//  SwiftTips
//
//  Created by cash on 2019/3/7.
//  Copyright © 2019 cash. All rights reserved.
//

import UIKit

struct Coordinate: Codable {
    var latitude: Double
    var longitude: Double
    //不需要实现
}

struct Placemark: Codable {
    var name: String
    var coordinate: Coordinate
}

class AdvanceSwift_Encoding_Decoding_Class {
    func op() {
        var jsonData: Data = Data()
        
        let places = [
            Placemark(name: "Berlin", coordinate: Coordinate(latitude: 52, longitude: 13)),
            Placemark(name: "Cape Town", coordinate: Coordinate(latitude: -34, longitude: 18))]
        do {
            let encoder = JSONEncoder()
                jsonData = try encoder.encode(places) // 129 bytes
            let jsonString = String(decoding: jsonData, as: UTF8.self)
            /*
             [{"name":"Berlin","coordinate":{"longitude":13,"latitude":52}},
             {"name":"Cape Town","coordinate":{"longitude":18,"latitude":-34}}]
             */
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(Placemark.self, from: jsonData)
            // [Berlin (lat: 52.0, lon: 13.0), Cape Town (lat: -34.0, lon: 18.0)]
let _ =     type(of: decoded) // Array<Placemark>
//          decoded == places // true
        } catch {
            print(error.localizedDescription)
        }
    }
}

/// 能将值编码为外部表示的原⽣生格式的类型。
public protocol _Encoder {
    /// 编码过程中到当前点的编码键路路径。
    var codingPath: [CodingKey] { get }
    /// ⽤用户为编码设置的上下⽂文信息。
    var userInfo: [CodingUserInfoKey : Any] { get }
    /// 返回⼀一个合适⽤用来存放以`给定键类型`为键的多个值的编码容器器。
    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key>
    /// 返回⼀一个合适⽤用来存放多个⽆无键值的编码容器器。
    func unkeyedContainer() -> UnkeyedEncodingContainer
    /// 返回⼀一个合适⽤用来存放⼀一个原始值的编码容器器。
    func singleValueContainer() -> SingleValueEncodingContainer
}

/// 可以⽀持存储和直接编码⼀个单⼀无键值的容器。
public protocol SingleValueEncodingContainer {
    /// 编码过程中到当前点的编码键路径。
    var codingPath: [CodingKey] { get }
    
    /// 对 null 编码。
    mutating func encodeNil() throws
    
    /// 基础类型
    mutating func encode(_ value: Bool) throws
    mutating func encode(_ value: Int) throws
    mutating func encode(_ value: Int8) throws
    mutating func encode(_ value: Int16) throws
    mutating func encode(_ value: Int32) throws
    mutating func encode(_ value: Int64) throws
    mutating func encode(_ value: UInt) throws
    mutating func encode(_ value: UInt8) throws
    mutating func encode(_ value: UInt16) throws
    mutating func encode(_ value: UInt32) throws
    mutating func encode(_ value: UInt64) throws
    mutating func encode(_ value: Float) throws
    mutating func encode(_ value: Double) throws
    mutating func encode(_ value: String) throws
    
    mutating func encode<T: Encodable>(_ value: T) throws
}

extension Array: Encodable where Element: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in self {
            try container.encode(element)
        }
    }
}

// 编译器生成的代码
struct Placemark2 {
    // ...
    private enum CodingKeys: CodingKey {
        case name
        case coordinate
    }
}

/// 该类型作为编码和解码时使⽤用的键
public protocol CodingKey2 {
    /// 在⼀个命名集合 (⽐如一个字符串串作为键的字典) 中的字符串值。
    var stringValue: String { get }
    /// 在⼀个整数索引集合 (⽐如⼀个整数作为键的字典) 中使⽤的值。
    var intValue: Int? { get }
    init?(stringValue: String)
    init?(intValue: Int)
}

// encode(to:) 方法
struct Placemark3: Codable {
    var name = ""
    var coordinate = ""
    
    // ...
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(coordinate, forKey: .coordinate)
    }
}

// init(from:) 初始化方法
struct _Placemark: Codable {
    // ...
    /*
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        coordinate = try container.decode(Coordinate.self, forKey: .coordinate)
    }
     */
}

// 自定义 Coding Keys
struct _Placemark3: Codable {
    var name: String
    var coordinate: Coordinate
    
    private enum CodingKeys: String, CodingKey {
        case name = "label"
        case coordinate
    }
    // 编译器器⽣成的编码和解码⽅法将使用重载后的 CodingKeys
}

struct Placemark4: Codable {
    var name: String = "(Unknown)" // 默认值
    var coordinate: Coordinate
    
    private enum CodingKeys: CodingKey {
        case coordinate
    }
}


// 自定义的 encode(to:) 和 init(from:) 实现
/*
struct Placemark5: Codable {
    var name: String
    var coordinate: Coordinate?

    // encode(to:) 依然由编译器器⽣生成

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        do {
            self.coordinate = try container.decodeIfPresent(Coordinate.self, forKey: .coordinate)
        } catch DecodingError.keyNotFound {
            self.coordinate = nil
        }
    }
}

do {
    let inputData = invalidJSONInput.data(using: .utf8)!
    let decoder = JSONDecoder()
    let decoded = try decoder.decode([Placemark4].self, from: inputData)
    decoded // [Berlin (nil)]
} catch {
    print(error.localizedDescription)
}
 */


// 让其他人的代码满足 Codable
import CoreLocation

// <1>
struct Placemark6: Codable {
    var name: String
    var coordinate: CLLocationCoordinate2D
}

extension Placemark6 {
    private enum CodingKeys: String, CodingKey {
        case name
        case latitude = "lat"
        case longitude = "lon"
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        // 分别编码纬度和经度
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        // 从纬度和经度重新构建 CLLocationCoordinate2D
        self.coordinate = CLLocationCoordinate2D(
            latitude: try container.decode(Double.self, forKey: .latitude),
            longitude: try container.decode(Double.self, forKey: .longitude)
        )
    }
}

// <2> 嵌套容器
/*
struct Placemark7: Encodable {
    var name: String
    var coordinate: CLLocationCoordinate2D
    
    private enum CodingKeys: CodingKey {
        case name
        case coordinate
    }
    
    // 嵌套容器的编码键
    private enum CoordinateCodingKeys: CodingKey {
        case latitude
        case longitude
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        var coordinateContainer = container.nestedContainer(
            keyedBy: CoordinateCodingKeys.self, forKey: .coordinate)
        try coordinateContainer.encode(coordinate.latitude, forKey: .latitude)
        try coordinateContainer.encode(coordinate.longitude, forKey: .longitude)
    }
}
 */

// <3> 使用计算属性绕开问题
/*
struct Placemark8: Codable {
    var name: String
    private var _coordinate: Coordinate
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: _coordinate.latitude,
                                          longitude: _coordinate.longitude)
        }
        set {
            _coordinate = Coordinate(latitude: newValue.latitude,
                                     longitude: newValue.longitude)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case _coordinate = "coordinate"
    }
}
 */


// 让类满足 Codable
// 推荐的方式是写一个结构体来封装 UIColor，并且对这个结构体进行编解码
extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return (red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }
}

extension UIColor {
    struct CodableWrapper: Codable {
        var value: UIColor
        
        init(_ value: UIColor) {
            self.value = value
        }
        
        enum CodingKeys: CodingKey {
            case red
            case green
            case blue
            case alpha
        }
        
        func encode(to encoder: Encoder) throws {
            // 如果颜⾊不不能转为 RGBA，则抛出错误
            guard let (red, green, blue, alpha) = value.rgba else {
                let errorContext = EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription:
                        "Unsupported color format: \(value)"
                )
                throw EncodingError.invalidValue(value, errorContext)
            }
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(red, forKey: .red)
            try container.encode(green, forKey: .green)
            try container.encode(blue, forKey: .blue)
            try container.encode(alpha, forKey: .alpha)
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let red = try container.decode(CGFloat.self, forKey: .red)
            let green = try container.decode(CGFloat.self, forKey: .green)
            let blue = try container.decode(CGFloat.self, forKey: .blue)
            let alpha = try container.decode(CGFloat.self, forKey: .alpha)
            self.value = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
    }
}

// 计算属性
/*
struct ColoredRect: Codable {
    var rect: CGRect
    // 对颜色进⾏存储
    private var _color: UIColor.CodableWrapper
    var color: UIColor {
        get { return _color.value }
        set { _color.value = newValue }
    }
    
    init(rect: CGRect, color: UIColor) {
        self.rect = rect
        self._color = UIColor.CodableWrapper(color)
    }
    
    private enum CodingKeys: String, CodingKey {
        case rect
        case _color = "color"
    }
}

let rects = [ColoredRect(rect: CGRect(x: 10, y: 20, width: 100, height: 200), color: .yellow)]
do {
    let encoder = JSONEncoder()
    let jsonData = try encoder.encode(rects)
    let jsonString = String(decoding: jsonData, as: UTF8.self)
    // [{"color":{"red":1,"alpha":1,"blue":0,"green":1},"rect":[[10,20],[100,200]]}]
} catch {
    print(error.localizedDescription)
}
 */


// 让枚举满足 Codable
/*
enum Either<A: Codable, B: Codable>: Codable {
    case left(A)
    case right(B)
    
    private enum CodingKeys: CodingKey {
        case left
        case right
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .left(let value):
            try container.encode(value, forKey: .left)
        case .right(let value):
            try container.encode(value, forKey: .right)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let leftValue = try container.decodeIfPresent(A.self, forKey: .left) {
            self = .left(leftValue)
        } else {
            let rightValue = try container.decode(B.self, forKey: .right)
            self = .right(rightValue)
        }
    }
}
 */

/*
let values: [Either<String, Int>] = [
    .left("Forty-two"),
    .right(42)
]

do {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    let xmlData = try encoder.encode(values)
    let xmlString = String(decoding: xmlData, as: UTF8.self)

    let decoder = PropertyListDecoder()
    let decoded = try decoder.decode([Either<String, Int>].self, from: xmlData)
} catch {
    print(error.localizedDescription)
}
 */

// 解码多态集合
enum Viewz {
    case view(UIView)
    case label(UILabel)
    case imageView(UIImageView)
    // ...
}
