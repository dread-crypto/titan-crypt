// Package field provides primitive roots of unity for NTT operations.
package field

import (
	"fmt"
)

// PrimitiveRoots contains precomputed primitive roots of unity.
// These are equivalent to twenty-first's PRIMITIVE_ROOTS map.
var PrimitiveRoots = map[uint64]uint64{
	0:          1,
	1:          1,
	2:          18446744069414584320,
	4:          281474976710656,
	8:          18446744069397807105,
	16:         17293822564807737345,
	32:         70368744161280,
	64:         549755813888,
	128:        17870292113338400769,
	256:        13797081185216407910,
	512:        1803076106186727246,
	1024:       11353340290879379826,
	2048:       455906449640507599,
	4096:       17492915097719143606,
	8192:       1532612707718625687,
	16384:      16207902636198568418,
	32768:      17776499369601055404,
	65536:      6115771955107415310,
	131072:     12380578893860276750,
	262144:     9306717745644682924,
	524288:     18146160046829613826,
	1048576:    3511170319078647661,
	2097152:    17654865857378133588,
	4194304:    5416168637041100469,
	8388608:    16905767614792059275,
	16777216:   9713644485405565297,
	33554432:   5456943929260765144,
	67108864:   17096174751763063430,
	134217728:  1213594585890690845,
	268435456:  6414415596519834757,
	536870912:  16116352524544190054,
	1073741824: 9123114210336311365,
	2147483648: 4614640910117430873,
	4294967296: 1753635133440165772,
}

// GetPrimitiveRoot returns the primitive root of unity for the given order.
// The order must be a power of 2.
func GetPrimitiveRoot(order uint64) (Element, error) {
	if order == 0 {
		return Zero, fmt.Errorf("order cannot be zero")
	}

	// Check if order is a power of 2
	if order&(order-1) != 0 {
		return Zero, fmt.Errorf("order must be a power of 2, got %d", order)
	}

	// Check if we have the primitive root for this order
	if root, exists := PrimitiveRoots[order]; exists {
		return NewFromRaw(root), nil
	}

	return Zero, fmt.Errorf("primitive root not found for order %d", order)
}

// PrimitiveRootOfUnity returns the primitive root of unity for the given order.
// Returns Zero if not found. This is a convenience wrapper around GetPrimitiveRoot.
// This is equivalent to twenty-first's BFieldElement::primitive_root_of_unity().
func PrimitiveRootOfUnity(order uint64) Element {
	root, err := GetPrimitiveRoot(order)
	if err != nil {
		return Zero
	}
	return root
}

// IsPrimitiveRootOfUnity checks if the given element is a primitive root of unity of the given order.
func IsPrimitiveRootOfUnity(element Element, order uint64) bool {
	if order == 0 {
		return false
	}

	// Check if order is a power of 2
	if order&(order-1) != 0 {
		return false
	}

	// A primitive root of unity of order n satisfies:
	// 1. element^n ≡ 1 (mod P)
	// 2. element^(n/2) ≢ 1 (mod P) for all proper divisors of n

	// Check condition 1: element^n ≡ 1
	if !element.ModPow(order).Equal(One) {
		return false
	}

	// Check condition 2: element^(n/2) ≢ 1 for all proper divisors
	// We only need to check the largest proper divisor: n/2
	if order > 1 {
		halfOrder := order / 2
		if element.ModPow(halfOrder).Equal(One) {
			return false
		}
	}

	return true
}

// GeneratePrimitiveRoot generates a primitive root of unity for the given order.
// This is a more expensive operation and should be used sparingly.
func GeneratePrimitiveRoot(order uint64) (Element, error) {
	if order == 0 {
		return Zero, fmt.Errorf("order cannot be zero")
	}

	// Check if order is a power of 2
	if order&(order-1) != 0 {
		return Zero, fmt.Errorf("order must be a power of 2, got %d", order)
	}

	// For small orders, we can use the precomputed values
	if root, exists := PrimitiveRoots[order]; exists {
		return NewFromRaw(root), nil
	}

	// For larger orders, we need to generate them
	// This is a complex operation that requires finding a generator
	// of the multiplicative group of the field

	// For now, return an error for unsupported orders
	return Zero, fmt.Errorf("primitive root generation not implemented for order %d", order)
}

// GetInversePrimitiveRoot returns the inverse of the primitive root of unity.
func GetInversePrimitiveRoot(order uint64) (Element, error) {
	root, err := GetPrimitiveRoot(order)
	if err != nil {
		return Zero, err
	}

	return root.Inverse(), nil
}

// GetNthRootOfUnity returns the n-th root of unity for the given order.
func GetNthRootOfUnity(order uint64, n uint64) (Element, error) {
	if n >= order {
		return Zero, fmt.Errorf("n must be less than order")
	}

	root, err := GetPrimitiveRoot(order)
	if err != nil {
		return Zero, err
	}

	return root.ModPow(n), nil
}

// GetInverseNthRootOfUnity returns the inverse of the n-th root of unity.
func GetInverseNthRootOfUnity(order uint64, n uint64) (Element, error) {
	root, err := GetNthRootOfUnity(order, n)
	if err != nil {
		return Zero, err
	}

	return root.Inverse(), nil
}
