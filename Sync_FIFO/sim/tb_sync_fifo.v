`timescale 1 ns/ 1 ps
module tb_sync_fifo();

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
 
 sync_fifo u_sync_fifo (
    .clk ( clk ),
    .data_in ( data_in ),
    .data_out ( data_out ),
    .empty ( empty ),
    .full ( full ),
    .r_en ( r_en ),
    .rstn ( rstn ),
    .w_en ( w_en )
 );
 
 endmodule
