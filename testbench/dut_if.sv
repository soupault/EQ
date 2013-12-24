interface dut_if();

  logic         clk;  // clock signal of BMC input
  logic         clk2; // 2xfreq('clk') for feeding transaction
  logic         clk6; // 6xfreq('clk') for design operating
  logic         nrst;
  logic         spdif;
  logic [23:0]  pcm;
  logic         pcm_ena;

endinterface: dut_if

