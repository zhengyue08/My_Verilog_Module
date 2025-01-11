
`timescale 1ns/1ns

/**********************************RAM************************************/
module dual_port_RAM #(parameter DEPTH = 16,
					   parameter WIDTH = 8)(
	 input wclk
	,input wenc
	,input [$clog2(DEPTH)-1:0] waddr  
	,input [WIDTH-1:0] wdata      	
	,input rclk
	,input renc
	,input [$clog2(DEPTH)-1:0] raddr  
	,output reg [WIDTH-1:0] rdata 		
	);

	reg [WIDTH-1:0] RAM_MEM [0:DEPTH-1];

	always @(posedge wclk) begin
		if(wenc)
			RAM_MEM[waddr] <= wdata;
	end 

	always @(posedge rclk) begin
		if(renc)
			rdata <= RAM_MEM[raddr];
	end 
endmodule  


/**********************************SFIFO************************************/
module asfifo#(
	parameter	WIDTH = 8,
	parameter 	DEPTH = 16
)(
	input 					i_clk_r,
	input 					i_clk_w, 
	input 					i_rst_n	,
	input 					i_winc	,
	input 			 		i_rinc	,
	input 		[WIDTH-1:0]	i_wdata	,

	output reg				o_wfull	,
	output reg				o_rempty,
	output wire [WIDTH-1:0]	o_rdata
);

localparam AW = $clog2(DEPTH);


reg 	[AW : 0] wptr, wptr_gray_ff1, wptr_gray_ff2;
wire 	[AW : 0] wptr_gray;

// Translate wptr to gray code
assign 	wptr_gray = (wptr >> 1) ^ wptr;

reg 	[AW : 0] rptr, rptr_gray_ff1, rptr_gray_ff2;
wire 	[AW : 0] rptr_gray;

// Translate rptr to gray code
assign 	rptr_gray = (rptr_gray >> 1) ^ rptr;

// Synchronizer:  Transfer wptr_gray to read clk domain
always @(posedge i_clk_r, negedge i_rst_n) begin
	if (~i_rst_n)
		{wptr_gray_ff2, wptr_gray_ff1} <= 0;
	else
		{wptr_gray_ff2, wptr_gray_ff1} <= {wptr_gray_ff1, wptr_gray};
end

// Synchronizer: Transfer rptr_gray to write clk domain
always @(posedge i_clk_w, negedge i_rst_n) begin
	if (~i_rst_n)
		{rptr_gray_ff2, rptr_gray_ff1} <= 0;
	else
		{rptr_gray_ff2, rptr_gray_ff1} <= {rptr_gray_ff1, rptr_gray};
end

always @(posedge i_clk_w, negedge i_rst_n) begin
	if (~i_rst_n) begin
		wptr <= 0;
	end else begin
		wptr <= ((~o_wfull) && i_winc) ? wptr + 1'b1 : wptr;
	end
end

always @(posedge i_clk_r, negedge i_rst_n) begin
	if (~i_rst_n) begin
		rptr <= 0;
	end else begin
		rptr <= ((~o_rempty) && i_rinc) ? rptr + 1'b1 : rptr;
	end
end


wire [AW : 0] fifo_cnt;

// read empty, will be asserted as long as the ram is empty no matter if the rinc is asserted
always @(*) o_rempty = (rptr_gray[AW:AW-1] ^ wptr_gray_ff2[AW:AW-1]) && (rptr_gray[AW-2:0] == wptr_gray_ff2[AW-2:0]);

// write full, will be asserted as long as the ram is full no matter if the winc is asserted
always @(*) o_wfull = (wptr_gray == rptr_gray_ff2);



dual_port_RAM #(.DEPTH(DEPTH), .WIDTH(WIDTH)) ram (
	.wclk(i_clk_w),
	.wenc((~o_wfull) & i_winc),
	.waddr(wptr[AW-1 : 0]),
	.wdata(i_wdata),
	.rclk(i_clk_r),
	.renc((~o_rempty) & i_rinc),
	.raddr(rptr[AW-1 : 0]),
	.rdata(o_rdata)
);
    
`ifdef FORMAL

// cover max depth
fifo_wr_entry_highest: cover property (@(posedge clk) wptr == DEPTH-1);
fifo_rd_entry_highest: cover property (@(posedge clk) rptr == DEPTH-1);

// cover full empty status
fifo_rempty: cover property (@(posedge clk) rempty);
fifo_wfull:  cover property (@(posedge clk) wfull);


// Empty Flag Assert
empty_condition: assert property (@(posedge clk) disable iff(~rst_n) wptr - rptr == 0 |-> rempty);

// Full Flag Assert
full_condition: assert property (@(posedge clk) disable iff(~rst_n) wptr - rptr == DEPTH |-> wfull);


full_wptr_nochange:   assert property (@(posedge clk) disable iff(~rst_n) $rose(wfull) |=> $stable(wptr));

emptry_rptr_nochange: assert property (@(posedge clk) disable iff(~rst_n) $rose(rempty) |=> $stable(rptr));


// Full Empty cannot be asserted same time
empty_no_full: assert property (@(posedge clk) disable iff(~rst_n) rempty |-> ~wfull);
full_no_empty: assert property (@(posedge clk) disable iff(~rst_n) wfull |-> ~rempty);

// Can read and write different address at same edge
rd_wr_same_time: assert property (@(posedge clk) disable iff(~rst_n) rinc && winc && (~wfull) && (~rempty) |=> wptr-rptr == $past(wptr - rptr));

// Cannot read and write same address at same edge
cannot_rd_wr_same_address1: assert property (@(posedge clk) disable iff(~rst_n) wfull && rinc && winc |=> (~wfull));
cannot_rd_wr_same_address2: assert property (@(posedge clk) disable iff(~rst_n) rempty && rinc && winc |=> (~rempty));


`endif

endmodule
