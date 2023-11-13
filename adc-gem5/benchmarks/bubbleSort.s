	.text
	N:       .dword 1024	// Number of elements in the vectors
	
	.bss 
	Array: .zero  8192        // vector X(1000)*8

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

	// Initilize randomply the array
	ldr     x0, =Array	    // Load array base address to x0
	ldr     x6, N               // Load the number of elements into x2
    	mov     x1, 1234            // Set the seed value
	mov 	x5, 0		    // Set array counter to 0

    	// LCG parameters (adjust as needed)
    	movz    x2, 0x19, lsl 16    //1664525         // Multiplier
	movk	x2, 0x660D, lsl 0
    	movz    x3, 0x3C6E, lsl 16  // 1013904223      // Increment
	movk 	x3, 0xF35F, lsl 0
    	movz    x4, 0xFFFF, lsl 16      // Modulus (maximum value)
        movk    x4, 0xFFFF, lsl 0      // Modulus (maximum value)

random_array:
    	// Calculate the next pseudorandom value
    	mul     x1, x1, x2          // x1 = x1 * multiplier
    	add     x1, x1, x3          // x1 = x1 + increment
    	and     x1, x1, x4          // x1 = x1 % modulus

	str     x1, [x0]	    // Store the updated seed back to memory
	add 	x0, x0, 8	    // Increment array base address 
	add 	x5, x5, 1	    // Increment array counter 
	cmp	x5, x6		    // Verify if process ended
	b.lt	random_array

	mov	x1, 0
	mov	x0, 0
	bl	m5_dump_stats

    	ldr     x2, N
    	ldr     x1, =Array

//---------------------- CODE HERE ------------------------------------



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
