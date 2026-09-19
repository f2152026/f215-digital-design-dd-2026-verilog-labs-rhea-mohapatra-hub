// tb.v
// Self-checking testbench for 2-bit magnitude comparator (comp2)

module tb;

  reg  [1:0] t_a;
  reg  [1:0] t_b;
  wire       t_gt;
  wire       t_lt;
  wire       t_eq;

  reg exp_gt, exp_lt, exp_eq;
  integer i, j;
  integer errors = 0;
  integer total_tests = 0;

  // Instantiate DUT
  comp2 DUT (
    .A  (t_a),
    .B  (t_b),
    .GT (t_gt),
    .LT (t_lt),
    .EQ (t_eq)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  // Self-checking stimulus loop
  initial begin
    for (i = 0; i < 4; i = i + 1) begin
      for (j = 0; j < 4; j = j + 1) begin
        t_a = i;
        t_b = j;
        
        // Independently calculate expected golden outputs
        exp_gt = (i > j);
        exp_lt = (i < j);
        exp_eq = (i == j);

        #5; // Allow combinational logic to settle

        // Check using case-inequality (!==)
        if ({t_gt, t_lt, t_eq} !== {exp_gt, exp_lt, exp_eq}) begin
          $display("FAIL at time %0t: A=%b (%0d) B=%b (%0d) | got GT=%b LT=%b EQ=%b | expected GT=%b LT=%b EQ=%b",
                   $time, t_a, t_a, t_b, t_b, t_gt, t_lt, t_eq, exp_gt, exp_lt, exp_eq);
          errors = errors + 1;
        end
        total_tests = total_tests + 1;
      end
    end

    // Summary output using $write and $display
    $write("TEST COMPLETE: ");
    if (errors == 0) begin
      $display("PASS (%0d/%0d passed)", total_tests - errors, total_tests);
    end else begin
      $display("FAIL (%0d/%0d passed, %0d errors)", total_tests - errors, total_tests, errors);
    end

    $finish;
  end

  initial
    $monitor($time, " A=%b B=%b | GT=%b LT=%b EQ=%b", t_a, t_b, t_gt, t_lt, t_eq);

endmodule