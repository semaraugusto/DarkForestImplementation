pragma circom 2.0.0;
include "./mimcsponge.circom";
include "./comparators.circom";
include "./bitify.circom";

template Main() {
    signal input x1;
    signal input y1;
    signal input x2;
    signal input y2;

    signal input distMove;
    signal input distMax;

    signal output h[2];

    component comp = LessThan(64);
    signal xSq;
    signal ySq;
    signal rSq;
    xSq <== (x2-x1)*(x2-x1);
    ySq <== (y2-y1)*(y2-y1);
    rSq <== distMove*distMove;
    log(xSq + ySq);
    log(rSq);

    comp.in[0] <== xSq + ySq;
    comp.in[1] <== rSq;
    comp.out === 1;

    component comp_max_distance = LessThan(64);
    signal xSq2;
    signal ySq2;
    signal rSq2;
    xSq2 <== x2*x2;
    ySq2 <== y2*y2;
    rSq2 <== distMax*distMax;
    log(xSq2 + ySq2);
    log(rSq2);

    comp_max_distance.in[0] <== xSq2 + ySq2;
    comp_max_distance.in[1] <== rSq2;
    comp_max_distance.out === 1;


    component mimc_check = MiMCSponge(2, 220, 1);

    mimc_check.ins[0] <== x1;
    mimc_check.ins[1] <== y1;
    mimc_check.k <== 0;

    /* signal pos_check; */
    h[0] <== mimc_check.outs[0];
    /* log(curr_pos_hash); */
    /* log(pos_check); */

    /* component is_equal = IsEqual();
    /* curr_pos_hash === pos_check; */
    /* is_equal.in[0] <== curr_pos_hash;
    is_equal.in[1] <== pos_check;
    is_equal.out === 1;   */

    component mimc_out = MiMCSponge(2, 220, 1);

    mimc_out.ins[0] <== x2;
    mimc_out.ins[1] <== y2;
    mimc_out.k <== 0;

    h[1] <== mimc_out.outs[0];
}
component main = Main();
