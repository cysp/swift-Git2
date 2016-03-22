import PackageDescription

let package = Package(
    name: "Git2",
    dependencies: [
      .Package(url: "../CGit2", Version(0, 0, 0)),
    ]
)
