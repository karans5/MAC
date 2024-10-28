//package definition
package mac_int;		
import adder_int::*;//import adder module
import multiplier_int::*;// import multiplier module

//input struct declaration
typedef struct {
	Bit#(8) a;
	Bit#(8) b;
	Bit#(32) c;
	} MACinputsint deriving(Bits,Eq);


// interface declaration for 
interface MAC_int_ifc;
//	method Action get_A(Bit#(8) value);
//	method Action get_B(Bit#(8) value);
//	method Action get_C(Bit#(32) value);
	method Action get_IntInputs(MACinputsint inputs);
    method Bit#(32) get_MACint();	
endinterface: MAC_int_ifc

(*synthesize*)
module mkMAC_int(MAC_int_ifc);
	//instantiating adder interface and binding to adder module
	RCA_ifc rca <- mkRipplecarryadder;
	//instantiating multiplier interface and binfing it to multiplier module
	Mult_ifc mul <- mkMult;

	//Register declarations
	Reg#(Bit#(8)) regA <- mkReg(0);
	Reg#(Bit#(8)) regB <- mkReg(0);
	Reg#(Bit#(32)) regC <- mkReg(0);
	Reg#(Bit#(32)) macOut <- mkReg(0);
	Reg#(Bool) rg_sent_inputs <- mkReg(False);
	Reg#(Bool) rg_add_complete <- mkReg(False);
	
	//---rule declarations---//

	// Rule to start the MAC operation by initiating the adder
	rule rl_startMAC;
    		GetMulInp mulinp = GetMulInp{a: regA, b: regB};
    		mul.get_Inputs(mulinp);
			rg_sent_inputs <= True;
	endrule: rl_startMAC

	// Rule to get multiplication result and send it the adder module
	rule rl_intermediateMAC(rg_sent_inputs);
    		// Get the product from the multiplier and extend it to 32 bits
    		Bit#(32) product = zeroExtend(mul.get_Mul);
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

	//---method declarations---//

	//method to get inputs
	method Action get_IntInputs(MACinputsint inputs);
		regA <=  inputs.a;
		regB <=  inputs.b;
		regC <=  inputs.c;
	endmethod: get_IntInputs

	//method to return output
	method Bit#(32) get_MACint();
		return macOut;
	endmethod: get_MACint

endmodule: mkMAC_int


endpackage: mac_int
