//  Copyright © 2016 Scott Talbot. All rights reserved.

import CGit2


internal typealias git_submodule = OpaquePointer

public final class Submodule {
    private let _repo: Repository
    private let _inner: git_submodule
    private let _owned: Bool

    internal init(repo: Repository, inner: git_submodule) {
        _repo = repo
        _inner = inner
        _owned = true
//        print("git_submodule.init(\(_inner))")
    }
    internal init(repo: Repository, unownedInner inner: git_submodule) {
        _repo = repo
        _inner = inner
        _owned = false
    }
    deinit {
        if _owned {
            git_submodule_free(_inner)
        }
    }

    public var name: String {
        get {
            let name_bytes: UnsafePointer<CChar> = git_submodule_name(_inner)
            return String(cString: name_bytes)
        }
    }

    public var path: String {
        get {
            let path_bytes: UnsafePointer<CChar> = git_submodule_path(_inner)
            return String(cString: path_bytes)
        }
    }

    public var url: String {
        get {
            let url_bytes: UnsafePointer<CChar> = git_submodule_url(_inner)
            return String(cString: url_bytes)
        }
    }

    public var headId: Oid? {
        get {
            let oid = git_submodule_head_id(_inner)
            if oid == nil {
                return nil
            }
            return Oid(rawValue: oid.pointee)
        }
    }

    public var indexId: Oid? {
        get {
            let oid = git_submodule_index_id(_inner)
            if oid == nil {
                return nil
            }
            return Oid(rawValue: oid.pointee)
        }
    }

    public var workdirId: Oid? {
        get {
            let oid = git_submodule_wd_id(_inner)
            if oid == nil {
                return nil
            }
            return Oid(rawValue: oid.pointee)
        }
    }
}
