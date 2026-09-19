// tb.v
// Self-checking testbench for 4-bit ALU

module tb;

  reg  [3:0] t_a;
  reg  [3:0] t_b;
  reg        t_op;
  wire [3:0] t_result;

  reg  [3:0] exp_result;
  integer errors = 0;
  integer total_tests = 0;

  // Instantiate DUT
  alu DUT (
    .a      (t_a),
    .b      (t_b),
    .op     (t_op),
    .result (t_result)
  );

  // Waveform dump configuration
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  // Self-checking task
  task check_alu(input [3:0] a_in, input [3:0] b_in, input op_in);
    begin
      t_a  = a_in;
      t_b  = b_in;
      t_op = op_in;

      // Calculate golden expected result (4-bit truncation)
      if (op_in == 1'b0)
        exp_result = a_in + b_in;
      else
        exp_result = a_in - b_in;

      #5; // Wait for combinational logic to propagate

      if (t_result !== exp_result) begin
        $display("FAIL at time %0t: op=%b a=%d (%b) b=%d (%b) | got result=%d (%b) expected=%d (%b)",
                 $time, t_op, t_a, t_a, t_b, t_b, t_result, t_result, exp_result, exp_result);
        errors = errors + 1;
      end
      total_tests = total_tests + 1;
    end
  endtask

  initial begin
    errors = 0;
    total_tests = 0;

    // --- TEST CASE 1: Test sensitivity list (op toggles while a & b remain constant) ---
    t_a = 4'd7;
    t_b = 4'd3;
    
    t_op = 1'b0; // ADD: 7 + 3 = 10
    #5;
    if (t_result !== 4'd10) begin
      $display("FAIL [Sensitivity Test - ADD] at time %0t: got %d expected 10", $time, t_result);
      errors = errors + 1;
    end
    total_tests = total_tests + 1;

    t_op = 1'b1; // SUB: 7 - 3 = 4 (Only 'op' changed here!)
    #5;
    if (t_result !== 4'd4) begin
      $display("FAIL [Sensitivity Test - SUB op change] at time %0t: got %d expected 4", $time, t_result);
      errors = errors + 1;
    end
    total_tests = total_tests + 1;

    // --- TEST CASE 2: Comprehensive operand sweep for ADD and SUB ---
    check_alu(4'd5,  4'd2,  1'b0); // 5 + 2 = 7
    check_alu(4'd5,  4'd2,  1'b1); // 5 - 2 = 3
    check_alu(4'd10, 4'd4,  1'b1); // 10 - 4 = 6
    check_alu(4'd3,  4'd5,  1'b1); // 3 - 5 = 14 (Two's complement overflow: -2 = 4'b1110)
    check_alu(4'd15, 4'd1,  1'b0); // 15 + 1 = 0 (4-bit overflow)
    check_alu(4'd0,  4'd0,  1'b1); // 0 - 0 = 0
    check_alu(4'd12, 4'd12, 1'b1); // 12 - 12 = 0

    // Final Report
    $write("TEST COMPLETE: ");
    if (errors == 0) begin
      $display("PASS (%0d/%0d passed)", total_tests, total_tests);
    end else begin
      $display("FAIL (%0d/%0d passed, %0d errors)", total_tests - errors, total_tests, errors);
    end

    $finish;
  end

  initial
    $monitor($time, " op=%b a=%b b=%b | result=%b", t_op, t_a, t_b, t_result);

endmodule