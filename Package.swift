import PackageDescription

let package = Package(
    name: "Git2",
    dependencies: [
      .Package(url: "https://github.com/cysp/swift-CGit2.git", Version(0, 0, 0)),
    ]
)
