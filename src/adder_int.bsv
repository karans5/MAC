package adder_int;

import DReg :: *;  // Importing `DReg` module to use delayed registers (DRegs)

// Struct to hold the result of the addition, including the sum and overflow flag
typedef struct {
    Bit#(1) overflow;  // Overflow flag (1 if overflow occurs)
    Int#(32) sum;      // 32-bit signed sum of the two inputs
} Adderresult deriving (Bits, Eq);

// Ripple Carry Adder interface definition
interface RCA_ifc;
    method Action start(Int#(32) a, Int#(32) b);  // Method to load signed inputs
    method Adderresult get_add();  // Method to get the result (sum + overflow)
endinterface: RCA_ifc

// Top-level module definition for the ripple carry adder
(*synthesize*)
module mkRipplecarryadder (RCA_ifc);

    // --- Register Declarations --- //
    Reg#(Int#(32)) rg_inp1 <- mkReg(0);  // Register to store input 'a'
    Reg#(Int#(32)) rg_inp2 <- mkReg(0);  // Register to store input 'b'
    Reg#(Bool) rg_inp_valid <- mkDReg(False);  // Flag to indicate valid input
    Reg#(Adderresult) rg_out <- mkReg(Adderresult{overflow: 0, sum: 0});  // Register for the result
    Reg#(Bool) rg_out_valid <- mkDReg(False);  // Flag to indicate valid output

    // Function to perform the ripple carry addition
    function Adderresult ripple_carry_addition(
        Int#(32) a, Int#(32) b, Bit#(1) cin);  // 'cin' is the carry-in bit

        Int#(32) sum = 0;         // 32-bit signed sum for the addition
        Bit#(33) carry = 0;       // 33-bit carry to handle overflow

        carry[0] = cin;  // Initialize carry-in

        // Loop to perform bit-by-bit addition with carry propagation
        for (Integer i = 0; i < 32; i = i + 1) begin
            sum[i] = a[i] ^ b[i] ^ carry[i];  // Compute the sum bit
            carry[i + 1] = (a[i] & b[i]) | ((a[i] ^ b[i]) & carry[i]);  // Compute the carry-out
        end

        // Create the result struct and assign sum and overflow
        Adderresult out;
        out.sum = sum;
        out.overflow = carry[32];  // Set overflow flag from the final carry-out

        return out;  // Return the computed result
    endfunction: ripple_carry_addition

    // --- Rule Definitions --- //

    rule rl_rca;
        // Compute the addition using the ripple_carry_addition function
        rg_out <= ripple_carry_addition(rg_inp1, rg_inp2, 1'b0);  
        rg_out_valid <= True;  // Set output valid flag to true
    endrule: rl_rca

    // --- Method Definitions --- //

    // Method to set the input values for addition
    method Action start(Int#(32) a, Int#(32) b);
        rg_inp1 <= a;  // Store input 'a' in register
        rg_inp2 <= b;  // Store input 'b' in register
    endmethod: start

    // Method to retrieve the addition result
    method Adderresult get_add();
        return rg_out;  // Return the result from the output register
    endmethod: get_add

endmodule: mkRipplecarryadder

endpackage: adder_int

