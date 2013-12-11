class my_sequence extends uvm_sequence #( my_transaction );

  `uvm_object_utils( my_sequence );

  function new( string name = "" );
    super.new( name );
  endfunction: new

  
  task body;
    string sample_lenght = "10";

    logic [31:0] subframes[];
    int fd;
    string line;
    int sample;
    int index = 0;

    string cmd = { "python ./white_noise.py ", sample_lenght };
    $display( cmd );
    $system( cmd );
    subframes = new[ sample_lenght.atoi() ];
     
    fd = $fopen( "signal.tmp", "r" );
    
    while( !$feof( fd ) )
      begin
        $fgets( line, fd );
        $sscanf( line, "%d\n", sample );
        subframes[index] = 24'(sample);
        index = index + 1;
      end
   
    $fclose( fd );

    foreach ( subframes[j] )
      $display( "... %d", subframes[j] );

    $finish(); 
    // divide to subframes and add meta-info
    //
    // create BMC coded subframe
    // 
    // give slot-by-slot to driver
    // FIXME: or put finite amounts
    forever
      begin
        my_transaction tx;
        tx = my_transaction::type_id::create( "tx" );
        // Communicating the driver
        start_item( tx );
        // Modify randomization due to current state of system if needed
        assert( tx.randomize() );
        finish_item( tx );
      end

    subframes.delete();
  endtask: body

endclass: my_sequence

