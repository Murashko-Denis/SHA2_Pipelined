//hash sha2
module sha2_pipelined 
#(parameter N=32) //size word
(
    input clk, 
    input [511:0] message,
    input strobe,
    output [255:0] hash_out,
    output valid
);
//count rounds	 
reg [6:0] cnt_round;
//initialization hash values
wire [255:0] H_0 = {32'h6A09E667, 32'hBB67AE85, 32'h3C6EF372, 32'hA54FF53A,
						  32'h510E527F, 32'h9B05688C, 32'h1F83D9AB, 32'h5BE0CD19};
//initialization variables
wire [N-1:0] a_in = H_0[255:224], b_in = H_0[223:192], c_in = H_0[191:160], d_in = H_0[159:128];
wire [N-1:0] e_in = H_0[127:96],  f_in = H_0[95:64],   g_in = H_0[63:32],   h_in = H_0[31:0];

//add the received values to the previously hash result:
reg [N-1:0] a_q, b_q, c_q, d_q, e_q, f_q, g_q, h_q;
assign hash_out = {
    a_in + a_q, b_in + b_q, c_in + c_q, d_in + d_q, e_in + e_q, f_in + f_q, g_in + g_q, h_in + h_q
};

//hash valid if 64 rounds complite
assign valid = cnt_round == 7'd64; 

//main block
wire [N-1:0] a_d, b_d, c_d, d_d, e_d, f_d, g_d, h_d;
always @(posedge clk)
begin
    if (strobe) begin
	 //initialization variables
        a_q <= a_in; 
		  b_q <= b_in; 
		  c_q <= c_in; 
		  d_q <= d_in;
        e_q <= e_in; 
		  f_q <= f_in; 
		  g_q <= g_in; 
		  h_q <= h_in;
        cnt_round <= 0;
    end else begin
	 //new value in round
        a_q <= a_d; 
		  b_q <= b_d; 
		  c_q <= c_d; 
		  d_q <= d_d;
        e_q <= e_d; 
		  f_q <= f_d; 
		  g_q <= g_d; 
		  h_q <= h_d;
        cnt_round <= cnt_round + 1;
    end
end

//calculation round
round round (
    .Kj(Kj), 
	 .Wj(Wj),
    .a_in(a_q), 
	 .b_in(b_q), 
	 .c_in(c_q), 
	 .d_in(d_q),
    .e_in(e_q), 
	 .f_in(f_q), 
	 .g_in(g_q), 
	 .h_in(h_q),
    .a_out(a_d), 
	 .b_out(b_d), 
	 .c_out(c_d), 
	 .d_out(d_d),
    .e_out(e_d), 
	 .f_out(f_d), 
	 .g_out(g_d), 
	 .h_out(h_d)
);


//calculation Wj
wire [N-1:0] W_shift2, W_shift15, s1_Wtm2, s0_Wtm15, Wj, Kj;
s0_w s0_w (
	.x(W_shift15), 
	.s0(s0_Wtm15)
);

s1_w s1_w (
	.x(W_shift2), 
	.s1(s1_Wtm2)
);

calculate_Wj #(.N(32)) calculate_Wj(
    .clk(clk),
    .M(message), 
	 .M_valid(strobe),
    .W_shift2(W_shift2), 
	 .W_shift15(W_shift15),
    .s1_Wtm2(s1_Wtm2), 
	 .s0_Wtm15(s0_Wtm15),
    .W(Wj)
);

//calculation Kj
calculate_Kj calculate_Kj(
    .clk(clk), 
	 .rst(strobe), 
	 .K(Kj)
);

endmodule

//calculation round
module round 
#(parameter N=32) 
(
    input [N-1:0] Kj, Wj,
    input [N-1:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
    output [N-1:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out
);

//calculate functions
wire [N-1:0] Ch_e_f_g, Ma_a_b_c, S0_a, S1_e;

//Ch = (e and f) xor ((not e) and g)
Ch #(.N(N)) Ch (
    .x(e_in), 
	 .y(f_in), 
	 .z(g_in), 
	 .Ch(Ch_e_f_g)
);

//Ma = (a and b) xor (a and c) xor (b and c)
Ma #(.N(N)) Ma (
    .x(a_in), 
	 .y(b_in), 
	 .z(c_in), 
	 .Ma(Ma_a_b_c)
);

// Σ0 = (x rotr 2) xor (x rotr 13) xor (x rotr 22)
S0 S0(
    .x(a_in), 
	 .S0(S0_a)
);

//Σ1 = (x rotr 6) xor (x rotr 11) xor (x rotr 25)
S1 S1(
    .x(e_in), 
	 .S1(S1_e)
);

//re-count 32bit word
/*h := g
  g := f
  f := e
  e := d + t1
  d := c
  c := b
  b := a
  a := t1 + t2*/
round_recount #(.N(N)) round_recount(
    .Kj(Kj), 
	 .Wj(Wj),
    .a_in(a_in), 
	 .b_in(b_in), 
	 .c_in(c_in), 
	 .d_in(d_in),
    .e_in(e_in), 
	 .f_in(f_in), 
	 .g_in(g_in), 
	 .h_in(h_in),
    .Ch_e_f_g(Ch_e_f_g), 
	 .Ma_a_b_c(Ma_a_b_c), 
	 .S0_a(S0_a), 
	 .S1_e(S1_e),
    .a_out(a_out), 
	 .b_out(b_out), 
	 .c_out(c_out), 
	 .d_out(d_out),
    .e_out(e_out), 
	 .f_out(f_out), 
	 .g_out(g_out), 
	 .h_out(h_out)
);
endmodule

//calculation round function
module round_recount 
#(parameter N=32) 
(
    input [N-1:0] Kj, Wj,
    input [N-1:0] a_in, b_in, c_in, d_in, e_in, f_in, g_in, h_in,
    input [N-1:0] Ch_e_f_g, Ma_a_b_c, S0_a, S1_e,
    output [N-1:0] a_out, b_out, c_out, d_out, e_out, f_out, g_out, h_out
);

wire [N-1:0] T1 = h_in + S1_e + Ch_e_f_g + Kj + Wj;
wire [N-1:0] T2 = S0_a + Ma_a_b_c;

assign a_out = T1 + T2;
assign b_out = a_in;
assign c_out = b_in;
assign d_out = c_in;
assign e_out = d_in + T1;
assign f_out = e_in;
assign g_out = f_in;
assign h_out = g_in;

endmodule


// Ch(x,y,z)
module Ch #(parameter N=0) (
    input wire [N-1:0] x, y, z,
    output wire [N-1:0] Ch
);

assign Ch = ((x & y) ^ (~x & z));

endmodule


// Ma(x,y,z)
module Ma #(parameter N=0) (
    input wire [N-1:0] x, y, z,
    output wire [N-1:0] Ma
);

assign Ma = (x & y) ^ (x & z) ^ (y & z);

endmodule


//calculate_Wj - for generate additional 48 words
//w[j] = w[j-16] + s0 + w[j-7] + s1
//s0 = (w[j-15] rotr 7) xor (w[j-15] rotr 18) xor (w[j-15] shr 3)
//s1 = (w[j-2] rotr 17) xor (w[j-2] rotr 19) xor (w[j-2] shr 10)
module calculate_Wj 
#(parameter N=32) 
(
    input clk,
    input [N*16-1:0] M,
    input M_valid,
    input [N-1:0] s1_Wtm2, 
	 input [N-1:0] s0_Wtm15,
	 output [N-1:0] W_shift2, 
	 output [N-1:0] W_shift15,
    output [N-1:0] W
);
reg [N*16-1:0] W_register;
//calculate W_shift values
assign W_shift2 = W_register[N*2-1:N*1];
assign W_shift15 = W_register[N*15-1:N*14];
wire [N-1:0] W_shift7 = W_register[N*7-1:N*6];
wire [N-1:0] W_shift16 = W_register[N*16-1:N*15];
// calculate Wnext
wire [N-1:0] W_next = s1_Wtm2 + W_shift7 + s0_Wtm15 + W_shift16;

//write Wnext in W_register_next and shift register
wire [N*16-1:0] W_register_next = { W_register[N*15-1:0], W_next };
//Wj
assign W = W_register[N*16-1:N*15];

//initializing W_register
always @(posedge clk)
begin
    if (M_valid) begin
        W_register <= M;
    end else begin
        W_register <= W_register_next;
    end
end

endmodule


// Σ0 = (x rotr 2) xor (x rotr 13) xor (x rotr 22)
module S0 (
    input wire [31:0] x,
    output wire [31:0] S0
);
assign S0 = ({x[1:0], x[31:2]} ^ {x[12:0], x[31:13]} ^ {x[21:0], x[31:22]});

endmodule


//Σ1 = (x rotr 6) xor (x rotr 11) xor (x rotr 25)
module S1 (
    input wire [31:0] x,
    output wire [31:0] S1
);

assign S1 = ({x[5:0], x[31:6]} ^ {x[10:0], x[31:11]} ^ {x[24:0], x[31:25]});

endmodule


//s0 = (w[i-15] rotr 7) xor (w[i-15] rotr 18) xor (w[i-15] shr 3)
module s0_w (
    input wire [31:0] x,
    output wire [31:0] s0
    );

assign s0 = ({x[6:0], x[31:7]} ^ {x[17:0], x[31:18]} ^ (x >> 3));

endmodule


//s1 = (w[i-2] rotr 17) xor (w[i-2] rotr 19) xor (w[i-2] shr 10)
module s1_w (
    input wire [31:0] x,
    output wire [31:0] s1
    );

assign s1 = ({x[16:0], x[31:17]} ^ {x[18:0], x[31:19]} ^ (x >> 10));

endmodule


//count constant for each round
module calculate_Kj (
    input clk,
    input rst,
    output [31:0] K
    );

reg [2047:0] buffer;
wire [2047:0] buffer_shifted = { buffer[2015:0], buffer[2047:2016] };
assign K = buffer[2047:2016];

always @(posedge clk)
begin
    if (rst) begin
		  //initializing array of round constant
        buffer <= {
            32'h428a2f98, 32'h71374491, 32'hb5c0fbcf, 32'he9b5dba5,
            32'h3956c25b, 32'h59f111f1, 32'h923f82a4, 32'hab1c5ed5,
            32'hd807aa98, 32'h12835b01, 32'h243185be, 32'h550c7dc3,
            32'h72be5d74, 32'h80deb1fe, 32'h9bdc06a7, 32'hc19bf174,
            32'he49b69c1, 32'hefbe4786, 32'h0fc19dc6, 32'h240ca1cc,
            32'h2de92c6f, 32'h4a7484aa, 32'h5cb0a9dc, 32'h76f988da,
            32'h983e5152, 32'ha831c66d, 32'hb00327c8, 32'hbf597fc7,
            32'hc6e00bf3, 32'hd5a79147, 32'h06ca6351, 32'h14292967,
            32'h27b70a85, 32'h2e1b2138, 32'h4d2c6dfc, 32'h53380d13,
            32'h650a7354, 32'h766a0abb, 32'h81c2c92e, 32'h92722c85,
            32'ha2bfe8a1, 32'ha81a664b, 32'hc24b8b70, 32'hc76c51a3,
            32'hd192e819, 32'hd6990624, 32'hf40e3585, 32'h106aa070,
            32'h19a4c116, 32'h1e376c08, 32'h2748774c, 32'h34b0bcb5,
            32'h391c0cb3, 32'h4ed8aa4a, 32'h5b9cca4f, 32'h682e6ff3,
            32'h748f82ee, 32'h78a5636f, 32'h84c87814, 32'h8cc70208,
            32'h90befffa, 32'ha4506ceb, 32'hbef9a3f7, 32'hc67178f2
        };
    end else begin
        buffer <= buffer_shifted;
    end
end

endmodule





