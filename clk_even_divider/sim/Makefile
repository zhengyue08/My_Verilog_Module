wave: compile
	./simv -gui

sim: compile
	./simv

compile:
	vcs -sverilog -Mupdate -kdb -debug_access+all -f sim.f
