package mac_fp;
// Include registers and wires
//replace + with adder module.


module mkMultiplyAccumulate (Empty);

   // Function to convert bfloat16 to FP32
   function Bit#(32) bfloat16_to_fp32(Bit#(16) bfloat16);
      Bit#(1) sign = bfloat16[15];
      Bit#(8) exponent = bfloat16[14:7];
      Bit#(7) mantissa = bfloat16[6:0];
     
      // FP32 has 23 mantissa bits, pad bfloat16 mantissa with 16 zeros
      Bit#(23) fp32_mantissa = {mantissa, 16'b0};

      // Construct FP32 value
      return {sign, exponent, fp32_mantissa};
   endfunction

   // Function to multiply two FP32 floating point numbers (A * B)
   function ActionValue#(Bit#(32)) float_multiply(Bit#(32) A, Bit#(32) B);
      let sign1 = A[31];
      let sign2 = B[31];
      let exp1  = A[30:23];
      let exp2  = B[30:23];
      let frac1 = {1'b1, A[22:0]};  // Implicit leading 1
      let frac2 = {1'b1, B[22:0]};  // Implicit leading 1

      // Multiply significands (fractions) manually using bitwise shift and add
      Bit#(48) frac_result = 0;
      for (Integer i = 0; i < 24; i = i + 1) begin
         if (frac2[i] == 1) begin
            frac_result = frac_result + (frac1 << i);
         end
      end

      // Add exponents and adjust for IEEE 754 bias
      let exp_result = exp1 + exp2 - 127;

      // Determine the sign of the result
      let sign_result = sign1 ^ sign2;

      // Normalize the result
      if (frac_result[47] == 1) begin
         frac_result = frac_result >> 1;
         exp_result = exp_result + 1;
      end

      // Assemble final result back into IEEE 754 FP32 format
      Bit#(32) result = {sign_result, exp_result, frac_result[46:24]};
      return result;
   endfunction

   // Function to add two FP32 floating point numbers (A + B)
   function ActionValue#(Bit#(32)) float_add(Bit#(32) A, Bit#(32) B);
      let sign1 = A[31];
      let sign2 = B[31];
      let exp1  = A[30:23];
      let exp2  = B[30:23];
      let frac1 = {1'b1, A[22:0]};  // Implicit leading 1
      let frac2 = {1'b1, B[22:0]};  // Implicit leading 1

      // Align exponents by shifting the smaller fraction
      Bit#(24) frac1_aligned, frac2_aligned;
      Bit#(8)  exp_result;
      Bit#(24) frac_result;
      Bit#(1)  sign_result;

      if (exp1 > exp2) begin
         let exp_diff = exp1 - exp2;
         frac2_aligned = frac2 >> exp_diff;
         frac1_aligned = frac1;
         exp_result = exp1;
      end else begin
         let exp_diff = exp2 - exp1;
         frac1_aligned = frac1 >> exp_diff;
         frac2_aligned = frac2;
         exp_result = exp2;
      end

      // Perform addition/subtraction of aligned fractions
      if (sign1 == sign2) begin
         frac_result = frac1_aligned + frac2_aligned;
         sign_result = sign1;
      end else begin
         if (frac1_aligned > frac2_aligned) begin
            frac_result = frac1_aligned - frac2_aligned;
            sign_result = sign1;
         end else begin
            frac_result = frac2_aligned - frac1_aligned;
            sign_result = sign2;
         end
      end

      // Normalize result if necessary
      if (frac_result[23]) begin
         exp_result = exp_result + 1;
         frac_result = frac_result >> 1;
      end

      // Assemble the final result in IEEE 754 FP32 format
      Bit#(32) result = {sign_result, exp_result, frac_result[22:0]};
      return result;
   endfunction


endmodule

endpackage: mac_fp
