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
    
endmodule
