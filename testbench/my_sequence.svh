`include "../subframe.svh"

class my_sequence extends uvm_sequence #( my_transaction );

  `uvm_object_utils( my_sequence );

  function new( string name = "" );
    super.new( name );
  endfunction: new

  
  task body;
    int           sample_lenght = 10;
    string        cmd;
    logic [27:0]  subframes[]; // no preamble included
    int           fd;
    string        line;
    int           sample;
    
    bit [63:0]    temp;
    bit           prev_trans_bit = 0;
    int           i = 0, k, m;

    // generate input signal and dynamic array for it
    cmd.itoa( sample_lenght );
    cmd = { "python ./white_noise.py ", cmd };
    `uvm_info( cmd )
    $system( cmd );
    subframes = new[ sample_lenght ];
    
    // read data from file
    fd = $fopen( "signal.tmp", "r" );
    while( !$feof( fd ) )
      begin
        $fgets( line, fd );
        $sscanf( line, "%d\n", sample );
        // TODO: casting should work here, but it doesn't
        // subframes[index][AUDIO_SAMPLE] = 24'sample;
        subframes[i][`AUDIO_SAMPLE] = sample;
        subframes[i][`AUX_SAMPLE]   = '0; // because of 24bits sample depth
        i = i + 1;
      end
    $fclose( fd );

    // fill meta-info fields
    foreach ( subframes[j] )
      begin
        // TODO: split A,B channels data 
        subframes[j][`VALIDITY]    = 1'b1;
        // TODO: read from file, generate random, etc: CHANNEL_STATUS, USER_DATA
        subframes[j][`CHNL_STATUS] = 1'b0;
        subframes[j][`USER_DATA]   = 1'b0;

        subframes[j][`PARITY]      = ~( ^subframes[j][26:0] );
      end

    foreach ( subframes[j] )
      $display( "... %b", subframes[j] );

    //$finish(); 
    
    // encode data and interact with driver
    for( i = 0; i < sample_lenght; i = i + 1 )
      begin
        // creating BMC coded subframe
        // paste preamble
        //case( subframe[i][] )  // TODO: pass preamble here XXX
        case( 2'b01 )
          2'b01 : temp[63:56] = 8'b11100010; // X
          2'b11 : temp[63:56] = 8'b11100100; // Y
          2'b10 : temp[63:56] = 8'b11101000; // Z
        endcase
        // encode data with BMC
        for( k = 0; k < 28; k = k + 1 )
          begin
            // if last signal value is HIGH(1); [ 00/11 - 'd0, 10/01 - 'd1 ]
            if( temp[56-k*2] )
              temp[56-k*2-2 +: 2] = subframes[i][k] ? 2'b00 : 2'b01;
            else
              temp[56-k*2-2 +: 2] = subframes[i][k] ? 2'b11 : 2'b10;
          end
        
        // switch polarity due to last transmitted bit 
        temp = prev_trans_bit ? ~temp : temp; 
        prev_trans_bit = temp[0];

        // walking through time-slots
        for( m = 32*2-1; m >= 0; m = m - 1 )
          begin
            my_transaction tx;
            tx = my_transaction::type_id::create( "tx" );
            // Communicating the driver
            start_item( tx );
            tx.data = temp[m];
            // Modify randomization due to current state of system if needed
            // assert( tx.randomize() );
            finish_item( tx );
          end
      end

    subframes.delete();
  endtask: body

endclass: my_sequence

