# swift-htslib

A Swift interface to [htslib](https://github.com/samtools/htslib), the C library for reading and writing high-throughput sequencing data formats.

## Features

- **SAM/BAM/CRAM** — Read and write alignment files with full access to records, headers, CIGAR, sequence, qualities, and auxiliary tags
- **VCF/BCF** — Read and write variant call files with typed INFO/FORMAT field access and genotype decoding
- **FASTA/FAI** — Indexed FASTA sequence retrieval by region or coordinates
- **BGZF** — Direct access to BGZF-compressed file I/O with virtual offsets
- **Indexing** — Load, query, and build BAI/CSI/TBI indexes
- **Pileup** — Single-sample and multi-sample pileup iteration
- **Async readers** — Actor-isolated `AsyncBAMReader` and `AsyncVCFReader` for structured concurrency
- **Thread pools** — Shared `ThreadPool` for parallel decompression across multiple files
- **Move-only types** — `BAMRecord`, `VCFRecord`, and file handles use `~Copyable` for safe resource management
- **Swift 6 concurrency** — Strict `Sendable` conformance throughout

## Requirements

- **macOS 14+** or **iOS 17+**
- **Swift 6.0+**
- **htslib** installed via [Homebrew](https://brew.sh) or apt:
  ```
  brew install htslib    # macOS
  apt install libhts-dev # Debian/Ubuntu
  ```
- **pkg-config** (for Swift Package Manager to locate htslib headers):
  ```
  brew install pkg-config
  ```

## Installation

Add swift-htslib as a dependency in your `Package.swift`:

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

## Quick Start

### Read a BAM file

```swift
import Htslib

let file = try HTSFile(path: "sample.bam", mode: "r")
let header = try SAMHeader(from: file)
let iterator = SAMRecordIterator(file: file.rawPointer, header: header.pointer)

while let record = iterator.next() {
    print("\(record.queryName) at \(record.position)")
}
```

### Region query with index

```swift
let file = try HTSFile(path: "sample.bam", mode: "r")
let header = try SAMHeader(from: file)
let index = try HTSIndex(path: "sample.bam")

let (tid, start, end) = try RegionParser.parse(region: "chr1:1000-2000", header: header)
let iter = sam_itr_queryi(index.pointer, tid, start, end)
let query = SAMQueryIterator(file: file.rawPointer, iterator: iter!)

while let record = query.next() {
    print("\(record.queryName) at \(record.position)")
}
```

### Async BAM reader

```swift
let reader = try AsyncBAMReader(path: "sample.bam", loadIndex: true)

// Sequential
while let record = try await reader.next() {
    print(record.queryName)
}

// Region query
try await reader.query(region: "chr1:1000-2000")
while let record = try await reader.next() {
    print(record.queryName)
}
```

### Read a VCF file

```swift
let file = try HTSFile(path: "variants.vcf.gz", mode: "r")
let header = try VCFHeader(from: file)
let iterator = VCFRecordIterator(file: file.rawPointer, header: header.pointer)

while var record = iterator.next() {
    try record.unpack()
    print("pos=\(record.position) alleles=\(record.alleles)")
}
```

### Fetch a FASTA sequence

```swift
let fai = try FASTAIndex(path: "reference.fa")
let seq = try fai.fetch(region: "chr1:1000-2000")
print(seq)
```

## Architecture

swift-htslib is organized as three layers:

| Layer | Target | Description |
|-------|--------|-------------|
| **CHtslib** | System library | Imports htslib headers via pkg-config |
| **CHTSlibShims** | C shims | Wraps macros, variadic functions, and inline helpers that Swift cannot import directly |
| **Htslib** | Swift API | Public Swift types and functions |

### Module Map

The `Htslib` target is organized into these logical modules:

- **Core** — `HTSFile`, `HTSError`, `HTSFileFormat`, `HTSFormatCategory`, `HTSVersion`, `ThreadPool`
- **SAM** — `BAMRecord`, `SAMHeader`, `AlignmentFlag`, `CIGAROperation`, `AuxiliaryData`, `SAMRecordIterator`, `SAMQueryIterator`
- **Pileup** — `PileupEntry`, `PileupColumn`, `PileupIterator`, `MultiPileupColumn`, `MultiPileupIterator`
- **Base Modifications** — `BaseModification`, `BaseModificationState`, `BaseModificationIterator`
- **VCF** — `VCFRecord`, `VCFHeader`, `Genotype`, `VariantType`, `VCFRecordIterator`, `SyncedBCFReader`
- **FASTA** — `FASTAIndex`, `FASTASequence`
- **BGZF** — `BGZFFile`
- **Index** — `HTSIndex`, `TabixIndex`, `RegionParser`
- **I/O** — `HFile`
- **Async** — `AsyncBAMReader`, `AsyncVCFReader`

## License

See [LICENSE](LICENSE.md) for details.
