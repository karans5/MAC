package adder_fp;
import DReg :: *;  // Importing `DReg` module to use delayed registers (DRegs)


// Ripple Carry Adder interface definition
interface FP_add_ifc;
    method Action start(Bit#(32) a, Bit#(32) b);  // Method to load inputs
    method Bit#(32) get_add();  // Method to get the result (sum + overflow)
endinterface: FP_add_ifc

// Top-level module definition for the ripple carry adder
(*synthesize*)
module mk_Adder_fp (FP_add_ifc);

    // --- Register Declarations --- //

    Reg#(Bit#(32)) rg_fp_inp1 <- mkReg(0);  // Register to store input 'a'
    Reg#(Bit#(32)) rg_fp_inp2 <- mkReg(0);  // Register to store input 'b'
    Reg#(Bool) rg_fp_inp_valid <- mkDReg(False);  // Flag to indicate valid input
    Reg#(Bit#(32)) rg_fp_out <- mkReg(0);  // Register for the result
    Reg#(Bool) rg_fp_out_valid <- mkDReg(False);  // Flag to indicate valid output

    // Function to perform the ripple carry addition
    function Bit#(32) fp_addition(Bit#(32) a, Bit#(32) b);  

       //Step1: Extract sign, exponent and mantissa from inputs
       Bit#(1) sign_A  = a[31];
       Bit#(1) sign_B  = b[31];
       Bit#(8) exp_A   = a[30:23];
       Bit#(8) exp_B   = b[30:23];
       
       Bit#(23) mantissa_A = a[22:0];
       Bit#(23) mantissa_B = b[22:0];
              
       Bit#(32) result = 32'b0;     
       //step2: align the exponents:     
            
         
        Bit#(8) exp_Diff = (exp_A > exp_B) ? (exp_A - exp_B) : (exp_B - exp_A);
       
        Bit#(25) shiftedMantissaA = {1'b0,1'b1,mantissa_A}; //adding implicit one for mantissa addition
        Bit#(25) shiftedMantissaB = {1'b0,1'b1,mantissa_B};

        if (exp_A > exp_B) begin
            shiftedMantissaB = shiftedMantissaB >> exp_Diff;
        end else if (exp_B > exp_A) begin
            shiftedMantissaA = shiftedMantissaA >> exp_Diff;
        end

        Bit#(8) result_Exp = (exp_A> exp_B) ? exp_A : exp_B;

        // Step 3: Add or subtract mantissas based on sign
        
        Bit#(25) mantissaSum = 25'b0;
        Bit#(1) result_Sign;

        if (sign_A == sign_B) begin
            // Same sign, add mantissas
            mantissaSum = shiftedMantissaA + shiftedMantissaB;
            result_Sign = sign_A;
        end else begin
            // Different signs, subtract mantissas
            if (shiftedMantissaA > shiftedMantissaB) begin
              mantissaSum =  shiftedMantissaA - shiftedMantissaB;
               result_Sign = sign_A;
            end else begin
                mantissaSum = shiftedMantissaB - shiftedMantissaA;
                result_Sign = sign_B;
            end
        end

        // Step 4: Normalize result if needed
        if (mantissaSum[24]==1'b1) begin
            // Mantissa overflow, there is a carry_out, shift right and increment exponent
             mantissaSum = mantissaSum >> 1;
            result_Exp = result_Exp + 1;
        end else begin
            // Normalize left if possible
            if (mantissaSum[23] == 1'b0 && result_Exp >0) begin
                mantissaSum = mantissaSum << 1;
                result_Exp = result_Exp- 1;
            end
        end

        // Step 5: Check for overflow or underflow:
        if (result_Exp > 8'b11111110) begin
        	result = {result_Sign, 8'hFF, 23'b0}; // Set to Infinity
        end else if (result_Exp < 8'b00000001) begin
        	if(result_Exp == 0) begin 
        		result = {result_Sign, 31'b0};
        	end else begin 
        		result = {result_Sign, 8'b0, mantissaSum[22:0]};
        	end
        end else begin
        	
        	result = {result_Sign, result_Exp, mantissaSum[22:0]}; // Normal result
       
        
        end
       
        return result;
           
        
        
    endfunction: fp_addition

    // --- Rule Definitions --- //

    rule rl_fp_add if(rg_fp_inp_valid);
        // Compute the addition using the ripple_carry_addition function
        rg_fp_out <= fp_addition(rg_fp_inp1, rg_fp_inp2);  
        rg_fp_out_valid <= True;  // Set output valid flag to true
        $display("a=%b",rg_fp_inp1);
        $display("b=%b",rg_fp_inp2);
    endrule: rl_fp_add

    // --- Method Definitions --- //

    // Method to set the input values for addition
   method Action start(Bit#(32) a, Bit#(32) b);
    rg_fp_inp1 <= a;  // Store input 'a' in register
    rg_fp_inp2 <= b;  // Store input 'b' in register
    rg_fp_inp_valid <= True;  // Set input valid flag to true
   endmethod: start


    // Method to retrieve the additiSon result
    method  Bit#(32) get_add() if (rg_fp_out_valid);
        return rg_fp_out;  // Return the result from the output register
    endmethod: get_add

endmodule: mk_Adder_fp

endpackage: adder_fp


