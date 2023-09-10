/*
Author: Yue Zheng
Email: zhen0631@umn.edu

Full Adder.

3:2

Instantiation:

    full_adder u_fadder (
        .a(),
        .b(),
        .cin(),
        .sum(),
        .cout()
    );

*/

module full_adder (
    input a,
    input b,
    input cin,
    output sum,
    output cout
);

    assign sum = a ^ b ^ cin;
    assign cout = (a & b) || (a & cin) || (b & cin);

endmodule
