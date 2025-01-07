// With a dual_port_RAM rtl model. Verified

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
module sfifo#(
	parameter	WIDTH = 8,
	parameter 	DEPTH = 16
)(
	input 					clk		, 
	input 					rst_n	,
	input 					winc	,
	input 			 		rinc	,
	input 		[WIDTH-1:0]	wdata	,

	output reg				wfull	,
	output reg				rempty	,
	output wire [WIDTH-1:0]	rdata
);

localparam ADDR_WIDTH = $clog2(DEPTH);

reg [ADDR_WIDTH : 0] wptr, rptr;

wire [ADDR_WIDTH : 0] fifo_cnt;

// read empty, will be asserted as long as the ram is empty no matter if the rinc is asserted
always @(*) rempty = (rptr == {wptr[ADDR_WIDTH],wptr[ADDR_WIDTH-1:0]});

// write full, will be asserted as long as the ram is full no matter if the winc is asserted
always @(*) wfull = (wptr == {~rptr[ADDR_WIDTH],rptr[ADDR_WIDTH-1:0]});


always @(posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		wptr <= 0;
	end else begin
		wptr <= ((~wfull) && winc) ? wptr + 1'b1 : wptr;
	end
end

always @(posedge clk, negedge rst_n) begin
	if (~rst_n) begin
		rptr <= 0;
	end else begin
		rptr <= ((~rempty) && rinc) ? rptr + 1'b1 : rptr;
	end
end




dual_port_RAM #(.DEPTH(DEPTH), .WIDTH(WIDTH)) ram (
	.wclk(clk),
	.wenc((~wfull) & winc),
	.waddr(wptr[ADDR_WIDTH-1 : 0]),
	.wdata(wdata),
	.rclk(clk),
	.renc((~rempty) & rinc),
	.raddr(rptr[ADDR_WIDTH-1 : 0]),
	.rdata(rdata)
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
