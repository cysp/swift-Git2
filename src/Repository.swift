//  Copyright © 2016 Scott Talbot. All rights reserved.

import Foundation
import CGit2


typealias git_repository_t = OpaquePointer


public enum RepositoryError: ErrorProtocol {
    case NotFound
}


public final class Repository {
    let _inner: UnsafeMutablePointer<git_repository_t>


    private init(inner: UnsafeMutablePointer<git_repository_t>) {
        _inner = inner
    }
    deinit {
        git_repository_free(_inner.pointee)
        _inner.deinitialize(count: 1)
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

        let r: UnsafeMutablePointer<git_repository_t> = nil
        let result = git_repository_open(r, (path as NSString).fileSystemRepresentation)
        if result != GIT_OK.rawValue {
            throw RepositoryError.NotFound
        }

        return Repository(inner: r)
    }

    public var workdir: String? {
        get {
            let workdir_bytes: UnsafePointer<CChar>
            workdir_bytes = git_repository_workdir(_inner.pointee)
            if workdir_bytes == nil {
                return nil
            }
            return String(cString: workdir_bytes)
        }
    }
}
