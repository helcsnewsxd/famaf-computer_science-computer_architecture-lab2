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
