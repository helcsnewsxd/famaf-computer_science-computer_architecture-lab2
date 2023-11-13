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

	// Convert Alpha to Double
	ldr 	x11, [x10]
	scvtf 	d0, x11

	// Alias for registers
	n .req x0
	posX .req x2
	posY .req x3
	posZ .req x4
	alpha .req d0
	valX .req d1
	valY .req d2
	valZ .req d3
	valX2 .req d4
	valY2 .req d5
	valZ2 .req d6

	// Principal loop --> The condition is set before store to substract the branch control overhead
	// The first time that the loop is executed, we don't have to do the store		
	b loop_body

	// Do the store
	loop_store:
		stp 	valZ, valZ2, [posZ], #16

	loop_body:
		// --> We merge two iterations (loop unrolling)
		// Read x, y values
		ldp 	valX, valX2, [posX], #16
		ldp 	valY, valY2, [posY], #16

		// Calculate value ==> Z[i] = alpha * X[i] + Y[i]
		fmadd 	valZ, valX, alpha, valY
		fmadd 	valZ2, valX2, alpha, valY2

		// Check condition before store
		// The store is moved instructions before to reduce the number of branchs in every iteration
		// Now, we've only 1 branch every 2 iterations (instead of 2 branchs every 2 iterations)
		subs 	n, n, 2
		b.ge 	loop_store

	end_loop:

	// Remove alias
	.unreq n
	.unreq posX
	.unreq posY
	.unreq posZ
	.unreq alpha
	.unreq valX
	.unreq valY
	.unreq valZ
	.unreq valX2
	.unreq valY2
	.unreq valZ2

//---------------------- END CODE ------------------------------------

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
