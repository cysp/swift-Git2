//  Copyright © 2016 Scott Talbot. All rights reserved.

import CGit2


public struct Sorting: OptionSet {
    public typealias RawValue = UInt32

    public let rawValue: Sorting.RawValue

    public init() {
        self.rawValue = GIT_SORT_NONE.rawValue
    }
    public init(rawValue: Sorting.RawValue) {
        self.rawValue = rawValue
    }

    public static let None = Sorting(rawValue: GIT_SORT_NONE.rawValue)
    public static let Topological = Sorting(rawValue: GIT_SORT_TOPOLOGICAL.rawValue)
    public static let Time = Sorting(rawValue: GIT_SORT_TIME.rawValue)
    public static let Reverse = Sorting(rawValue: GIT_SORT_REVERSE.rawValue)
}