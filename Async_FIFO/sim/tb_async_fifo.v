`timescale 1 ns/ 1 ns
module tb_async_fifo();

    reg clk ; 
    reg [7:0] data_in ; 
    reg r_en ; 
    reg rstn ; 
    reg w_en ; 
    // wires 
    wire [7:0] data_out ;
    wire empty ;
    wire full ; 
 
 initial begin
    clk=0;
    rstn=0;
    r_en=0;
    w_en=0;
    data_in=0;
    
    #40
    rstn = 1;
    #35
    w_en=1;
    r_en=0;
    #100
    w_en=0;
    r_en=1;
    #100
    w_en=1;
    r_en=0;
    #200
    w_en=0;
    r_en=1;
    #200
    w_en=1;
    r_en=0;
    #200
    w_en=0;
    r_en=1;
    #200
    w_en=1;
    r_en=0;
    #200
    w_en=0;
    r_en=1;
    #200
    w_en=1;
    r_en=0;
    #200
    w_en=0;
    r_en=1;
    #200
    w_en=1;
    r_en=0;
    #200
    w_en=0;
    r_en=1;
    #200
    w_en=1;
    r_en=1;
    #200
    $finish;
 end
 
 always #20 data_in<=data_in+1;
 
 always #10 clk=~clk;
 

asfifo u_asfifo
(
	.i_clk_r (clk),
	.i_clk_w (clk), 
	.i_rst_n	(rstn),
	.i_winc	(w_en),
	.i_rinc	(r_en),
   .i_wdata	(data_in),
	.o_wfull	(full),
	.o_rempty(empty),
	.o_rdata (data_out)
);

initial begin
   $dumpfile("asfifo.vcd");
   $dumpvars(0,tb_async_fifo);
end

 endmodule
