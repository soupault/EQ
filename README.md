Developing S/PDIF to PCM converter.
Plus band equalizer in the middle.

Input clock is 384xFs (Fs - samples freq) = 18.432 MHz.
Samples are 48 kHz, 24 bits.

In case of sample loss use previous one (no interpolation).

Filters bands are fixed. Configuring only gains.

Old code is shit. Refactoring and creating UVM.

           ___                     _____ 
      ___ / _ \__ _____  ___ ___ _<  / /_
     (_-</ // / // / _ \/ _ `/ // / / __/
    /___/\___/\_,_/ .__/\_,_/\_,_/_/\__/ 
                 /_/                     

