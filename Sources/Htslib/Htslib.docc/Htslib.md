# ``Htslib``

A Swift interface to htslib for reading and writing high-throughput sequencing data.

## Overview

swift-htslib provides Swift types and functions for working with common bioinformatics
file formats: SAM/BAM/CRAM alignment files, VCF/BCF variant call files, indexed FASTA
sequences, and BGZF-compressed data. It wraps the C htslib library with a safe, idiomatic
Swift API that uses move-only types for resource management and strict `Sendable`
conformance for concurrency safety.

## Topics

### Core

- ``HTSFile``
- ``HTSError``
- ``HTSFileFormat``
- ``HTSFormatCategory``
- ``HTSVersion``
- ``ThreadPool``

### SAM/BAM/CRAM

- ``BAMRecord``
- ``SAMHeader``
- ``AlignmentFlag``
- ``CIGAROperation``
- ``CIGARSequence``
- ``BAMSequence``
- ``BAMQualities``
- ``AuxiliaryData``
- ``SAMRecordIterator``
- ``SAMQueryIterator``

### Pileup

- ``PileupEntry``
- ``PileupColumn``
- ``PileupIterator``
- ``MultiPileupColumn``
- ``MultiPileupIterator``

### Base Modifications

- ``BaseModification``
- ``BaseModificationState``
- ``BaseModificationIterator``

### VCF/BCF

- ``VCFRecord``
- ``VCFHeader``
- ``Genotype``
- ``VariantType``
- ``VCFRecordIterator``
- ``SyncedBCFReader``

### FASTA

- ``FASTAIndex``
- ``FASTASequence``

### BGZF

- ``BGZFFile``

### Index

- ``HTSIndex``
- ``TabixIndex``
- ``RegionParser``

### I/O

- ``HFile``

### Async Readers

- ``AsyncBAMReader``
- ``AsyncVCFReader``

### Articles

- <doc:GettingStarted>
- <doc:WorkingWithBAM>
- <doc:WorkingWithVCF>
