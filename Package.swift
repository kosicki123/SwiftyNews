import PackageDescription

let package = Package(
    name: "PomoNews",
    dependencies: [
        .Package(url: "https://github.com/qutheory/vapor.git", majorVersion: 0, minor: 4),
        .Package(url: "https://github.com/qutheory/vapor-zewo-mustache.git", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/czechboy0/Redbird.git", majorVersion: 0)
    ],
    exclude: [
        "Deploy",
        "Public",
        "Resources",
		"Tests",
		"Database"
    ]
)
