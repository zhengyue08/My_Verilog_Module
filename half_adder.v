/*
Author: Yue Zheng
Email: zhen0631@umn.edu

Half Adder

2:2

Instantiation:

    half_adder u_hadder (
        .a(),
        .b(),
        .sum(),
        .cout()
    );
*/

module half_adder (
    input a,
    input b,
    output sum,
    output cout
);

    assign sum = a ^ b;
    assign cout = a & b;

endmodule