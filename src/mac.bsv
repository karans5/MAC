package mac;
//interface declaration for MAC top module
interface MAC_ifc;
	method Action get_A(Bit#(16) a);
	method Action get_B(Bit#(16) b);
	method Action get_C(Bit#(16) c);
	method Action set_S1_or_S2(Bool mode);
	method Action get_MAC();
endinterface: MAC_ifc

(*synthesize*)
module mkMac (MAC_ifc);

	Reg#(Bit#(16)) regA <- mkReg(0);
	Reg#(Bit#(16)) regB <- mkReg(0);
	Reg#(Bit#(16)) regC <- mkReg(0);
	Reg#(Bool) select <- mkReg(0);

	method Action get_A(Bit#(16) a);
		regA <= a;
	endmethod: get_A

	method Action get_B(Bit#(16) b);
		regB <= b;
	endmethod: get_B

	method Action get_C(Bit#(16) c);
		regC <= c;
	endmethod: get_C

	method Action set_S1_or_S2(Bool mode);
		select <= mode;
	endmethod: set_S1_or_S2

	method Action get_MAC();
	endmethod: get_MAC

endmodule: mkMac

endpackage 
