package adder;
import DReg :: *;


typedef struct{
		Bit#(1) overflow;
		Bit#(32) sum;
		} Adderresult deriving(Bits,Eq);
//ripple carry adder interface
interface RCA_ifc;
	method Action start(Bit#(32) a, Bit#(32) b);
	method Adderresult get_result();
endinterface: RCA_ifc

//top-level module definition
(*synthesize*)

module mkRipplecarryadder (RCA_ifc);

//declare the registers used in the design

Reg#(Bit#(32)) rg_inp1     <- mkReg(0);
Reg#(Bit#(32)) rg_inp2     <- mkReg(0);
Reg#(Bool) rg_inp_valid    <- mkDReg(False);

Reg#(Adderresult) rg_out   <- mkReg(Adderresult{overflow: 0,
				     sum: 0});
				     
Reg#(Bool) rg_out_valid     <-mkDReg(False);

function Adderresult ripple_carry_addition(Bit#(32) a,
                                           Bit#(32) b,
                                           Bit#(1) cin);
    
    Bit#(32) sum;
    Bit#(33) carry;

    carry[0] = cin;			
    
    for (Integer i = 0; i < 32; i = i + 1) begin
        sum[i] = a[i] ^ b[i] ^ carry[i];
        carry[i + 1] = (a[i] & b[i]) | ((a[i] ^ b[i]) & carry[i]);
    end			

    Adderresult out;
    out.sum = sum;
    out.overflow = carry[33];

    return out;			
endfunction: ripple_carry_addition

//rule definitions

rule rl_rca;
	rg_out <= ripple_carry_addition(rg_inp1, rg_inp2, 1'b0);
	rg_out_valid <= True;
	
endrule: rl_rca


//method definitions

method Action start( Bit#(32) a, Bit#(32) b);
	rg_inp1 <= a;
	rg_inp2 <= b;
	
endmethod: start

method Adderresult get_result();
	return rg_out;
endmethod: get_result
endmodule: mkRipplecarryadder

endpackage

