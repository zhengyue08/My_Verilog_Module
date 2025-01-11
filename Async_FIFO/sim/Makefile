sim:
	vvp a.out

compile:
	iverilog -g2005-sv tb_async_fifo.v ../rtl/asfifo.v
	# vcs -Mupdate -debug_access+all -kdb tb_async_fifo.v ../rtl/asfifo.v