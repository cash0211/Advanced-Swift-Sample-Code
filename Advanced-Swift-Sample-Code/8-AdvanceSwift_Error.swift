//
//  AdvanceSwift_Error.swift
//  SwiftTips
//
//  Created by cash on 2019/3/17.
//  Copyright © 2019 cash. All rights reserved.
//

import Foundation

enum Result<A> {
    case failure(Error)
    case success(A)
}

enum FileError: Error {
    case fileDoesNotExist
    case noPermission
}


/// 引入 try
class AdvanceSwift_Error {
    func contents(ofFile filename: String) -> Result<String> {
        return .success("")
    }
    
    func op() {
        let result = contents(ofFile: "input.txt")
        switch result {
        case let .success(contents):
            print(contents)
        case let .failure(error):
            if let fileError = error as? FileError,
                fileError == .fileDoesNotExist
            {
                print("File not found")
            } else {
                //处理理错误
            }
        }
    }
    
    /// 打开⼀一个⽂文本⽂文件，并返回它的内容。
    ///
    /// - Parameter filename: 读取⽂文件的名字。
    /// - Returns: 以 UTF-8 表示的⽂文件内容。
    /// - Throws: 如果⽂文件不不存在或者操作没有读取权限，抛出 `FileError`。
    func contents2(ofFile filename: String) throws -> String {
        return ""
    }
    
    func op2() {
        do {
            let result = try contents2(ofFile: "input.txt")
            print(result)
        } catch FileError.fileDoesNotExist {
            print("File not found")
        } catch {
            print(error)
            // 处理其他错误
        }
    }
}

/// 将错误桥接到 Objective-C
enum ParseError: Error {
    case wrongEncoding
    case warning(line: Int, message: String)
}

extension ParseError: CustomNSError {
    static let errorDomain = "io.objc.parseError"
    var errorCode: Int {
        switch self {
        case .wrongEncoding: return 100
        case .warning(_, _): return 200
        }
    }
    var errorUserInfo: [String: Any] {
        return [:]
    }
}

enum Result2<A, ErrorType: Error> {
    case failure(ErrorType)
    case success(A)
}

class AdvanceSwift_Error2 {
    func parse(text: String) -> Result2<[String], ParseError> {
        return .success([])
    }
}

// → LocalizedError — 提供一个本地化的信息，来表示错误为什么发生(failureReason)， 从错误中恢复的提示 (recoverySuggestion) 以及额外的帮助文本 (helpAnchor)。
// → RecoverableError — 描述一个用戶可以恢复的错误，展示一个或多个 recoveryOptions，并在用戶要求的时候执行恢复。

// Rethrows
extension Sequence {
    /// 当且仅当所有元素满⾜足条件时返回 `true`
    func all(matching predicate: (Element) throws -> Bool) rethrows -> Bool {
        for element in self {
            guard try predicate(element) else { return false }
        }
        return true
    }
}

enum ReadIntError: Error {
    case couldNotRead
}

class AdvanceSwift_Error3 {
    func checkFile(filename: String) throws -> Bool { return true }
    
    func checkAllFiles(filenames: [String]) throws -> Bool {
        return try filenames.all(matching: checkFile)
    }
    
    // 错误和可选值
    func op() {
        do {
            let int = try Int("42").or(error: ReadIntError.couldNotRead)
        } catch {
            print(error)
        }
    }
}

extension Optional {
    /// 如果 `self` 不不是 `nil` 的话，解包。
    /// 如果 `self` 是 `nil` 则抛出给定的错误。
    func or(error: Error) throws -> Wrapped {
        switch self {
        case let x?: return x
        case nil: throw error
        }
    }
}

// 链结果
extension Result {
    func flatMap<B>(transform: (A) -> Result<B>) -> Result<B> {
        switch self {
        case let .failure(m): return .failure(m)
        case let .success(x): return transform(x)
        }
    }
}

class AdvanceSwift_Error4 {
    /*  all(matching:)，checkFile 和 contents(ofFile:) 都是返回 Result 值的变种版本。
    func checkFilesAndFetchProcessID(filenames: [String]) -> Result<Int> {
        return filenames
            .all(matching: checkFile)
            .flatMap { _ in contents(ofFile: "Pidfile") }
            .flatMap { contents in
                Int(contents).map(Result.success)
                    ?? .failure(ReadIntError.couldNotRead)
        }
    }
     */
}
