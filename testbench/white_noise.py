
import sys
import random

if __name__ == "__main__":
  print( "Generating white noise..." )
  
  with open( "signal.tmp", "w" ) as f:
    sample_lenght = int( sys.argv[1] )
    for i in range( sample_lenght ):
      # 24 bit wide
      sample = random.randrange( pow(2, 24) )
      f.write( str(sample) + "\n" )
  
  print( "Done..." )

