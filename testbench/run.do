#

echo "#"
echo "# NOTE: Creating library and compiling design ..."
echo "#"
if [file exists work] {
    vdel -all
}
vlib work
vlog +incdir+/home/egor/workspace/uvm-1.1d/src ./pkg.sv +incdir+. +incdir+.. tb_main.sv

echo "#"
echo "# NOTE: Starting simulation"
echo "#"
vsim tb_main
run -all

