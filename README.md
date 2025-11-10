# Titan Crypt

[![Go Version](https://img.shields.io/badge/Go-1.21+-blue.svg)](https://golang.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Go Report Card](https://goreportcard.com/badge/github.com/dread-crypto/titan-crypt)](https://goreportcard.com/report/github.com/dread-crypto/titan-crypt)

**Titan Crypt** is a high-performance cryptographic primitives library written in Go, providing the foundational building blocks for zero-knowledge proof systems. Designed to support [Atlas VM](https://github.com/dread-crypto/atlas-vm) and other privacy-preserving applications.

## 🎯 Overview

Titan Crypt provides production-ready implementations of essential cryptographic primitives optimized for STARK-based proof systems. The library focuses on:

- **Performance**: Optimized field arithmetic and polynomial operations
- **Correctness**: Comprehensive test coverage with property-based testing
- **Clarity**: Clean, idiomatic Go code with extensive documentation
- **Compatibility**: Designed to work seamlessly with zkSTARK systems

## 🚀 Features

### Core Cryptographic Primitives

#### Field Arithmetic
- **Goldilocks Field**: High-performance operations over \( p = 2^{64} - 2^{32} + 1 \)
- **Extension Fields**: Degree-3 extension field for advanced protocols
- **Montgomery Arithmetic**: Optimized modular operations
- **Batch Operations**: Vectorized operations for performance

#### Hash Functions
- **Tip5**: STARK-optimized hash function with sponge construction
- **Poseidon**: Zero-knowledge friendly hash for constraint systems
- **Sponge Abstraction**: Flexible interface for variable-length inputs

#### Polynomial Operations
- **NTT**: Fast Number Theoretic Transform for polynomial multiplication
- **Evaluation**: Efficient polynomial evaluation at points
- **Interpolation**: Fast polynomial interpolation
- **Zerofier Trees**: Optimized structures for constraint systems

#### Merkle Structures
- **Merkle Trees**: Efficient authentication with batch verification
- **MMR (Merkle Mountain Ranges)**: Append-only Merkle structures
- **Proof Generation**: Compact inclusion and exclusion proofs

#### Serialization
- **BFieldCodec**: Canonical encoding for proof system integration
- **Zero-Copy**: Efficient serialization without allocations

## 📦 Installation

```bash
go get github.com/dread-crypto/titan-crypt
```

## 🔧 Quick Start

### Basic Field Operations

```go
package main

import (
    "fmt"
    "github.com/dread-crypto/titan-crypt/pkg/titan-crypt/field"
)

func main() {
    // Create field elements
    a := field.New(42)
    b := field.New(17)
    
    // Perform operations
    sum := a.Add(b)        // 42 + 17 = 59
    product := a.Mul(b)    // 42 * 17 = 714
    inverse := a.Inv()     // 1 / 42
    
    fmt.Printf("Sum: %v\n", sum)
    fmt.Printf("Product: %v\n", product)
    fmt.Printf("Inverse: %v\n", inverse)
}
```

### Hashing with Tip5

```go
package main

import (
    "fmt"
    "github.com/dread-crypto/titan-crypt/pkg/titan-crypt/field"
    "github.com/dread-crypto/titan-crypt/pkg/titan-crypt/hash"
)

func main() {
    // Create hash input
    input := []field.Element{
        field.New(1),
        field.New(2),
        field.New(3),
    }
    
    // Hash with Tip5
    digest := hash.Tip5Hash(input)
    
    fmt.Printf("Tip5 Hash: %v\n", digest)
}
```

### Polynomial Operations

```go
package main

import (
    "fmt"
    "github.com/dread-crypto/titan-crypt/pkg/titan-crypt/field"
    "github.com/dread-crypto/titan-crypt/pkg/titan-crypt/polynomial"
)

func main() {
    // Create a polynomial: 3x^2 + 2x + 1
    coeffs := []field.Element{
        field.New(1), // constant term
        field.New(2), // x coefficient
        field.New(3), // x^2 coefficient
    }
    
    poly := polynomial.New(coeffs)
    
    // Evaluate at x = 5: 3(25) + 2(5) + 1 = 86
    point := field.New(5)
    result := poly.Evaluate(point)
    
    fmt.Printf("P(5) = %v\n", result)
}
```

### Merkle Trees

```go
package main

import (
    "fmt"
    "github.com/dread-crypto/titan-crypt/pkg/titan-crypt/field"
    "github.com/dread-crypto/titan-crypt/pkg/titan-crypt/merkle"
)

func main() {
    // Create leaf data
    leaves := [][]field.Element{
        {field.New(1), field.New(2)},
        {field.New(3), field.New(4)},
        {field.New(5), field.New(6)},
        {field.New(7), field.New(8)},
    }
    
    // Build Merkle tree
    tree := merkle.NewMerkleTree(leaves)
    root := tree.Root()
    
    // Generate inclusion proof
    proof := tree.Proof(1) // Proof for leaf at index 1
    
    fmt.Printf("Root: %v\n", root)
    fmt.Printf("Proof valid: %v\n", proof.Verify(root, leaves[1], 1))
}
```

## 📚 Documentation

### Package Structure

```
titan-crypt/
├── pkg/titan-crypt/
│   ├── field/          # Goldilocks field arithmetic
│   ├── xfield/         # Extension field operations
│   ├── hash/           # Tip5 and Poseidon hash functions
│   ├── polynomial/     # Polynomial operations and NTT
│   ├── merkle/         # Merkle trees and MMR
│   ├── ntt/            # Number Theoretic Transform
│   ├── sponge/         # Sponge construction
│   ├── bfieldcodec/    # Serialization codec
│   ├── zerofier/       # Zerofier tree structures
│   └── traits/         # Common interfaces and adapters
```

### Key Modules

- **field**: Core field arithmetic over Goldilocks prime
- **hash**: STARK-optimized hash functions (Tip5, Poseidon)
- **polynomial**: Fast polynomial operations with NTT
- **merkle**: Authentication structures for proof systems
- **ntt**: Number Theoretic Transform for FFT operations

## 🧪 Testing

```bash
# Run all tests
go test ./...

# Run tests with race detector
go test -race ./...

# Run benchmarks
go test -bench=. ./...

# Run property-based tests
go test -fuzz=. ./pkg/titan-crypt/field

# Generate coverage report
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out
```

## 🎯 Performance

Titan Crypt is optimized for performance in zero-knowledge proof systems:

| Operation | Performance | Notes |
|-----------|-------------|-------|
| Field Addition | ~1 ns | Constant time |
| Field Multiplication | ~2 ns | Montgomery arithmetic |
| Field Inversion | ~30 ns | Extended GCD |
| Tip5 Hash (16 elements) | ~500 ns | Optimized sponge |
| Poseidon Hash | ~300 ns | 8-round configuration |
| NTT (2^16) | ~50 ms | Radix-2 Cooley-Tukey |
| Merkle Proof Gen | ~10 µs | For 1M leaves |

*Benchmarks on AMD Ryzen 9 5900X, Go 1.21*

## 🔒 Security

Titan Crypt implements cryptographic primitives with security in mind:

- **Constant-Time Operations**: Field operations resist timing attacks
- **Comprehensive Testing**: Property-based tests verify correctness
- **Fuzzing**: Continuous fuzzing for edge cases
- **No Unsafe Code**: Pure Go implementation without unsafe pointers

**Note**: This library is designed for zero-knowledge proof systems, not general-purpose cryptography. Use established libraries (e.g., `crypto/aes`, `crypto/sha256`) for standard cryptographic needs.

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
# Clone the repository
git clone https://github.com/dread-crypto/titan-crypt.git
cd titan-crypt

# Run tests
go test ./...

# Run linter
golangci-lint run

# Run benchmarks
go test -bench=. -benchmem ./...
```

## 📋 Requirements

- Go 1.21 or higher
- No external dependencies for core functionality

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Projects

- **[Atlas VM](https://github.com/dread-crypto/atlas-vm)** - Zero-knowledge virtual machine using Titan Crypt
- **[dread-crypto](https://github.com/dread-crypto)** - Organization for privacy-preserving cryptographic tools

## 📖 References

- [Goldilocks Field](https://eprint.iacr.org/2022/1577.pdf) - Efficient prime field for STARKs
- [STARKs](https://eprint.iacr.org/2018/046.pdf) - Scalable Transparent Arguments of Knowledge
- [Poseidon Hash](https://eprint.iacr.org/2019/458.pdf) - ZK-friendly hash function
- [Fast Fourier Transform](https://en.wikipedia.org/wiki/Fast_Fourier_transform) - NTT foundations

## 🙏 Acknowledgments

Titan Crypt is built on well-established cryptographic research and optimized for practical use in zero-knowledge proof systems.

---

**Status**: Production Ready  
**Version**: 0.1.0  
**Last Updated**: November 2025  
**Maintainer**: dread-crypto organization
