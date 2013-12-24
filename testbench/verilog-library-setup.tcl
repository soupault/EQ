#This file contains the commands to create libraries and compile the library file into those libraries.

set path_to_quartus $::env(HOME)/software/altera/quartus
set type_of_sim compile_all

# The type_of_sim should be one of the following values
# compile_all: Compiles all Altera libraries 
# functional: Compiles all libraries that are required for a functional simulation
# ip_functional: Compiles all libraries that are required functional simulation of Altera IP cores
# cycloneiii: Compiles all libraries that are required for an CYCLONEIII timing simulation
# max: Compiles all libraries that are required for an MAX timing simulation
# maxii: Compiles all libraries that are required for an MAXII timing simulation

if {[string equal $type_of_sim "compile_all"]} {
# compiles all libraries
	vlib lpm_ver
	vlib altera_mf_ver	
	vlib altera_prim_ver	
	vlib sgate_ver
	vlib altgxb_ver
	vlib cycloneiii_ver
	vlib max_ver
	vlib maxii_ver
	vmap lpm_ver lpm_ver
	vmap altera_mf_ver altera_mf_ver
	vmap sgate_ver sgate_ver
	vmap altgxb_ver altgxb_ver	
	vmap cycloneiii_ver cycloneiii_ver
	vmap max_ver max_ver
	vmap maxii_ver maxii_ver
	vmap altera_prim_ver altera_prim_ver
	vlog -work altera_mf_ver $path_to_quartus/eda/sim_lib/altera_mf.v
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v
	vlog -work cycloneiii_ver $path_to_quartus/eda/sim_lib/cycloneiii_atoms.v
	vlog -work max_ver $path_to_quartus/eda/sim_lib/max_atoms.v
	vlog -work maxii_ver $path_to_quartus/eda/sim_lib/maxii_atoms.v
	vlog -work altera_prim_ver $path_to_quartus/eda/sim_lib/altera_primitives.v
} elseif {[string equal $type_of_sim "functional"]} {
# required for functional simulation of designs that call LPM & altera_mf functions
	vlib lpm_ver
	vmap lpm_ver lpm_ver
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlib altera_mf_ver
	vmap altera_mf_ver altera_mf_ver
	vlog -work altera_mf_ver $path_to_quartus/eda/sim_lib/altera_mf.v
} elseif {[string equal $type_of_sim "ip_functional"]} {
# required for IP functional simualtion of designs
	vlib lpm_ver
	vmap lpm_ver lpm_ver
	vlog -work lpm_ver $path_to_quartus/eda/sim_lib/220model.v
	vlib altera_mf_ver
	vmap altera_mf_ver altera_mf_ver
	vlog -work altera_mf_ver $path_to_quartus/eda/sim_lib/altera_mf.v
	vlib sgate_ver
	vmap sgate_ver sgate_ver
	vlog -work sgate_ver $path_to_quartus/eda/sim_lib/sgate.v
} elseif {[string equal $type_of_sim "cycloneii"]} {
	# required for gate-level simulation of CYCLONEIII designs
	vlib cycloneiii_ver
	vmap cycloneiii_ver cycloneiii_ver
	vlog -work cycloneiii_ver $path_to_quartus/eda/sim_lib/cycloneiii_atoms.v
} elseif {[string equal $type_of_sim "max"]} {
	# required for gate-level simulation of MAX designs
	vlib max_ver
	vmap max_ver max_ver
	vlog -work max_ver $path_to_quartus/eda/sim_lib/max_atoms.v
} elseif {[string equal $type_of_sim "maxii"]} {
	# required for gate-level simulation of MAXII designs
	vlib maxii_ver
	vmap maxii_ver maxii_ver
	vlog -work maxii_ver $path_to_quartus/eda/sim_lib/maxii_atoms.v
} else {
	puts "invalid code"
}




