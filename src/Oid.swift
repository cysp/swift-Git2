//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation
import CGit2



public final class Oid {
    private let _inner: UnsafeMutablePointer<git_oid>

    internal init(rawValue: git_oid) {
        _inner = UnsafeMutablePointer.init(allocatingCapacity: 1)
        _inner.initialize(with: rawValue)
    }
    deinit {
        _inner.deinitialize()
    }

    internal var rawUnsafePointer: UnsafePointer<git_oid> {
        get {
            return UnsafePointer(_inner)
        }
    }
}

extension Oid: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        get {
            do {
                let buf = Buf()
                try buf.grow(20)
                git_oid_tostr(buf.rawValue.pointee.ptr, 20, _inner)
                let oid_string = try buf.stringValue()
                return oid_string
            } catch {
                return ""
            }
        }
    }
    public var debugDescription: String {
        get {
            return "Oid(\(description))"
        }
    }
}

//extension Oid: RawRepresentable {
//    public typealias RawValue = git_oid
//
//    public var rawValue: git_oid {
//        get {
//            return _inner.pointee
//        }
//    }
//}

extension Oid: Equatable { }
public func ==(lhs: Oid, rhs: Oid) -> Bool {
    return git_oid_equal(lhs._inner, rhs._inner) != 0
}

extension Oid: Comparable { }
public func <(lhs: Oid, rhs: Oid) -> Bool {
    return git_oid_cmp(lhs._inner, rhs._inner) < 0
}

public func <=(lhs: Oid, rhs: Oid) -> Bool {
    return git_oid_cmp(lhs._inner, rhs._inner) <= 0
}

public func >=(lhs: Oid, rhs: Oid) -> Bool {
    return git_oid_cmp(lhs._inner, rhs._inner) >= 0
}

public func >(lhs: Oid, rhs: Oid) -> Bool {
    return git_oid_cmp(lhs._inner, rhs._inner) > 0
}
