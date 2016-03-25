//  Copyright © 2016 Scott Talbot. All rights reserved.

import CGit2


internal typealias git_reference = OpaquePointer

public final class Reference {
    private let _repo: Repository
    private let _inner: git_reference

    internal init(repo: Repository, inner: git_reference) {
        _repo = repo
        _inner = inner
//        print("git_reference.init(\(_inner))")
    }
    deinit {
//        print("git_reference_free(\(_inner))")
        git_reference_free(_inner)
    }

    public var name: String? {
        get {
            let name_bytes: UnsafePointer<CChar> = git_reference_name(_inner)
            if name_bytes == nil {
                return nil
            }
            return String(cString: name_bytes)
        }
    }
}


extension Reference: Equatable { }

public func ==(lhs: Reference, rhs: Reference) -> Bool {
    if git_reference_cmp(lhs._inner, rhs._inner) == 0 {
        return false
    }
    return true
}
