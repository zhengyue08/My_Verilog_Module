// Sync FIFO: doesn't allow reading and writing on same address.
// Perfect Version
// wr_addr: address for next write
// rd_addr: address for next read


module sync_fifo 
#(
    parameter DATA_WIDTH = 'd8,
    parameter DATA_DEPTH = 'd8
)

(
    input clk,
    input rstn,
    input [DATA_WIDTH-1:0] data_in,
    input w_en,
    input r_en,
    output reg [DATA_WIDTH-1:0] data_out,
    output full,
    output empty,
    output [$clog2(DATA_DEPTH):0] data_num
);

reg [DATA_WIDTH-1:0] mem [0:DATA_DEPTH-1];

reg [$clog2(DATA_DEPTH):0] wr_addr, rd_addr;


 always @(posedge clk)
    if (~rstn)
        wr_addr <= 0;
    else 
		if (w_en & (~full))
        	wr_addr <= wr_addr + 1;
		else
			wr_addr <= wr_addr;

always @(posedge clk)
    if (w_en & (~full))
	    mem[wr_addr[$clog2(DATA_DEPTH)-1:0]] <= data_in;


always @(posedge clk)
    if (~rstn)
        rd_addr <= 0;
    else 
		if (r_en & (~empty))
        	rd_addr <= rd_addr + 1;
		else
			rd_addr <= rd_addr;
        
always @(posedge clk)
	if (r_en & (~empty))
	    data_out <= mem[rd_addr[$clog2(DATA_DEPTH)-1:0]];

assign full = wr_addr == {~rd_addr[$clog2(DATA_DEPTH)],rd_addr[$clog2(DATA_DEPTH)-1:0]};
assign empty = rd_addr == {wr_addr[$clog2(DATA_DEPTH)],wr_addr[$clog2(DATA_DEPTH)-1:0]};
assign data_num = (wr_addr > rd_addr) ? (wr_addr - rd_addr) : (rd_addr - wr_addr);


endmodule
