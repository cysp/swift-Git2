//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation
import CGit2


internal typealias git_commit = OpaquePointer


public final class Commit {
    private let _repo: Repository
    private let _inner: git_commit;

    internal init(repo: Repository, inner: git_commit) {
        _repo = repo
        _inner = inner
    }
    deinit {
        git_commit_free(_inner)
    }

    public var id: Oid {
        get {
            let oid_raw = git_commit_id(_inner)
            return Oid(rawValue: oid_raw.pointee)
        }
    }

    public var message: String {
        get {
            let message_bytes: UnsafePointer<CChar> = git_commit_message(_inner)
            return String(cString: message_bytes)
        }
    }

    public var summary: String {
        get {
            let summary_bytes: UnsafePointer<CChar> = git_commit_summary(_inner)
            return String(cString: summary_bytes)
        }
    }

//    public var body: String {
//        get {
//            let summary_bytes: UnsafePointer<CChar> = git_commit_body(_inner)
//            return String(cString: summary_bytes)
//        }
//    }
}
