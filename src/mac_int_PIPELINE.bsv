// Package definition
package mac_int_PIPELINE;		
import adder_int::*;      // Import adder module
import multiplier_int::*; // Import multiplier module 

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
module mkMAC_int_pipelined(MAC_int_ifc);
	// Instantiate the adder and multiplier interfaces
	RCA_ifc rca <- mkRipplecarryadder;  // Ensure adder supports signed arithmetic
	Mult_ifc mul <- mkMult;             // Ensure multiplier supports signed multiplication

	// Register declarations
	Reg#(Int#(8)) regA_stage1 <- mkReg(0);
	Reg#(Int#(8)) regB_stage1 <- mkReg(0);
	Reg#(Int#(32)) regC_stage1 <- mkReg(0);

	Reg#(Int#(32)) product_stage2 <- mkReg(0);
	Reg#(Bool) rg_sent_inputs_stage2 <- mkReg(False);
	Reg#(Bool) rg_add_complete_stage3 <- mkReg(False);

	Reg#(Int#(32)) macOut_stage4 <- mkReg(0);

	// --- Rule Declarations --- //

	// Rule to start the MAC operation by storing inputs in stage 1
	rule rl_startMAC;
		// Move inputs to stage 1 registers
		rg_sent_inputs_stage2 <= False;  // Reset flag
		rg_add_complete_stage3 <= False; // Reset flag
		regA_stage1 <= 0; // Initialize for first operation
		regB_stage1 <= 0; // Initialize for first operation
		regC_stage1 <= 0; // Initialize for first operation
	endrule: rl_startMAC

	// Rule to receive inputs
	rule rl_receiveInputs;
		// Example control signal to indicate that inputs can be received
		if (!rg_sent_inputs_stage2) begin
			regA_stage1 <= regA_stage1; // Load input A
			regB_stage1 <= regB_stage1; // Load input B
			regC_stage1 <= regC_stage1; // Load input C
			rg_sent_inputs_stage2 <= True; // Mark inputs as sent
		end
	endrule: rl_receiveInputs

	// Rule to initiate multiplication (stage 2)
	rule rl_startMultiply (rg_sent_inputs_stage2);
		GetMulInp mulinp = GetMulInp{a: regA_stage1, b: regB_stage1};
		mul.get_Inputs(mulinp);
		product_stage2 <= signExtend(mul.get_Mul); // Store the product
	endrule: rl_startMultiply

	// Rule to add the multiplication result to C (stage 3)
	rule rl_intermediateMAC (rg_sent_inputs_stage2);
		if (rg_sent_inputs_stage2) begin
			rca.start(product_stage2, regC_stage1); // Start the adder
			rg_sent_inputs_stage2 <= False; // Reset input sent flag
			rg_add_complete_stage3 <= True;  // Mark addition as complete
		end
	endrule: rl_intermediateMAC

	// Rule to retrieve the result from the adder (stage 4)
	rule rl_getMAC (rg_add_complete_stage3);
		macOut_stage4 <= rca.get_add().sum; // Get the final output from the adder
		rg_add_complete_stage3 <= False;     // Reset addition complete flag
	endrule: rl_getMAC

	// --- Method Declarations --- //

	// Method to get inputs
	method Action get_IntInputs(MACinputsint inputs);
		regA_stage1 <= inputs.a;
		regB_stage1 <= inputs.b;
		regC_stage1 <= inputs.c;
	endmethod: get_IntInputs

	// Method to return output
	method Int#(32) get_MACint();
		return macOut_stage4; // Return the output from the final stage
	endmethod: get_MACint

endmodule: mkMAC_int_pipelined

endpackage: mac_int_PIPELINE

