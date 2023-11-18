.data
	N:       .dword 4	// Number of elements in the vectors
	Alpha:   .dword 2      // scalar value

	// Double values - FOR INIT
	X_init:  .double 2, 2.5, 3, 3.5
	Y_init:  .double 9.5, 8.5, 7.5, 6.5

.bss
	X: .zero  32768        // vector X(4096)*8
	Y: .zero  32768        // Vector Y(4096)*8
        Z: .zero  32768        // Vector Y(4096)*8

.text
	MRS X9, CPACR_EL1			// Read EL1 Architectural Feature Access Control Register
	MOVZ X10, 0x0030, lsl #16	        // Set BITs 20 and 21
	ORR X9, X9, X10
	MSR CPACR_EL1, X9			// Write EL1 Architectural Feature Access Control Register

// ==================== MAIN ====================

main:
	// Init memory
	bl initRegisters
	bl initMemory

	// Call daxpy
	bl initRegisters
	// bl daxpy
	bl optimized_daxpy

	// Infinite loop
	bl initRegisters
	bl infloop

// ===============================================

// ==================== AUXILIAR FUNCTIONS =====================

initRegisters:
	ldr     x0, N
    	ldr     x10, =Alpha
    	ldr     x2, =X
    	ldr     x3, =Y
	ldr     x4, =Z

	ret

initMemory:
	// Get register alias
	n .req x0
	i .req x1
	posX .req x2
	posY .req x3
	posInitX .req x4
	posInitY .req x5
	value .req d0

	// Init registers
	mov n, 4
	ldr posInitX, =X_init
	ldr posInitY, =Y_init

	// init X loop
	mov i, 0
	initMemory_xloop:
		// Loop condition
		cmp i, n
		b.ge initMemory_xloop_end

		// Loop body
		// Get the init value
		ldr value, [posInitX]

		// Store the init value
		str value, [posX]

		// Update pointers
		add posX, posX, 8
		add posInitX, posInitX, 8

		// Update loop counter
		add i, i, 1

		// Loop back
		b initMemory_xloop

	initMemory_xloop_end:

	// init Y loop
	mov i, 0
	initMemory_yloop:
		// Loop condition
		cmp i, n
		b.ge initMemory_yloop_end

		// Loop body
		// Get the init value
		ldr value, [posInitY]

		// Store the init value
		str value, [posY]

		// Update pointers
		add posY, posY, 8
		add posInitY, posInitY, 8

		// Update loop counter
		add i, i, 1

		// Loop back
		b initMemory_yloop

	initMemory_yloop_end:

	// Remove register alias
	.unreq n
	.unreq i
	.unreq posX
	.unreq posY
	.unreq posInitX
	.unreq posInitY
	.unreq value

	ret

daxpy:
	// Get register alias
	n .req x0
	i .req x1
	posX .req x2
	posY .req x3
	posZ .req x4
	posAlpha .req x10
	alphaInt .req x11
	alpha .req d0
	valX .req d1
	valY .req d2
	valZ .req d3

	// Get alpha and convert to double value
	ldr alphaInt, [posAlpha]
	scvtf alpha, alphaInt

	// Principal loop
	mov i, 0
	daxpy_loop:
		// Loop condition to exit
		cmp i, n
		b.ge daxpy_end_loop

		// Loop body
		// Get valX, valY
		ldr valX, [posX]
		ldr valY, [posY]

		// Compute valZ = alpha*valX + valY
		fmul valZ, alpha, valX
		fadd valZ, valZ, valY

		// Store valZ
		str valZ, [posZ]

		// Update pointers
		add posX, posX, 8
		add posY, posY, 8
		add posZ, posZ, 8

		// Update loop counter
		add i, i, 1

		// Loop back
		b daxpy_loop

	daxpy_end_loop:

	// Remove register alias
	.unreq n
	.unreq i
	.unreq posX
	.unreq posY
	.unreq posZ
	.unreq posAlpha
	.unreq alphaInt
	.unreq alpha
	.unreq valX
	.unreq valY
	.unreq valZ

	ret

optimized_daxpy:
	// Get register alias
	n .req x0
	posX .req x2
	posY .req x3
	posZ .req x4
	posAlpha .req x10
	alphaInt .req x11
	alpha .req d0
	valX .req d1
	valY .req d2
	valZ .req d3
	valX2 .req d4
	valY2 .req d5
	valZ2 .req d6

	// Get alpha and convert to double value
	ldr alphaInt, [posAlpha]
	scvtf alpha, alphaInt

	// Principal loop
	// We want to have only one branch instruction for iteration. Then, we will consider first the store instruction
	b optimized_daxpy_loop_body // We go to the body of the loop

	optimized_daxpy_loop_store:
		// Store valZ
		stp valZ, valZ2, [posZ], 16

	optimized_daxpy_loop_body:
		// We calculate the values and then (in the end of the body), check if it's ok the condition of the loop to store the values
		// Get valX, valY
		ldp valX, valX2, [posX], 16
		ldp valY, valY2, [posY], 16

		// Compute valZ = alpha*valX + valY
		fmadd valZ, alpha, valX, valY
		fmadd valZ2, alpha, valX2, valY2

		// Decrease the counter
		subs n, n, 2
		
		// If n >= 0, we go to the store instruction
		b.ge optimized_daxpy_loop_store

	// Remove register alias
	.unreq n
	.unreq posX
	.unreq posY
	.unreq posZ
	.unreq posAlpha
	.unreq alphaInt
	.unreq alpha
	.unreq valX
	.unreq valY
	.unreq valZ
	.unreq valX2
	.unreq valY2
	.unreq valZ2

	ret

infloop:
	B infloop

// =============================================================
