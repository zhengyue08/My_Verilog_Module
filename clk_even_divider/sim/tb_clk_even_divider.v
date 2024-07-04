module tb_clk_even_divider;

    reg clk;
    reg rstn;
    wire clk_divided;


    clk_even_divider_counter u_clkd (
        .i_clk  (clk),
        .i_rstn (rstn),
        .o_clk_divided (clk_divided)
    );


    initial begin
        rstn = 1;
        #15;
        rstn = 0;
        #20;
        rstn = 1;
    end

    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        #100;
        $finish;
    end


endmodule