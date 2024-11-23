package multiplier_fp_v3;
import DReg :: *;

//multiplier interface
interface FP_multiplier_ifc;
	method Action start(Bit#(16) a, Bit#(16) b);
	method Bit#(32) get_Product();
endinterface: FP_multiplier_ifc


//(*synthesize*)
module mkFP_multiplier(FP_multiplier_ifc);


//registers to store input and output
Reg#(Bit#(16)) rg_A     <- mkReg(0);
Reg#(Bit#(16)) rg_B     <- mkReg(0);

//input valid signal
Reg#(Bool) rg_inp_valid    <- mkDReg(False);

//register to store the product
Reg#(Bit#(32)) rg_Product <- mkReg(0);

//out_valid signal
Reg#(Bool) rg_Product_valid    <- mkDReg(False);

 function Bit#(32) fp_multiply(Bit#(16) inp_a, Bit#(16) inp_b);
    // Determine the sign of the result
    Bit#(1) sign = inp_a[15] ^ inp_b[15];

    // Extract exponent and mantissa
    Bit#(8) exp_a  = inp_a[14:7]; // Extract exponent
    Bit#(8) exp_b  = inp_b[14:7]; // Extract exponent


    // Include the implicit leading 1 for the mantissa
    Bit#(8) frac_a = (|inp_a[14:7] == 1'b1) ? {1'b1, inp_a[6:0]} : {1'b0, inp_a[6:0]};  // Implicit leading 1
    Bit#(8) frac_b = (|inp_b[14:7]==1'b1) ? {1'b1, inp_b[6:0]} : {1'b0, inp_b[6:0]};

    // Perform the multiplication (8-bit * 8-bit = 16-bit result)
    Bit#(16) frac_result = zeroExtend(frac_a) * zeroExtend(frac_b);
      //Bit#(16) frac_result = frac_a*frac_b;
      
      
    ///Normalization
    Bit#(1) normalized = (frac_result[15] == 1'b1)? 1'b1 : 1'b0; 

    // Normalize the result if necessary
   
    Bit#(16) normalized_frac= (normalized==1'b1) ? frac_result : frac_result >> 1;
    Bit#(8) exp_result = exp_a + exp_b - 8'd127; // Bias adjustment
    Bit#(1) rounding = |normalized_frac[6:0]; // last 7 bits are OR'ed to get the rounding bit
    Bit#(8) final_exp_result = exp_result + zeroExtend(normalized);
    
    
   
        
    Bit#(7) mantissa_result = normalized_frac[14:8] + zeroExtend(normalized_frac[7] & rounding);
    // Assemble final result in IEEE 754 FP32 format
    Bit#(23) final_mantissa_result = {mantissa_result[6:0], 16'b0}; 
    Bit#(32) result = {sign, final_exp_result, final_mantissa_result};
    return result;
endfunction

   
   
   //always block to compute the product
   rule rl_compute_product (rg_inp_valid);
     
   	$display("A = %b",rg_A);
   	$display("B = %b",rg_B);
   	
   	rg_Product <= fp_multiply(rg_A,rg_B);
   	rg_Product_valid <= True;
   	rg_inp_valid <= False;
   	$display("Pro = %b",rg_Product);
   	
   	
   endrule: rl_compute_product


     method Action start( Bit#(16) a, Bit#(16) b) if(!rg_inp_valid);
		rg_A <= a;
		rg_B <= b;
		rg_inp_valid <= True;
		rg_Product_valid <=False;
		
   endmethod: start

   method Bit#(32) get_Product() if (rg_Product_valid);   		
		return rg_Product;
   endmethod: get_Product
 
endmodule : mkFP_multiplier

endpackage: multiplier_fp_v3
