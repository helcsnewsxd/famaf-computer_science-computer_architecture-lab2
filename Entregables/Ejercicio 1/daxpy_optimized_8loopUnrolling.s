	.data
	N:       .dword 4096	// Number of elements in the vectors
	Alpha:   .dword 2      // scalar value
	
	.bss 
	X: .zero  32768        // vector X(4096)*8
	Y: .zero  32768        // Vector Y(4096)*8
        Z: .zero  32768        // Vector Y(4096)*8

	.arch armv8-a
	.text
	.align	2
	.global	main
	.type	main, %function
main:
.LFB6:
	.cfi_startproc
	stp	x29, x30, [sp, -16]!
	.cfi_def_cfa_offset 16
	.cfi_offset 29, -16
	.cfi_offset 30, -8
	mov	x29, sp
	mov	x1, 0
	mov	x0, 0
	bl	m5_dump_stats

	ldr     x0, N
    	ldr     x10, =Alpha
    	ldr     x2, =X
    	ldr     x3, =Y
	ldr     x4, =Z

//---------------------- CODE HERE ------------------------------------

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
	valX3 .req d7
	valY3 .req d8
	valZ3 .req d9
	valX4 .req d10
	valY4 .req d11
	valZ4 .req d12
	valX5 .req d13
	valY5 .req d14
	valZ5 .req d15
	valX6 .req d16
	valY6 .req d17
	valZ6 .req d18
	valX7 .req d19
	valY7 .req d20
	valZ7 .req d21
	valX8 .req d22
	valY8 .req d23
	valZ8 .req d24

	// Get alpha and convert to double value
	ldr alphaInt, [posAlpha]
	scvtf alpha, alphaInt

	// Principal loop
	// We want to have only one branch instruction for iteration. Then, we will consider first the store instruction
	b optimized_daxpy_loop_body // We go to the body of the loop

	optimized_daxpy_loop_store:
		// Store valZ
		stp valZ, valZ2, [posZ], 16
		stp valZ3, valZ4, [posZ], 16
		stp valZ5, valZ6, [posZ], 16
		stp valZ7, valZ8, [posZ], 16

	optimized_daxpy_loop_body:
		// We calculate the values and then (in the end of the body), check if it's ok the condition of the loop to store the values
		// Get valX, valY
		ldp valX, valX2, [posX], 16
		ldp valX3, valX4, [posX], 16
		ldp valX5, valX6, [posX], 16
		ldp valX7, valX8, [posX], 16

		ldp valY, valY2, [posY], 16
		ldp valY3, valY4, [posY], 16
		ldp valY5, valY6, [posY], 16
		ldp valY7, valY8, [posY], 16

		// Compute valZ = alpha*valX + valY
		fmadd valZ, alpha, valX, valY
		fmadd valZ2, alpha, valX2, valY2
		fmadd valZ3, alpha, valX3, valY3
		fmadd valZ4, alpha, valX4, valY4
		fmadd valZ5, alpha, valX5, valY5
		fmadd valZ6, alpha, valX6, valY6
		fmadd valZ7, alpha, valX7, valY7
		fmadd valZ8, alpha, valX8, valY8

		// Decrease the counter
		subs n, n, 8
		
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
	.unreq valX3
	.unreq valY3
	.unreq valZ3
	.unreq valX4
	.unreq valY4
	.unreq valZ4
	.unreq valX5
	.unreq valY5
	.unreq valZ5
	.unreq valX6
	.unreq valY6
	.unreq valZ6
	.unreq valX7
	.unreq valY7
	.unreq valZ7
	.unreq valX8
	.unreq valY8
	.unreq valZ8

//---------------------- END CODE -------------------------------------

	mov 	x0, 0
	mov 	x1, 0
	bl	m5_dump_stats
	mov	w0, 0
	ldp	x29, x30, [sp], 16
	.cfi_restore 30
	.cfi_restore 29
	.cfi_def_cfa_offset 0
	ret
	.cfi_endproc
.LFE6:
	.size	main, .-main
	.ident	"GCC: (Ubuntu 9.4.0-1ubuntu1~20.04.1) 9.4.0"
	.section	.note.GNU-stack,"",@progbits
