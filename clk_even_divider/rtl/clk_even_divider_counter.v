module clk_even_divider_counter # 
(
	parameter divided = 4
)
(
	input  wire i_clk,
	input  wire i_rstn,
	output wire o_clk_divided
);
	
    reg [$clog2(divided)-1:0] counter;

    reg clk_divided;

    always @(posedge i_clk)
        if (~i_rstn)
            counter <= 0;
        else
            counter <= counter + 1;

    always @(posedge i_clk)
        if (~i_rstn)
            clk_divided <= 0;
        else if (counter == $clog2(divided) - 1 || counter == divided - 1)
            clk_divided <= ~clk_divided;
        else
            clk_divided <= clk_divided;

    assign o_clk_divided = clk_divided;
            
    
endmodule