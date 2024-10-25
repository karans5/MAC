//package definition
package mac_int;		
import adder::*;//import adder module
import multiplier::*;// import multiplier module

//input struct declaration
typedef struct {
	Bit#(8) a;
	Bit#(8) b;
	Bit#(32) c;
	} MACinputs deriving(Bits,Eq);


// interface declaration for 
interface MAC_int_ifc;
//	method Action get_A(Bit#(8) value);
//	method Action get_B(Bit#(8) value);
//	method Action get_C(Bit#(32) value);
	method Action get_Inputs(MACinputs input);
        method Bit#(32) get_MAC();	
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

	//---rule declarations---//

	//rule to perform mac
	//call multiplier module to perform multiply operation 
	//store th product in temp variable
	//the use the product as input to a method of adder module 
	// store the result in another varible
	rule rl_performMAC;
		mul.put_x(regA);
		mul.put_y(regB);
		Bit#(32) product = zeroExtend(mul.get_z);
		rca.start(product, regC);
		macOut <= rca.get_result();
	endrule	


	//---method declarations---//

	//method to get inputs
	method Action get_Inputs(MACinputs input);
		regA <=  input.a;
		regB <=  input.b;
		regC <=  input.c;
	end

	//method to return output
	method Bit#(32) get_MAC();
		return result;
	endmethod

endmodule: mkMAC_int


endpackage: mac_int
