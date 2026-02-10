# Working with VCF Files

Read variant records, access INFO and FORMAT fields, and decode genotypes.

## Overview

VCF (Variant Call Format) files describe genetic variants. swift-htslib provides
``VCFRecord`` for accessing variant data, typed INFO/FORMAT field accessors,
genotype decoding, and a synced reader for comparing variants across multiple files.

## Reading VCF Records

Use ``VCFRecordIterator`` to read records sequentially. Call ``VCFRecord/unpack(_:)``
before accessing decoded fields:

```swift
let file = try HTSFile(path: "variants.vcf.gz", mode: "r")
let header = try VCFHeader(from: file)
let iter = VCFRecordIterator(file: file.rawPointer, header: header.pointer)

while var record = iter.next() {
    try record.unpack()
    print("pos=\(record.position) alleles=\(record.alleles)")
    print("type=\(record.variantType) qual=\(record.quality)")
}
```

## Accessing INFO Fields

Use the typed INFO accessors to retrieve field values:

```swift
// Integer INFO field (e.g. DP, AC)
if let dp = record.infoInt32(forKey: "DP", header: header) {
    print("Total depth: \(dp[0])")
}

// Float INFO field (e.g. AF)
if let af = record.infoFloat(forKey: "AF", header: header) {
    print("Allele frequencies: \(af)")
}

// String INFO field
if let gene = record.infoString(forKey: "GENE", header: header) {
    print("Gene: \(gene)")
}

// Flag INFO field
if record.infoFlag(forKey: "DB", header: header) {
    print("In dbSNP")
}
```

## Accessing FORMAT Fields

FORMAT fields contain per-sample data. The returned arrays are flattened
across all samples:

```swift
// Per-sample depth
if let dp = record.formatInt32(forKey: "DP", header: header) {
    for (i, depth) in dp.enumerated() {
        print("Sample \(i): depth \(depth)")
    }
}

// Per-sample genotype likelihoods
if let gl = record.formatFloat(forKey: "GL", header: header) {
    print("Likelihoods: \(gl)")
}
```

## Decoding Genotypes

Use ``VCFRecord/genotypes(header:)`` to decode the GT field into
structured ``Genotype`` values:

```swift
if let gts = record.genotypes(header: header) {
    for (i, gt) in gts.enumerated() {
        let alleleStr = gt.alleles.map { $0.map(String.init) ?? "." }.joined(separator: "/")
        print("Sample \(i): \(alleleStr)")
        print("  ploidy=\(gt.ploidy) het=\(gt.isHeterozygous) hom=\(gt.isHomozygous)")
    }
}
```

## Synced BCF Reader

Use ``SyncedBCFReader`` to iterate multiple VCF/BCF files simultaneously
in coordinate order:

```swift
let reader = try SyncedBCFReader()
reader.allowNoIndex()
try reader.addReader(path: "sample1.vcf.gz")
try reader.addReader(path: "sample2.vcf.gz")

while reader.nextLine() > 0 {
    for i in 0..<reader.nReaders {
        if reader.hasLine(at: i), var record = reader.getRecord(at: i) {
            try record.unpack()
            print("Reader \(i): \(record.alleles)")
        }
    }
}
```

## Async Reading

Use ``AsyncVCFReader`` for actor-isolated reading with async/await:

```swift
let reader = try AsyncVCFReader(path: "variants.vcf.gz", loadIndex: true)

// Sequential
while var record = try await reader.next() {
    try record.unpack()
    print(record.alleles)
}

// Region query
try await reader.query(region: "chr1:1000-2000")
while var record = try await reader.next() {
    try record.unpack()
    print(record.alleles)
}
```
