onbreak resume
onerror resume
vsim -novopt work.lowpass_filter_tb
add wave sim:/lowpass_filter_tb/u_lowpass_filter/clk_i
add wave sim:/lowpass_filter_tb/u_lowpass_filter/clkena_i
add wave sim:/lowpass_filter_tb/u_lowpass_filter/nrst_i
add wave sim:/lowpass_filter_tb/u_lowpass_filter/filter_i
add wave sim:/lowpass_filter_tb/u_lowpass_filter/filter_o
add wave sim:/lowpass_filter_tb/filter_o_ref
run -all
