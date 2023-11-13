.data
	// CONSTANTS

.bss
	// MEMORY DATA

.text
	MRS X9, CPACR_EL1			// Read EL1 Architectural Feature Access Control Register
	MOVZ X10, 0x0030, lsl #16	        // Set BITs 20 and 21
	ORR X9, X9, X10
	MSR CPACR_EL1, X9			// Write EL1 Architectural Feature Access Control Register


//---------------------- INITIALIZATION HERE ------------------------------------

//---------------------- END INITIALIZATION ------------------------------------

//---------------------- CODE HERE ------------------------------------

//---------------------- END CODE ------------------------------------

end:
infloop: B infloop
