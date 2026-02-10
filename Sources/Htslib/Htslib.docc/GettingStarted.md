# Getting Started with swift-htslib

Install swift-htslib and read your first BAM file.

## Overview

swift-htslib is a Swift package that wraps the C htslib library, providing safe access
to SAM/BAM/CRAM, VCF/BCF, FASTA, and BGZF file formats.

## Prerequisites

- **macOS 14+** or **iOS 17+**
- **Swift 6.0+**
- **htslib** installed via Homebrew or apt:

```
brew install htslib      # macOS
apt install libhts-dev   # Debian/Ubuntu
```

- **pkg-config** so Swift Package Manager can locate htslib:

```
brew install pkg-config
```

## Installation

Add swift-htslib to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/swift-htslib.git", from: "0.1.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "Htslib", package: "swift-htslib"),
        ]
    ),
]
```

## Reading Your First BAM File

Open a BAM file, read its header, and iterate over alignment records:

```swift
import Htslib

// Open the file
let file = try HTSFile(path: "sample.bam", mode: "r")
let header = try SAMHeader(from: file)

// Create an iterator
let iterator = SAMRecordIterator(file: file.rawPointer, header: header.pointer)

// Read records
while let record = iterator.next() {
    print("\(record.queryName) at position \(record.position)")
    print("  CIGAR: \(record.cigar.map { "\($0.length)\($0.character)" }.joined())")
    print("  Sequence: \(record.sequence.string)")
}
```

## Using Thread Pools

For better performance with large files, share a thread pool across
multiple file handles:

```swift
let pool = try ThreadPool(threads: 4)

let bam1 = try HTSFile(path: "sample1.bam", mode: "r")
bam1.setThreadPool(pool)

let bam2 = try HTSFile(path: "sample2.bam", mode: "r")
bam2.setThreadPool(pool)
```

## Next Steps

- <doc:WorkingWithBAM> — Region queries, pileup, and async reading
- <doc:WorkingWithVCF> — Reading VCF files, INFO/FORMAT access, genotypes
