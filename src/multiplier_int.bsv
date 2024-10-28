package multiplier_int;

// Struct to hold the inputs for the multiplier
typedef struct {
    Int#(8) a;  // Signed 8-bit multiplicand
    Int#(8) b;  // Signed 8-bit multiplier
} GetMulInp deriving (Bits, Eq);

// Multiplier interface definition
interface Mult_ifc;
    method Action get_Inputs(GetMulInp inputs);  // Method to set inputs
    method Int#(16) get_Mul();  // Method to get the 16-bit signed product
endinterface: Mult_ifc

(*synthesize*)
module mkMult (Mult_ifc);

    // --- Register Declarations --- //
    Reg#(Int#(16)) product <- mkReg(0);  // Register to store the product
    Reg#(Int#(16)) d <- mkReg(0);        // Holds the multiplicand (extended to 16 bits)
    Reg#(Int#(8)) r <- mkReg(0);         // Holds the multiplier
    Reg#(Bool) done <- mkReg(False);     // Control register to indicate completion

    // rule to compute the multiplication operation
    rule rl_compute (r != 0 && !done);  // Rule fires only if r is non-zero and multiplication is ongoing
        if (r[0] == 1)  // Check the least significant bit of r
            product <= product + d;  // Add the multiplicand if bit is 1

        d <= d << 1;  // Left shift multiplicand
        r <= r >> 1;  // Right shift multiplier

        if (r == 1)  // Check if this is the last iteration
            done <= True;  // Mark multiplication as complete
    endrule: rl_compute

    // Method to set inputs for the multiplication
    method Action get_Inputs(GetMulInp inputs);
        // Load inputs into registers and reset product/done
        d <= signExtend(inputs.a);  // Extend the 8-bit multiplicand to 16 bits
        r <= inputs.b;  // Store the multiplier
        product <= 0;  // Reset the product
        done <= False;  // Reset the done flag
    endmethod: get_Inputs

    // Method to return the multiplication result
    method Int#(16) get_Mul();
        return product;  // Return the signed product
    endmethod: get_Mul

endmodule: mkMult

endpackage: multiplier_int

