	.data
	Array: .dword 0x64, 0xc8, 0x12c
	contenido_X0: .dword 0xA
	.text
	LDR X6, =Array
	LDR X0, contenido_X0
    	MRS X9, CPACR_EL1			// Read EL1 Architectural Feature Access Control Register
	MOVZ X10, 0x0030, lsl #16	        // Set BITs 20 and 21
	ORR X9, X9, X10
	MSR CPACR_EL1, X9			// Write EL1 Architectural Feature Access Control Register

	ADD X9, X6, #8
    	ADD  X10, X6, XZR
    	STUR X10, [X9, #0]
    	LDUR X9, [X9, #0]
    	ADD  X0, X9, X10

end:
infloop: B infloop
