pragma circom 2.0.0;
include "./mimcsponge.circom";
include "./comparators.circom";
include "./bitify.circom";
//include "pointbits.circom";

/* template LessThan(n) { */
/*     assert(n <= 252); */
/*     signal input in[2]; */
/*     signal output out; */
/*  */
/*     component n2b = Num2Bits(n+1); */
/*  */
/*     n2b.in <== in[0]+ (1<<n) - in[1]; */
/*  */
/*     out <== 1-n2b.out[n]; */
/* } */
function gcd(left_operand, right_operand){
    var temp;

    // Pass by reference
    var left;
    var right;
    left = left_operand;
    right = right_operand;

    while (right != 0){
        temp = left % right;
        left = right;
        right = temp;
    }
    return left;
}

function isPrimeOrOne(n) {
    var i=2;
    log(n);
    log(n);
    log(n);
    if (i >= n)
        return 1;

    while(n%i != 0 && i<n) {
        i += 1;
        log(i);
    }
    return i>=n;
}

template Main() {
    signal input x;
    signal input y;
    signal input r;
    signal input s;

    signal output h;

    /* component is_x_zero = IsZero(); */
    /* is_x_zero.in <== x; */
    /* is_x_zero.out === 0; */
    /*  */
    /* component is_y_zero = IsZero(); */
    /* is_y_zero.in <== y; */
    /* is_y_zero.out === 0; */

    /* check x^2 + y^2 < r^2 */
    component comp = LessThan(64);
    signal xSq;
    signal ySq;
    signal rSq;
    xSq <== x * x;
    ySq <== y * y;
    rSq <== r * r;

    comp.in[0] <== xSq + ySq;
    comp.in[1] <== rSq;
    comp.out === 1;

    component comp32 = LessThan(64);
    signal sSq;
    sSq <== s * s;

    comp32.in[0] <== xSq + ySq;
    comp32.in[1] <== sSq;
    comp32.out === 0;

    signal left;
    signal right;
    var gcd1;
    left <== x;
    right <== y;
    gcd1 = gcd(right, left);
    log(left);
    log(right);
    log(gcd1);

    // is_prime checks starts the counter at 2, so if is_prime(num)===1 than it either is a prime number or is 1
    signal gcd_prime;
    gcd_prime <-- gcd1;
    log(222222222222222222);
    var is_prime_or_one = isPrimeOrOne(gcd_prime);
    log(gcd_prime);
    log(is_prime_or_one);
    component is_zero = IsZero();
    log(3333333333333333333);
    log(is_prime_or_one);
    is_zero.in <-- is_prime_or_one;
    log(is_zero.out);
    is_zero.out === 1;

    component mimc = MiMCSponge(2, 220, 1);

    mimc.ins[0] <== x;
    mimc.ins[1] <== y;
    mimc.k <== 0;

    h <== mimc.outs[0];
}
component main = Main();
