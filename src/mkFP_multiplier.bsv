import DReg :: *;

//multiplier interface
interface FP_multiplier_ifc;

	method Action start(Bit#(16) a, Bit#(16) b);
	method Bit#(32) get_Product();

endinterface: FP_multiplier_ifc




(*synthesize*)
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


//Conversion from bf16 to fp32
//function Bit#(32) bf16_to_fp32(Bit#(16) bf_inp);

//the sign bit and exponent bits are same for bf16 and fp32
//keeping them as it is and pad zeros for mantissa part to make them 23 bits
     //Bit#(1) sign = bf_inp[15];
     //Bit#(8) exponent = bf_inp[14:7];
     //Bit#(7) mantissa = bf_inp[6:0];
     //Bit#(23) fp32_mantissa = {mantissa,16'b0};
      
     //return {sign,exponent, fp32_mantissa};

//endfunction: bf16_to_fp32


   
   // Function to multiply two FP32 floating point numbers (A * B)
   function Bit#(32) fp_multiply(Bit#(16) inp_a, Bit#(16) inp_b);
     
      // Determine the sign of the result
      Bit#(1) sign = inp_a[15] ^ inp_b[15];
     
      
      Bit#(8) exp_a  = inp_a[14:7]; //+ 8'b10000001;
      Bit#(8) exp_b  = inp_b[14:7];//+ 8'b10000001;
      
      Bit#(24) frac_a = {1'b1, inp_a[6:0]};  // Implicit leading 1
      Bit#(24) frac_b = {1'b1, inp_b[6:0]};  // Implicit leading 1
      
      Bit#(16) frac1 = zeroExtend(frac_a);
      Bit#(16) frac2 = zeroExtend(frac_b);
     
     
     
      // Multiply significands (fractions) manually using bitwise shift and add
      //can use a for loop or if condition
      Bit#(16) frac_result = 0;
      for (Integer i = 0; i < 16; i = i + 1) begin
         if (frac2[i] == 1) begin
            frac_result = frac_result + (frac1 << i);
         end
      end
     
      // Add exponents and adjust for IEEE 754 bias
      //8- bit addition
      Bit#(8) exp_result = exp_a + exp_b +  8'b10000001; //8'b01111111;
      
      
      //Bit#(1) sign_result = sign_a ^ sign_b;
      
      // Normalize the result
      if (frac_result[15] == 1) begin
         frac_result = frac_result >> 1;
         exp_result = exp_result + 1;
         
      end
      
      //round to nearest
      // do rounding before final result
      
      //include the logic for rounding
      
      // Assemble final result back into IEEE 754 FP32 format
      
      Bit#(32) result = {sign, exp_result, frac_result[30:25]};
      return result;
   endfunction
	
   //always block to compute the product
   rule rl_compute_product (rg_inp_valid);
   
   	Bit#(32) fp_A = bf16_to_fp32(rg_A);
   	Bit#(32) fp_B = bf16_to_fp32(rg_B);
   	$display("A = %b",fp_A);
   	$display("B = %b",fp_B);
   	
   	rg_Product <= fp_multiply(fp_A,fp_B);
   	rg_Product_valid <= True;
   	rg_inp_valid <= False;
   	$display("Pro = %b",rg_Product);
   	//$display("exp = %d",rg_Product[30:23] + 8'b10000001);
   	//Bit#(32) prod = fp_multiply(fp_A,fp_B);
   	//rg_Product <=prod;
   	
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


