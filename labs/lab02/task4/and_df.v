// and_df.v - Dataflow AND gate with continuous assignment delay
module and_df (
  input  a,
  input  b,
  output y
);

  assign #1 y = a & b; // Change #1 to #2 or #3 for parts (b) and (c)


endmodule