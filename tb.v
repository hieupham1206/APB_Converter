module tb();
	reg clk;
	reg resetn;
	reg write_req_gen;
	reg [7:0] write_data_gen;
	reg [7:0] write_addr_gen;
	reg read_req_gen;
	reg [7:0] read_addr_gen;

	wire clk_connect;
	wire resetn_connect;
	wire [7:0] connect_paddr;
	wire connect_pwrite;
	wire connect_psel;
	wire connect_penable;
	wire [7:0] connect_pwdata;
	wire [7:0] connect_prdata;
	wire connect_pready;

	wire write_req;
	wire [7:0] write_data;
	wire [7:0] write_addr;
	wire write_ack;

	wire read_req;
	wire [7:0] read_data;
	wire [7:0] read_addr;
	wire read_ack;


	assign write_req  = write_req_gen;
	assign write_data = write_data_gen;
	assign write_addr = write_addr_gen;
	assign read_req   = read_req_gen;
	assign read_addr  = read_addr_gen;

	initial begin
		clk = 1'b0;
		forever begin
			#10 clk = ~clk;
		end
	end

	initial begin
		resetn = 1'b0;
		repeat(10) @(posedge clk);
		resetn = 1'b1;
		write_req_gen = 1'b0;
		write_data_gen = 8'h00;
		write_addr_gen = 8'h00;
		read_req_gen = 1'b0;
		read_addr_gen = 8'h00;
		repeat(10) @(posedge clk);

		write_req_gen = 1'b1;
		write_data_gen = 8'hAC;
		write_addr_gen = 8'hCC;
		@(posedge write_ack);
		if((write_data_gen != connect_pwdata)|(write_addr_gen != connect_paddr)) begin
			$display("FAIL -- <WRITE> addr: %x -- data: %x", connect_paddr, connect_pwdata);
		end
		else begin
			$display("PASS -- <WRITE> addr: %x -- data: %x", connect_paddr, connect_pwdata);
		end
		@(posedge clk);
		write_req_gen = 1'b0;
		write_data_gen = 8'h00;
		write_addr_gen = 8'h00;

		repeat(1) @(posedge clk);

		write_req_gen = 1'b1;
		write_data_gen = 8'h50;
		write_addr_gen = 8'hF5;
		@(posedge write_ack);
		if((write_data_gen != connect_pwdata)|(write_addr_gen != connect_paddr)) begin
			$display("FAIL -- <WRITE> addr: %x -- data: %x", connect_paddr, connect_pwdata);
		end
		else begin
			$display("PASS -- <WRITE> addr: %x -- data: %x", connect_paddr, connect_pwdata);
		end
		repeat(1) @(posedge clk);
		write_req_gen = 1'b0;
		write_data_gen = 8'h00;
		write_addr_gen = 8'h00;

		repeat(1) @(posedge clk);
		read_req_gen = 1'b1;
		read_addr_gen = 8'h55;
		@(posedge read_ack);
		if((read_addr_gen != connect_paddr)|(read_data != 8'hff)) begin
			$display("FAIL -- <READ> addr: %x -- data: %x", connect_paddr, read_data);
		end
		else begin
			$display("PASS -- <READ> addr: %x -- data: %x", connect_paddr, read_data);
		end
		@(posedge clk);
		read_req_gen = 1'b0;
		read_addr_gen = 8'h00;

		@(posedge clk);
		$finish;
	end

	assign clk_connect = clk;
	assign resetn_connect = resetn;

	apb_converter inst_apb_converter(
		.pclk 		(clk_connect),
		.presetn 	(resetn_connect),
		// port to master
		.write_req	(write_req),
		.write_data (write_data),
		.write_addr (write_addr),
		.write_ack	(write_ack),
		.read_req	(read_req),
		.read_addr	(read_addr),
		.read_data 	(read_data),
		.read_ack	(read_ack),
		// port to slave
		.paddr 		(connect_paddr),	// 8 bit
		.pwrite		(connect_pwrite),
		.psel		(connect_psel),
		.penable	(connect_penable),
		.pwdata		(connect_pwdata), // 8 bit
		.prdata		(connect_prdata), // 8 bit
		.pready		(connect_pready)
	);

	blackbox instr_blackbox(
		.clk 		(clk_connect),
		.resetn 	(resetn_connect),
		.paddr 		(connect_paddr),
		.pwrite		(connect_pwrite),
		.psel		(connect_psel),
		.penable	(connect_penable),
		.pwdata		(connect_pwdata), // 8 bit
		.prdata		(connect_prdata), // 8 bit
		.pready		(connect_pready)
	);

endmodule