// Package definition
package mac_int;		
import adder_int::*;      // Import adder module (must handle signed addition)
import multiplier_int::*; // Import multiplier module (must handle signed multiplication)

// Input struct declaration
typedef struct {
	Int#(8) a;   // Use Int#(8) for signed 8-bit input
	Int#(8) b;   // Use Int#(8) for signed 8-bit input
	Int#(32) c;  // Use Int#(32) for signed 32-bit input
} MACinputsint deriving (Bits, Eq);

// Interface declaration for the MAC module
interface MAC_int_ifc;
	method Action get_IntInputs(MACinputsint inputs);
    method Int#(32) get_MACint(); // Output method returns signed 32-bit result
endinterface: MAC_int_ifc

(*synthesize*)
module mkMAC_int(MAC_int_ifc);
	// Instantiate the adder and multiplier interfaces
	RCA_ifc rca <- mkRipplecarryadder;  // Ensure adder supports signed arithmetic
	Mult_ifc mul <- mkMult;             // Ensure multiplier supports signed multiplication

	// Register declarations
	Reg#(Int#(8)) regA <- mkReg(0);
	Reg#(Int#(8)) regB <- mkReg(0);
	Reg#(Int#(32)) regC <- mkReg(0);
	Reg#(Int#(32)) macOut <- mkReg(0);
	Reg#(Bool) rg_sent_inputs <- mkReg(False);
	Reg#(Bool) rg_add_complete <- mkReg(False);
	
	// --- Rule Declarations --- //

	// Rule to start the MAC operation by initiating the multiplier
	rule rl_startMAC;
		GetMulInp mulinp = GetMulInp{a: regA, b: regB};
		mul.get_Inputs(mulinp);
		rg_sent_inputs <= True;
	endrule: rl_startMAC

	// Rule to get multiplication result and send it to the adder module
	rule rl_intermediateMAC(rg_sent_inputs);
		// Get the product from the multiplier and sign-extend it to 32 bits
		Int#(32) product = signExtend(mul.get_Mul);
		// Start the ripple carry adder with the product and regC
		rca.start(product, regC);
		rg_sent_inputs <= False;
		rg_add_complete <= True;
	endrule: rl_intermediateMAC

	// Rule to retrieve the result from the adder and store it in macOut
	rule rl_getMAC (rg_add_complete);
		// Extract the sum from the Adderresult struct and assign it to macOut
		macOut <= rca.get_add().sum;
		rg_add_complete <= False;
	endrule: rl_getMAC

	// --- Method Declarations --- //

	// Method to get inputs
	method Action get_IntInputs(MACinputsint inputs);
		regA <= inputs.a;
		regB <= inputs.b;
		regC <= inputs.c;
	endmethod: get_IntInputs

	// Method to return output
	method Int#(32) get_MACint();
		return macOut;
	endmethod: get_MACint

endmodule: mkMAC_int

endpackage: mac_int
