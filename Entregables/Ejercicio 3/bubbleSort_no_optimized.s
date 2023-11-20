	.text
	N:       .dword 1000	// Number of elements in the vectors
	
	.bss 
	Array: .zero  8000        // vector X(1000)*8

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

	// Get alias
	arr .req x1
	n .req x2
	step .req x3
	i .req x4
	valArrI .req x5
	valArrIPlus1 .req x6
	aux .req x7
	aux2 .req x8
	limitIterations .req x9

	// Do the bubble sort
	mov step, 0
	bubbleSort_step_loop:
		// Condition to end the loop
		cmp step, n
		b.ge bubbleSort_step_loop_end

		// Body of the loop
		// Set the limit of iterations
		sub limitIterations, n, step
		sub limitIterations, limitIterations, 1

		// Do the loop to compare array elements
		mov i, 0
		bubbleSort_compare_loop:
			// Condition to end the loop
			cmp i, limitIterations
			b.ge bubbleSort_compare_loop_end

			// Body of the loop
			// Load arr[i] and arr[i+1]
			ldr valArrI, [arr, i, lsl 3]

			add aux2, i, 1
			ldr valArrIPlus1, [arr, aux2, lsl 3]

			// Compare two adjacent elements
			// If arr[i] > arr[i+1] then swap, else continue
			cmp valArrI, valArrIPlus1
			b.le bubbleSort_compare_loop_swap_if_end

			bubbleSort_compare_loop_swap_if:
				str valArrIPlus1, [arr, i, lsl 3]
				str valArrI, [arr, aux2, lsl 3]
			bubbleSort_compare_loop_swap_if_end:

			// Increment i
			add i, i, 1

			// Go to the next iteration
			b bubbleSort_compare_loop
		bubbleSort_compare_loop_end:

		// Increment step
		add step, step, 1
		
		// Go to the next iteration
		b bubbleSort_step_loop
	bubbleSort_step_loop_end:

	// Remove alias
	.unreq arr
	.unreq n
	.unreq step
	.unreq i
	.unreq valArrI
	.unreq valArrIPlus1
	.unreq aux
	.unreq aux2
	.unreq limitIterations

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
