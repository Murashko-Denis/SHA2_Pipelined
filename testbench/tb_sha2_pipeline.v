module tb_sha2_pipelined;

integer cnt = 0; //cnt clk
reg strobe = 0;
reg clk = 1'b0;
wire valid;
wire [255:0] hash_out;
integer file;

//"abc" test message, padded (80000 after message and calculate length message last 9 bytes)
wire [511:0] message_abc = {
  256'h6162638000000000000000000000000000000000000000000000000000000000,
  256'h0000000000000000000000000000000000000000000000000000000000000018
};

//"denis" test message, padded
wire [511:0] message_denis = {
  256'h64656e6973800000000000000000000000000000000000000000000000000000,
  256'h0000000000000000000000000000000000000000000000000000000000000028
};

// a null message
wire [511:0]  message_null = {
  256'h8000000000000000000000000000000000000000000000000000000000000000,
  256'h0000000000000000000000000000000000000000000000000000000000000000
};

sha2_pipelined sha2_pipelined (
    .clk(clk),
    .message(message_abc),
    .strobe(strobe),
    .hash_out(hash_out),
    .valid(valid)
);

initial begin
  file = $fopen("log_file.txt","w");
  $display("Start Simulation!");
  #10 strobe = 1'b1;
  #10 strobe = 1'b0;
end

initial begin
  repeat (140) begin //70 clk
    #5 clk =! clk;
	if (clk) begin
		cnt = cnt + 1;
		log;
		end
  end
  $display("Simulation Complite!");
  $stop;
  $fclose(file);
end

task log;
begin
  $display("%b %d", strobe, cnt);
  $display("%b %h", valid, hash_out);
  $fdisplay(file,"%b %d", strobe, cnt);
  $fdisplay(file,"%b %h", valid, hash_out);
end
endtask

endmodule 