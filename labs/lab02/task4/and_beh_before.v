// and_beh_before.v - Behavioral AND gate with delay before procedural assignment
module and_beh_before (
  input      a,
  input      b,
  output reg y
);

  always @(*) begin
    #1 y = a & b; // Change #1 to #2 or #3 for parts (b) and (c)
  end

endmodule