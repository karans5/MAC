package mac;

//interface declaration for MAC top module
interface MAC_ifc;
	method Action get_A(Bit#(16) value);
	method Action get_B(Bit#(16) value);
	method Action get_C(Bit#(16) value);
	method Action set_S1_or_S2(Bit#(1) mode);
	method Action get_MAC();
endinterface: MAC_ifc

(*synthesize*)
module mkMac (MAC_ifc);

	Reg#(Bit#(16)) regA <- mkReg(0);
	Reg#(Bit#(16)) regB <- mkReg(0);
	Reg#(Bit#(16)) regC <- mkReg(0);
	Reg#(Bit#(1)) select <- mkReg(0);

	rule mac_int(select=0);
		tempA <= regA[7:0];
		tempB <= regB[7:0];
		mac_in32.performMAC(tempA, tempB, regC);
	endrule

	rule mac_fp(select=1);
		tempA <= regA;
		tempB <= regB;
		mac_fp.performMAC(tempA, tempB, regC);
	endrule

	method Action get_A(Bit#(16) value);
		regA <= value;
	endmethod: get_A

	method Action get_B(Bit#(16) value);
		regB <= value;
	endmethod: get_B

	method Action get_C(Bit#(16) value);
		regC <= value;
	endmethod: get_C

	method Action set_S1_or_S2(Bool mode);
		select <= mode;
	endmethod: set_S1_or_S2

	method Action get_MAC();

	endmethod: get_MAC

endmodule: mkMac

endpackage 
