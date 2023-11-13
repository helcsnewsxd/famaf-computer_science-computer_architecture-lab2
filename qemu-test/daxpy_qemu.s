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

	ldr     x0, N
    	ldr     x10, =Alpha
    	ldr     x2, =X
    	ldr     x3, =Y
	ldr     x4, =Z

//---------------------- INITIALIZATION HERE ------------------------------------

	// Alpha = 2
	// X = [2, 2.5, 3, 3.5]
	ldr     x5, =X_init

	ldr d0, [x5]
	str d0, [x2]

	ldr d0, [x5, #8]
	str d0, [x2, #8]

	ldr d0, [x5, #16]
	str d0, [x2, #16]

	ldr d0, [x5, #24]
	str d0, [x2, #24]

	// Y = [9.5, 8.5, 7.5, 6.5]
	ldr     x6, =Y_init

	ldr d0, [x6]
	str d0, [x3]

	ldr d0, [x6, #8]
	str d0, [x3, #8]

	ldr d0, [x6, #16]
	str d0, [x3, #16]

	ldr d0, [x6, #24]
	str d0, [x3, #24]

	// Z = [0, 0, 0, 0]
	ldr     x7, =Z

	fsub d0, d0, d0
	
	str d0, [x4]
	str d0, [x4, #8]
	str d0, [x4, #16]
	str d0, [x4, #24]

//---------------------- END INITIALIZATION ------------------------------------

//---------------------- CODE HERE ------------------------------------

	// Convert Alpha to Double
	ldr 	x11, [x10]
	scvtf 	d0, x11

	// Alias for registers
	n .req x0
	i .req x1
	posX .req x2
	posY .req x3
	posZ .req x4
	alpha .req d0
	valX .req d1
	valY .req d2
	valZ .req d3

	// Principal loop
	mov 	i, 0
	loop:
		// Check condition
		cmp i, n
		bge end_loop

		// Read x, y values
		ldr 	valX, [posX, #0]
		ldr 	valY, [posY, #0]

		// Calculate value ==> Z[i] = alpha * X[i] + Y[i]
		fmul 	valZ, valX, alpha
		fadd 	valZ, valZ, valY

		// Store value
		str 	valZ, [posZ, #0]

		// Increment i and positions
		add 	i, i, 1
		add 	posX, posX, 8
		add 	posY, posY, 8
		add 	posZ, posZ, 8

		b loop

	end_loop:

	// Remove alias
	.unreq n
	.unreq i
	.unreq posX
	.unreq posY
	.unreq posZ
	.unreq alpha
	.unreq valX
	.unreq valY
	.unreq valZ

//---------------------- END CODE ------------------------------------

end:
infloop: B infloop
