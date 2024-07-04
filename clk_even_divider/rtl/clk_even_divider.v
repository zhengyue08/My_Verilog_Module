module clk_even_divider # 
(
	parameter divided = 2
)
(
	input  wire i_clk,
	input  wire i_rstn,
	output wire o_clk_divided
);
	
	wire [$clog2(divided):0] inner_clk;

	
	dff #(1) u_dff0 (
		.clk			(i_clk),
		.rst_n			(i_rstn),
		.data_in		(~inner_clk[0]),
		.reset_data		(0),
		.data_out_reg	(inner_clk[0])
	);

	dff #(1) u_dff1 (
		.clk			(inner_clk[0]),
		.rst_n			(i_rstn),
		.data_in		(~inner_clk[1]),
		.reset_data		(0),
		.data_out_reg	(inner_clk[1])
	);

	assign o_clk_divided = inner_clk[$clog2(divided)];

endmodule


module dff #(
    parameter DATA_WIDTH = 8
)
(
    input clk,
    input rst_n,
    input [DATA_WIDTH-1 : 0] data_in,
    input [DATA_WIDTH-1 : 0] reset_data,
    output reg [DATA_WIDTH-1 : 0] data_out_reg

);

    always @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
            data_out_reg <= reset_data;
        end else begin
            data_out_reg <= data_in;
        end
    end

endmodule