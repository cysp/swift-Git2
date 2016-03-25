//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation
import CGit2


internal typealias git_repository = OpaquePointer


public enum RepositoryError: ErrorProtocol {
    case NotFound
}

public enum RepositoryRevwalkError: ErrorProtocol {
    case Error(Int32)
}


public final class Repository {
    private let _inner: git_repository

    internal init(inner: git_repository) {
        _inner = inner
//        print("git_repository.init(\(_inner))")
    }
    deinit {
//        print("git_repository_free(\(_inner))")
        git_repository_free(_inner)
    }

    private class func discover(start_path: String, across_fs: Bool = false) -> String? {
        let discovered_path_buf = Buf()
        let sp = (start_path as NSString).fileSystemRepresentation
        let result = git_repository_discover(discovered_path_buf.rawValue, sp, across_fs ? 1 : 0, nil);
        if result != GIT_OK.rawValue {
            return nil
        }

        let discovered_path_string: String
        do {
            discovered_path_string = try discovered_path_buf.stringValue()
        } catch {
            return nil
        }
        return discovered_path_string
    }

    public class func discover(start_path: String, across_fs: Bool = false) throws -> Repository {
        guard let path: String = discover(start_path, across_fs: across_fs) else {
            throw RepositoryError.NotFound
        }

        return try open(path)
    }

    public class func open(path: String) throws -> Repository {
        print("repo: \(path)")
        var r: git_repository = nil
        let result = git_repository_open(&r, (path as NSString).fileSystemRepresentation)
        if result != GIT_OK.rawValue {
            throw RepositoryError.NotFound
        }

        return Repository(inner: r)
    }

    public var isBare: Bool {
        get {
            if git_repository_is_bare(_inner) == 0 {
                return false
            }
            return true
        }
    }

    public var workdir: String? {
        get {
            let workdir_bytes: UnsafePointer<CChar> = git_repository_workdir(_inner)
            if workdir_bytes == nil {
                return nil
            }
            return String(cString: workdir_bytes)
        }
    }

    public var head: Reference? {
        get {
            var head: OpaquePointer = nil
            let result = git_repository_head(&head, _inner)
            if result != 0 {
                return nil
            }
            return Reference(repo: self, inner: head)
        }
    }

    public func find_commit(oid: Oid) -> Commit? {
        var commit_raw: git_commit = nil
        let result = git_commit_lookup(&commit_raw, _inner, oid.rawUnsafePointer)
        if result != 0 {
            return nil
        }
        return Commit(repo: self, inner: commit_raw)
    }

    public var submodules: [Submodule] {
        get {
            final class SubmoduleAccumulator {
                private var repository: Repository
                private var submodules: [Submodule]

                private init(repository: Repository) {
                    self.repository = repository
                    submodules = []
                }

                private func add(submoduleName: UnsafePointer<Int8>) {
                    let submodule_lookedup_raw = UnsafeMutablePointer<git_submodule>.init(allocatingCapacity: 1)
                    defer { submodule_lookedup_raw.deinitialize() }
                    let result = git_submodule_lookup(submodule_lookedup_raw, repository._inner, submoduleName)
                    switch result {
                    case 0, GIT_EEXISTS.rawValue:
                        submodules.append(Submodule(repo: repository, inner: submodule_lookedup_raw.pointee))
                    case _:
                        break
                    }
                }
            }

            var sa = SubmoduleAccumulator(repository: self)

            let trampoline: @convention(c) (git_submodule, UnsafePointer<Int8>, UnsafeMutablePointer<Void>) -> Int32 = { (_, name, payload) in
                let s = UnsafeMutablePointer<SubmoduleAccumulator>(payload)
                s.pointee.add(name)
                return 0
            }

            git_submodule_foreach(_inner, trampoline, &sa)

            return sa.submodules
        }
    }

//    private typealias SubmoduleForeachCallback = (Submodule) -> Void
//    private func submoduleForEach(callback: SubmoduleForeachCallback) {
//        let trampoline: @convention(c) (git_submodule, UnsafePointer<Int8>, UnsafeMutablePointer<Void>) -> Int32 = { (submodule, name, payload) in
//            let s = Submodule(repo: self, unownedInner: submodule)
//            let callback = UnsafeMutablePointer<Repository.SubmoduleForeachCallback>(payload)
//            callback.pointee(s)
//            return 0
//        }
//
//        var cb = callback
//        git_submodule_foreach(_inner, trampoline, &cb)
//    }

    public func revwalk() throws -> Revwalk {
//        print("Repository.revwalk")
        let revwalk_raw = UnsafeMutablePointer<git_revwalk>.init(allocatingCapacity: 1)
        defer { revwalk_raw.deinitialize() }
        let result = git_revwalk_new(revwalk_raw, _inner)
        if result != 0 {
            print("Repository.revwalk: \(result)")
            throw RepositoryRevwalkError.Error(result)
        }
        let revwalk = Revwalk(repo: self, inner: revwalk_raw.pointee)
        return revwalk
    }
}
