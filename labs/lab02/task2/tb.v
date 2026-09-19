// tb.v
// Starter testbench template -- YOU complete this file.

module tb;

  // TODO: declare the inputs and outputs
// Parameters for testing parameter override syntax
  parameter TEST_WIDTH = 8;
  parameter TEST_DEPTH = 8;

  // Address width automatically adjusts using $clog2
  reg  [$clog2(TEST_DEPTH)-1:0] t_sel;
  wire [TEST_WIDTH-1:0]         t_dout;

  integer i;
  integer errors;
  // TODO: instantiate DUT here
  lut #(
    .WIDTH(TEST_WIDTH),
    .DEPTH(TEST_DEPTH)
  ) 
  DUT (
    .sel  (t_sel),
    .dout (t_dout)
  );

  // Waveform dump configuration (DO NOT CHANGE)
  string vcd_file;
  initial begin
    if ($value$plusargs("vcd=%s", vcd_file)) begin
      $dumpfile(vcd_file);
      $dumpvars(0, DUT);
    end
  end

  initial begin
    
  // TODO: apply different input combinations
  errors = 0;
    
    // Loop through every valid address in the ROM
    for (i = 0; i < TEST_DEPTH; i = i + 1) begin
      t_sel = i;
      #5; // Wait for combinational output to settle
      
      if (t_dout !== (i * i)) begin
        $display("FAIL at time %0t: sel=%0d | got dout=%0d, expected %0d",
                 $time, t_sel, t_dout, i * i);
        errors = errors + 1;
         end
      end

if (errors == 0) begin
      $display("SUCCESS: All %0d addresses returned correct values!", TEST_DEPTH);
    end else begin
      $display("FAILURE: Total errors = %0d", errors);
    end

    $finish;
  end
  initial
    $monitor($time, " I0=%b I1=%b S=%b | Y=%b", t_sel, t_sel, t_dout, t_dout); // change as required

endmodule
