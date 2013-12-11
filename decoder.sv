module decoder
(
  input               short_i,
  input               mid_i,
  input               long_i,
  input               ena_i,

  input               clk_i,
  input               nrst_i,

  output logic [27:0] package_o,
  output logic [1:0]  preamble_o,
  output logic        ena_o
);

logic [1:0]   len;
logic [7:0]   len_bfr;
logic [4:0]   counter;

enum  { PREAMBLE_SEARCH_S,
        DECODE_DATA_S,
        DECODE_IDLE_S
      } state, next_state;


// TODO: filling output reg with fixed frequency (?)
// TODO: module will never send last pkg to output. need one more ena_i

// ****** Endcodig lenght input ******
always_comb
  begin
    case( { long_i, mid_i, short_i } )
      3'b100  : len = 2'b11;
      3'b010  : len = 2'b10;
      3'b001  : len = 2'b01;
      default : len = 2'b00;
    endcase
  end
  
// typical preamble sequence is ZYXYXYXY...
// X = 'LLSS; Y = 'LMSM; Z = 'LSSL;
localparam PRE_X = 8'b11110101;
localparam PRE_Y = 8'b11100110;
localparam PRE_Z = 8'b11010110;

// data patterns
// 0 = 'M; 1 = 'SS;
localparam PATT_0 = 2'b10;
localparam PATT_1 = 4'b0101;


// ****** Filling buffer ******
always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    len_bfr <= '0;
  else
    if( ena_i )
      len_bfr <= { len_bfr[7:2], len };


// ****** Decoding ******
always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    state <= PREAMBLE_SEARCH_S;
  else
    if( ena_i )
      state <= next_state;

always_comb
  begin
    case( state )
      PREAMBLE_SEARCH_S :
        if( ( len_bfr == PRE_X ) & ( len_bfr == ~PRE_X ) &
            ( len_bfr == PRE_Y ) & ( len_bfr == ~PRE_Y ) &
            ( len_bfr == PRE_Z ) & ( len_bfr == ~PRE_Z ) )
          next_state = DECODE_IDLE_S;  // accumulate 2 lenghts

      DECODE_IDLE_S     :
        next_state = DECODE_DATA_S;

      DECODE_DATA_S     :
        if( len_bfr[3:2] == PATT_0 )
          next_state = DECODE_DATA_S;
        else
          if( len_bfr[3:0] == PATT_1 )
            next_state = DECODE_IDLE_S;
          else
            next_state = PREAMBLE_SEARCH_S;
    endcase
  end 

// ****** Encoding preamble type ******
always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    preamble_o <= '0;
  else
    if( ena_i )
      case( len_bfr )
        PRE_X, ~PRE_X : preamble_o <= 2'b01; 
        PRE_Y, ~PRE_Y : preamble_o <= 2'b11; 
        PRE_Z, ~PRE_Z : preamble_o <= 2'b10;
        default       : preamble_o <= 2'b00; 
      endcase

// ****** Generating output data ******
always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    package_o <= '0;
  else
    if( ena_i )
      if( state == DECODE_DATA_S )
        begin
          if( next_state == DECODE_DATA_S )
            package_o <= { 1'b0, package_o[27:1] };
          else
            if( next_state == DECODE_IDLE_S )
              package_o <= { 1'b1, package_o[27:1] };
        end


// ****** Count how many data bits were decoded ******
always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    counter <= '0;
  else
    if( ena_i )
      begin
        if( state == DECODE_DATA_S )
          counter <= counter + 1'b1;
        else
          if( state == PREAMBLE_SEARCH_S )
            counter <= '0; 
      end
      

always_ff @( posedge clk_i or negedge nrst_i )
  if( ~nrst_i )
    ena_o <= '0;
  else
    if( ena_i )
      begin 
        if( ( state == DECODE_DATA_S ) & 
            ( next_state == PREAMBLE_SEARCH_S ) &
            ( counter == 5'd27 ) )
          ena_o <= '1;
        else
          ena_o <= '0;
      end

endmodule

