// STC-Metrotek 2009
// Author: kod
// Module: regfile
// Description: register file with control (r/w) & status (r) registers

module regfile
 #( 
  parameter sc = 32, // status register count
  parameter cc = 32, // control register count
  parameter aw = 7 , // address width
  parameter dw = 8   // data width
)
(
  input                   clk_i,
  input                   rst_i,
  input         [dw-1:0]  data_i,          // data to write
  input                   wren_i,          // write enable
  input         [aw-1:0]  addr_i,          // address of register to write/read
  input         [dw-1:0]  sreg_i [sc-1:0], // array of status registers
  output logic  [dw-1:0]  data_o,          // data to read
  output logic  [dw-1:0]  creg_o [cc-1:0]  // array of control registers
); 

logic [dw-1:0] ctrl_regs [cc-1:0]; // array of control registers
logic [aw-2:0] local_addr;

// write control register operation
always_ff @( posedge clk_i, posedge rst_i )
  if( rst_i )
    begin
      int i;
      for( i = 0; i < cc; i++ )
        ctrl_regs[i] <= '0;
    end
  else
    if( wren_i & ~addr_i[aw-1] )
      ctrl_regs[local_addr] <= data_i; 

assign local_addr = addr_i[aw-2:0];

// read control register operation
always_comb
  if( addr_i[aw-1] ) // status registers selected
    data_o = sreg_i[local_addr];    
  else               // control registers selected
    data_o = ctrl_regs[local_addr];

// output assigning
always_comb
  creg_o = ctrl_regs;

endmodule

