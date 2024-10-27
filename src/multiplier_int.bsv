package multiplier_int;

typedef struct {
    Bit#(8) a;
    Bit#(8) b;
} GetMulInp deriving(Bits, Eq);

interface Mult_ifc;
    method Action get_Inputs(GetMulInp inputs);
    method Bit#(16) get_Mul();
endinterface: Mult_ifc
(*synthesize*)
module mkMult (Mult_ifc);

    Reg#(Bit#(16)) product <- mkReg(0);  // Store the product
    Reg#(Bit#(16)) d <- mkReg(0);        // Holds the multiplicand
    Reg#(Bit#(8)) r <- mkReg(0);         // Holds the multiplier
    Reg#(Bool) done <- mkReg(False);   // Control register to signal when multiplication is complete
   

	// rule to compute the multiplication operation
    rule rl_compute (r != 0 && !done);  // Rule fires only if r is non-zero and multiplication is ongoing
        if (r[0] == 1)  // Check the least significant bit of r
            product <= product + d;  // Add the multiplicand if bit is 1

        d <= d << 1;  // Left shift multiplicand
        r <= r >> 1;  // Right shift multiplier

        if (r == 1)  // Check if this is the last iteration
            done <= True;  // Mark multiplication as complete
    endrule: rl_compute

    method Action get_Inputs(GetMulInp inputs);
        // Load the inputs into the registers and reset product/done
        d <= zeroExtend(inputs.a);
        r <= inputs.b;
        product <= 0;
        done <= False;
    endmethod: get_Inputs

    method Bit#(16) get_Mul();
        return product;  // Return the product
    endmethod: get_Mul

endmodule: mkMult

endpackage: multiplier_int

