onbreak resume
onerror resume
vsim -novopt work.highpass_filter_tb
add wave sim:/highpass_filter_tb/u_highpass_filter/clk_i
add wave sim:/highpass_filter_tb/u_highpass_filter/clkena_i
add wave sim:/highpass_filter_tb/u_highpass_filter/nrst_i
add wave sim:/highpass_filter_tb/u_highpass_filter/filter_in
add wave sim:/highpass_filter_tb/u_highpass_filter/filter_out
add wave sim:/highpass_filter_tb/filter_out_ref
run -all
