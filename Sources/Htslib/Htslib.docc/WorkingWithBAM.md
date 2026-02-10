# Working with BAM Files

Read alignment records, perform region queries, and use pileup iteration.

## Overview

BAM files contain aligned sequencing reads. swift-htslib provides ``BAMRecord`` for
accessing individual alignments, index-based region queries, pileup iteration for
computing coverage, and actor-based async readers for structured concurrency.

## Reading All Records

Use ``SAMRecordIterator`` to read every record in a BAM file sequentially:

```swift
let file = try HTSFile(path: "sample.bam", mode: "r")
let header = try SAMHeader(from: file)
let iter = SAMRecordIterator(file: file.rawPointer, header: header.pointer)

while let record = iter.next() {
    print(record.queryName, record.position, record.mappingQuality)
}
```

## Accessing Record Fields

``BAMRecord`` exposes the full set of SAM fields:

```swift
// Core fields
record.position        // 0-based position
record.contigID        // reference sequence ID
record.mappingQuality  // MAPQ
record.flag            // AlignmentFlag option set
record.insertSize      // template length

// Convenience flags
record.isReverse
record.isUnmapped
record.isSecondary
record.isDuplicate

// CIGAR operations
for op in record.cigar {
    print("\(op.length)\(op.character)")
}

// Sequence and qualities
let seq = record.sequence.string
let quals = Array(record.qualities)

// Auxiliary tags
if let nm = record.auxiliaryData.integer(forTag: "NM") {
    print("Edit distance: \(nm)")
}
```

## Region Queries

Load an index and query a specific genomic region:

```swift
let file = try HTSFile(path: "sample.bam", mode: "r")
let header = try SAMHeader(from: file)
let index = try HTSIndex(path: "sample.bam")

// Parse a region string
let (tid, start, end) = try RegionParser.parse(region: "chr1:1000-2000", header: header)

// Create a query iterator
let iter = sam_itr_queryi(index.pointer, tid, start, end)
let query = SAMQueryIterator(file: file.rawPointer, iterator: iter!)

while let record = query.next() {
    print(record.queryName, record.position)
}
```

## Pileup

Compute per-position coverage using ``PileupIterator``:

```swift
let file = try HTSFile(path: "sample.bam", mode: "r")
let header = try SAMHeader(from: file)

let pileup = PileupIterator(file: file.rawPointer, header: header.pointer)
pileup.setMaxDepth(8000)

while let column = pileup.next() {
    print("Position \(column.position): depth \(column.depth)")
    for entry in column.entries {
        print("  base=\(entry.base) qual=\(entry.baseQuality)")
    }
}
```

## Async Reading

Use ``AsyncBAMReader`` for actor-isolated, async/await-compatible reading:

```swift
let reader = try AsyncBAMReader(path: "sample.bam", loadIndex: true)

// Sequential reading
while let record = try await reader.next() {
    print(record.queryName)
}

// Region query
try await reader.query(region: "chr1:1000-2000")
while let record = try await reader.next() {
    print(record.queryName)
}

// Reset to sequential mode
await reader.resetQuery()
```
