.data
	N:       .dword 3	
	t_amb:   .dword 25   
	n_iter:  .dword 10    
	fc_temp: .dword 1000
	fc_x:    .dword 1
	fc_y:    .dword 1

.bss
	x: .zero 32768
	x_temp: .zero 32768

.text
	MRS X9, CPACR_EL1			// Read EL1 Architectural Feature Access Control Register
	MOVZ X10, 0x0030, lsl #16	        // Set BITs 20 and 21
	ORR X9, X9, X10
	MSR CPACR_EL1, X9			// Write EL1 Architectural Feature Access Control Register

// ==================== MAIN ====================

main:
	// Init memory
	bl initRegisters

	// Call simFisica
	bl initRegisters
	bl simFisica

	// Infinite loop
	bl initRegisters
	bl infloop

// ===============================================

// ==================== AUXILIAR FUNCTIONS =====================

initRegisters:
	ldr     x0, N
    ldr     x1, =x 
    ldr     x2, =x_temp
    ldr     x3, n_iter
	ldr     x4, t_amb
	ldr     x5, fc_temp
	ldr     x6, fc_x
	ldr     x7, fc_y

	ret

simFisica:
	// Get alias
	n .req x0
	posX .req x1
	xTemp .req x2
	nIter .req x3
	tempAmbINT .req x4
	tempAmb .req d0
	fcTempINT .req x5
	fcTemp .req d1
	fcX .req x6
	fcY .req x7
	nPow2 .req x8
	posHeatSource .req x9
	i .req x10
	k .req x11
	j .req x12
	actPos .req x13
	sum .req d2
	valOf4 .req d3
	auxVal .req d5
	auxPos .req x14

	// Convert ints to floats
	scvtf tempAmb, tempAmbINT
	scvtf fcTemp, fcTempINT

	// Load valOf4
	fmov valOf4, 4.0

	// Calculate nPow2
	mul nPow2, n, n

	// Calculate position of heat source
	madd posHeatSource, fcX, n, fcY

	// Init memory
	mov i, 0
	simFisica_init_loop:
		cmp i, nPow2
		bge simFisica_init_loop_end

		str tempAmb, [posX, i, lsl #3]

		add i, i, 1
		b simFisica_init_loop

	simFisica_init_loop_end:
	
	str fcTemp, [posX, posHeatSource, lsl #3]

	// Simulate physics
	// For each iteration
	mov k, 0
	simFisica_k_loop:
		cmp k, nIter
		bge simFisica_k_loop_end

		// For each row
		mov i, 0
		simFisica_i_loop:
			cmp i, n
			bge simFisica_i_loop_end

			// For each column
			mov j, 0
			simFisica_j_loop:
				cmp j, n
				bge simFisica_j_loop_end

				// Calculate actual position
				madd actPos, i, n, j

				// Principal if condition (position is not the heat source)
				cmp actPos, posHeatSource
				beq simFisica_j_loop_position_not_heat_source_end
				simFisica_j_loop_position_not_heat_source:
					// Reset sum value
					fsub sum, sum, sum

					// Add value of the down position
					// sum += i+1 < n ? x[(i+1)*n+j] : tempAmb; ==> sum += i+1 < n ? x[actPos+n] : tempAmb;
					add auxPos, actPos, n
					ldr auxVal, [posX, auxPos, lsl #3]

					add auxPos, i, 1
					cmp auxPos, n
					fcsel auxVal, auxVal, tempAmb, lt

					add sum, sum, auxVal

					// Add value of the up position
					// sum += i-1 >= 0 ? x[(i-1)*n+j] : tempAmb; ==> sum += i-1 >= 0 ? x[actPos-n] : tempAmb;
					sub auxPos, actPos, n
					ldr auxVal, [posX, auxPos, lsl #3]

					cmp i, 0
					fcsel auxVal, auxVal, tempAmb, gt

					add sum, sum, auxVal

					// Add value of the right position
					// sum += j+1 < n ? x[i*n+(j+1)] : tempAmb; ==> sum += j+1 < n ? x[actPos+1] : tempAmb;
					add auxPos, actPos, 1
					ldr auxVal, [posX, auxPos, lsl #3]

					add auxPos, j, 1
					cmp auxPos, n
					fcsel auxVal, auxVal, tempAmb, lt

					add sum, sum, auxVal

					// Add value of the left position
					// sum += j-1 >= 0 ? x[i*n+(j-1)] : tempAmb; ==> sum += j-1 >= 0 ? x[actPos-1] : tempAmb;
					sub auxPos, actPos, 1
					ldr auxVal, [posX, auxPos, lsl #3]

					cmp j, 0
					fcsel auxVal, auxVal, tempAmb, gt

					add sum, sum, auxVal

					// Calculate new value of the actual position and store it
					fdiv sum, sum, valOf4
					str sum, [xTemp, actPos, lsl #3]

				simFisica_j_loop_position_not_heat_source_end:

				add j, j, 1
				b simFisica_j_loop
			simFisica_j_loop_end:

			add i, i, 1
			b simFisica_i_loop
		simFisica_i_loop_end:

		add k, k, 1
		b simFisica_k_loop
	simFisica_k_loop_end:

	// Copy xTemp to x for all positions except the heat source
	mov i, 0
	simFisica_copy_loop:
		cmp i, nPow2
		bge simFisica_copy_loop_end

		cmp i, posHeatSource
		beq simFisica_copy_loop_position_heat_source_end
		simFisica_copy_loop_position_not_heat_source:
			ldr auxVal, [xTemp, i, lsl #3]
			str auxVal, [posX, i, lsl #3]

		simFisica_copy_loop_position_heat_source_end:

		add i, i, 1
		b simFisica_copy_loop
	simFisica_copy_loop_end:

	// Remove alias
	.unreq n
	.unreq posX
	.unreq xTemp
	.unreq nIter
	.unreq tempAmbINT
	.unreq tempAmb
	.unreq fcTempINT
	.unreq fcTemp
	.unreq fcX
	.unreq fcY
	.unreq nPow2
	.unreq posHeatSource
	.unreq i
	.unreq k
	.unreq j
	.unreq actPos
	.unreq sum
	.unreq valOf4
	.unreq auxVal
	.unreq auxPos

	ret

infloop:
	B infloop

// =============================================================
