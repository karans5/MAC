package multiplier;

interface Mult_ifc;
       method Action put_x (int x);
       method Action put_y (int y);
       method ActionValue #(int) get_z();
endinterface: Mult_ifc




module mkMult (Mult_ifc);

Reg#(int) product <- mkReg (0);
Reg#(int)           d <- mkReg (0);
Reg#(int)            r <- mkReg (0);
Reg#(Bool) got_x <- mkReg (False);
Reg#(Bool) got_y <- mkReg (False);

rule rl_compute ((r != 0)  &&  got_x 
&&  got_y);
    if (pack(r)[0] == 1)
        product <= product + d;
    d <= d << 1;
    r  <= r >> 1;
endrule

method Action put_x (int x) if (! got_x);
    d <= x; product <= 0; got_x <= True;
endmethod

method Action put_y (int y) if (! got_y);
    r <= y; got_y <= True;
endmethod

method ActionValue #(int) get_z ()
    if ((r == 0) && got_x && got_y);
        got_x <= False;
        got_y <= False;
  return product;
endmethod

endmodule: mkMult
endpackage:multiplier
