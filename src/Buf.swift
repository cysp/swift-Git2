//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation
import CGit2


public final class Buf {
    private var _inner: UnsafeMutablePointer<git_buf>

    public init() {
        _inner = UnsafeMutablePointer.init(allocatingCapacity: 1)
        _inner.initialize(with: git_buf(ptr: nil, asize: 0, size: 0))
    }
    public init(rawValue inner: UnsafeMutablePointer<git_buf>) {
        _inner = UnsafeMutablePointer(inner)
    }

    deinit {
        git_buf_free(_inner)
        _inner.deinitialize(count: 1)
    }
}


extension Buf: RawRepresentable {
    public typealias RawValue = UnsafeMutablePointer<git_buf>

    public var rawValue: Buf.RawValue {
        get {
            return _inner
        }
    }
}


public enum BufStringError: Int32, ErrorProtocol {
    case IsBinary = 1
    case ContainsNul = 2
    case NonUtf8 = 3
}

extension Buf {
    public func stringValue() throws -> String {
        if git_buf_is_binary(_inner) != 0 {
            throw BufStringError.IsBinary
        }
        if git_buf_contains_nul(_inner) != 0 {
            throw BufStringError.ContainsNul
        }
        guard let s = String(cString: _inner.pointee.ptr, encoding: NSUTF8StringEncoding) else {
            throw BufStringError.NonUtf8
        }
        return s
    }
}
