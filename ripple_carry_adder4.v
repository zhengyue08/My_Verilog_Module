/*
Author: Yue Zheng
Email: zhen0631@umn.edu

4 bits ripple carry adder.

Instantiation: 

	ripple_carry_adder4 u_rca4 (
		.p(),
		.q(),
		.c0(),
		.r()
	);
*/



module ripple_carry_adder4 (
    input [3:0] p,
    input [3:0] q,
    input c0,
    output [4:0] r
);

wire c1, c2, c3;

full_adder adder0 (
    .a(p[0]),
    .b(q[0]),
    .cin(c0),
    .sum(r[0]),
    .cout(c1)
);

full_adder adder1 (
    .a(p[1]),
    .b(q[1]),
    .cin(c1),
    .sum(r[1]),
    .cout(c2)
);

full_adder adder2 (
    .a(p[2]),
    .b(q[2]),
    .cin(c2),
    .sum(r[2]),
    .cout(c3)
);


full_adder adder3 (
    .a(p[3]),
    .b(q[3]),
    .cin(c3),
    .sum(r[3]),
    .cout(r[4])
);


endmodule
