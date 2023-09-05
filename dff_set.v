/*
Author: Yue Zheng
Email: zhen0631@umn.edu

A Data Flip-Flop with a set value.

Instantiation:

    dff #(.DATA_WIDTH(2)) u_dff (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(state_next_reg),
		.reset_data(2'b00),
        .data_out_reg(state_reg)
    );

The variable connected to data_out_reg must be **wire**, **reg** is not accepted

*/

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

    always @(posedge clk) begin
        if(!rst_n) begin
            data_out_reg <= reset_data;
        end else begin
            data_out_reg <= data_in;
        end
    end

endmodule
