import PackageDescription

let package = Package(
    name: "Tempo",
    targets: [
        Target(name: "CLI", dependencies: [.Target(name:"App")])
    ],
    dependencies: [
        .Package(url: "https://github.com/eelcokoelewijn/NetworkKit.git",
                         versions: Version(1,0,0)..<Version(2,0,0)),
        .Package(url: "https://github.com/eelcokoelewijn/FileKit.git",
                         versions: Version(1,0,0)..<Version(2,0,0)),
        .Package(url: "https://github.com/eelcokoelewijn/TempoKit.git",
                         versions: Version(1,0,0)..<Version(2,0,0))
    ]
)
