//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation
import CGit2


public enum RevwalkError: ErrorProtocol {
    case Error(Int32)
}


internal typealias git_revwalk = OpaquePointer

public final class Revwalk {
    private let _repo: Repository
    private let _inner: git_revwalk

    internal init(repo: Repository, inner: git_revwalk) {
        _repo = repo
        _inner = inner
        sorting = .None
    }
    deinit {
        git_revwalk_free(_inner)
    }

    public func reset() {
        git_revwalk_reset(_inner)
    }

    public func pushHead() throws {
        let result = git_revwalk_push_head(_inner)
        if result != 0 {
            throw RevwalkError.Error(result)
        }
    }
    public func push(oid oid: Oid) throws {
        let result = git_revwalk_push(_inner, oid.rawUnsafePointer)
        if result != 0 {
            throw RevwalkError.Error(result)
        }
    }
    public func push(glob glob: String) throws {
        let result: Int32 = glob.nulTerminatedUTF8.withUnsafeBufferPointer { (glob_raw) -> Int32 in
            return git_revwalk_push_glob(_inner, unsafeBitCast(glob_raw.baseAddress, to: UnsafePointer<Int8>.self))
        }
        if result != 0 {
            throw RevwalkError.Error(result)
        }
    }

    public func hideHead() throws {
        let result = git_revwalk_hide_head(_inner)
        if result != 0 {
            throw RevwalkError.Error(result)
        }
    }
    public func hide(oid oid: Oid) throws {
        let result = git_revwalk_hide(_inner, oid.rawUnsafePointer)
        if result != 0 {
            throw RevwalkError.Error(result)
        }
    }
    public func hide(glob glob: String) throws {
        let result: Int32 = glob.nulTerminatedUTF8.withUnsafeBufferPointer { (glob_raw) -> Int32 in
            return git_revwalk_hide_glob(_inner, unsafeBitCast(glob_raw.baseAddress, to: UnsafePointer<Int8>.self))
        }
        if result != 0 {
            throw RevwalkError.Error(result)
        }
    }

    public var sorting: Sorting {
        didSet {
            git_revwalk_sorting(_inner, sorting.rawValue)
        }
    }

    private func next() -> Oid? {
        let raw_oid = UnsafeMutablePointer<git_oid>.init(allocatingCapacity: 1)
        defer { raw_oid.deinitialize() }
        let result = git_revwalk_next(raw_oid, _inner)
//        print("revwalk.next: \(result)")
        if result != 0 {
            return nil
        }
        let oid = Oid(rawValue: raw_oid.pointee)
//        print("oid: \(oid)")
        return oid
    }
}


extension Revwalk: Sequence {
    public typealias Iterator = RevwalkIterator

    public func makeIterator() -> Revwalk.Iterator {
//        print("Revwalk.makeIterator")
        return RevwalkIterator(self)
    }
}


public final class RevwalkIterator: IteratorProtocol {
    public typealias Element = Oid

    private let revwalk: Revwalk

    private init(_ revwalk: Revwalk) {
        self.revwalk = revwalk
    }

    public func next() -> RevwalkIterator.Element? {
//        print("RevwalkIterator.next")
        return self.revwalk.next()
    }
}
