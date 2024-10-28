package mac;
import mac_int::*;
import mac_fp::*;


//interface declaration for MAC top module
interface MAC_ifc;
	method Action get_A(Bit#(16) value);
	method Action get_B(Bit#(16) value);
	method Action get_C(Bit#(32) value);
	method Action set_S1_or_S2(Bit#(1) mode);
	method Bit#(32) get_MAC();
endinterface: MAC_ifc

(*synthesize*)
module mkMac (MAC_ifc);

	// module interface instantiation and binding
	MAC_int_ifc macint <- mkMAC_int;
	MAC_fp_ifc macfp <- mkMAC_fp;

	// Register declarations
	Reg#(Bit#(16)) regA <- mkReg(0);
	Reg#(Bit#(16)) regB <- mkReg(0);
	Reg#(Bit#(32)) regC <- mkReg(0);
	Reg#(Bit#(1)) select <- mkReg(0);

	rule rl_mac_int (select == 0);
		// Create temporary variables for 8-bit slices of regA and regB
		let tempA = regA[7:0];
		let tempB = regB[7:0];
		// Instantiate the MACinputs struct with the temporary variables and regC
		MACinputsint inputsint = MACinputsint{a:tempA,b:tempB,c:regC};
		// Call the get_Inputs method on the MAC interface
		macint.get_IntInputs(inputsint);
	endrule

	rule rl_mac_fp(select == 1);
		// Instantiate the MACinputs struct with regA, regB and regC
		MACinputsfp inputsfp = MACinputsfp{a:regA, b:regB, c:regC};
		// Call the get_Inputs method on the MAC interface
		macfp.get_FpInputs(inputsfp);
	endrule

	// method to get value A
	method Action get_A(Bit#(16) value);
		regA <= value;
	endmethod: get_A

	// method to get value B
	method Action get_B(Bit#(16) value);
		regB <= value;
	endmethod: get_B

	// method to get value C
	method Action get_C(Bit#(32) value);
		regC <= value;
	endmethod: get_C

	// method to get mode of operation
	method Action set_S1_or_S2(Bit#(1) mode);
		select <= mode;
	endmethod: set_S1_or_S2

	// method to return 32 bit output
	method Bit#(32) get_MAC();
		if (select == 0)
			return macint.get_MACint;
		else
			return macfp.get_MACfp;

	endmethod: get_MAC

endmodule: mkMac

endpackage : mac
