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
