module fib_generator (
input clk,
input rst_n,
output [7:0] fib
);

reg [7:0] fib_reg [0:1];

always @(posedge clk, negedge rst_n)
if (~rst_n) begin
fib_reg[0] <= 0;
fib_reg[1] <= 1;
end else begin
fib_reg[0] <= fib_reg[1];
fib_reg[1]  <= fib_reg[0] + fib_reg[1];
end

assign fib = fib_reg[0];

endmodule