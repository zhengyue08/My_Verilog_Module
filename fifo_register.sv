module shift_reg_fifo
#(
    parameter DEPTH  = 8,   // FIFO depth
    parameter DATA_W = 32   // FIFO data DWIDTH
)
(
    input  clk,
    input  rstn,
    output empty,
    output full,
    
    input  push,
    input  [DATA_W-1:0] push_data,
    input  pop,
    output [DATA_W-1:0] pop_data
);


    reg [DATA_W-1 : 0] shift_reg [DEPTH-1 : 0];
    reg [DEPTH -1 : 0] shift_valid_reg;
    wire [$clog2(DEPTH)-1 : 0] left_one;
    wire [$clog2(DEPTH)-1 : 0] push_valid_pos;
    wire exists;
    assign push_valid_pos = exists ? left_one + 1'b1 : 0;

    left_most_one_or_zero #(DEPTH) u_lmorz (.data_in(shift_valid_reg), .target(1), .exists(exists), .pos(left_one));



    assign full = left_one == DEPTH-1;
    assign empty = ~exists;

    always @(posedge clk, negedge rstn)
        if (~rstn)
            shift_valid_reg <= 0;
        else begin
            if (push && ~full)
                shift_valid_reg[push_valid_pos] <= 1;
            if (pop && ~empty)
                shift_valid_reg <= {1'b0, shift_valid_reg[DEPTH-1 : 1]};
        end

    // shift register
    always @(posedge clk, negedge rstn) begin
        if (~rstn) begin
            integer j;
            for (j = 0; j < DEPTH; j = j + 1)
                shift_reg[j] <= 0; 
        end       
        else
            if (push && ~full)
                shift_reg[push_valid_pos] <= push_data;
            if (pop && ~empty)
                shift_reg <= {0, shift_reg[DEPTH-1 : 1]};
    end

    // pop_data
    assign pop_data = pop  ? shift_reg[0] : pop_data;


endmodule



module left_most_one_or_zero #(parameter DWIDTH=8) (
    input   logic [DWIDTH-1 : 0]        data_in,
    input   logic                       target,
    output  logic                       exists,
    output  logic [$clog2(DWIDTH)-1 : 0] pos // from right
);


    logic [DWIDTH-1 : 0] data_in_m; // data in modified, inverse all bits if target is 0;

    assign data_in_m = target ? data_in : (~data_in);

    genvar i;

    wire [DWIDTH/2-1:0] sliced [0: $clog2(DWIDTH)-1];

    generate
        for (i = 0; i < $clog2(DWIDTH); i = i+1) begin: gen_loop
            if (i==0) begin
                assign pos[$clog2(DWIDTH)-1-i] = | data_in_m[DWIDTH - 1 : DWIDTH/2];
                assign sliced[i] = pos[$clog2(DWIDTH)-1-i] ? data_in_m[DWIDTH-1 : DWIDTH/2] : data_in_m[DWIDTH/2 - 1 : 0];
            end else begin
                assign pos[$clog2(DWIDTH)-1-i] = | sliced [i-1] [DWIDTH/(2**i)-1 : DWIDTH/(2**i)/2];
                assign sliced[i] = pos[$clog2(DWIDTH)-1-i] ? sliced[i-1] [DWIDTH/(2**i)-1 : DWIDTH/(2**i)/2] : sliced[i-1] [ DWIDTH/(2**i)/2 -1 : 0];
            end
        end
    endgenerate

    assign exists = | data_in_m;

endmodule






