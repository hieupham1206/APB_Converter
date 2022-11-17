module blackbox(
	input clk,
	input resetn,
	input [7:0] paddr,
	input pwrite,
	input psel  ,
	input penable,
	input [7:0] pwdata,
	output reg [7:0] prdata,
	output reg pready
);
	reg [2:0] state;

	localparam IDLE 		= 3'b000;
	localparam WRITE 		= 3'b001;
	localparam READ 		= 3'b010;
	localparam READY_WRITE 	= 3'b011;
	localparam READY_READ 	= 3'b100;
	localparam FINISH 		= 3'b101;

	always@(posedge clk or negedge resetn) begin
		if(!resetn) begin
			state	<= IDLE;
			pready	<= 1'b0;
			prdata	<= {8{1'b0}};
		end
		else begin
			case(state)
				IDLE: begin
					if(psel) begin
						if(penable) begin
							$display("FALSE. TOO EARLY PENABLE RAISED");
							$finish;
						end
						else if(pwrite) begin
							state	<= WRITE;
						end
						else begin
							state	<= READ;
						end
					end
					else begin
						state	<= IDLE;
					end
				end
				WRITE: begin
					if(penable) begin
						state	<= READY_WRITE;
					end
					else begin
						$display("FALSE. NO PENABLE DETECTED");
						$finish;
					end
				end
				READ: begin
					if(penable) begin
						state	<= READY_READ;
					end
					else begin
						$display("FALSE. NO PENABLE DETECTED");
						$finish;
					end
				end
				READY_WRITE: begin
					pready	<= 1'b1;
					state	<= FINISH;
				end
				READY_READ: begin
					pready	<= 1'b1;
					prdata	<= {8{1'b1}};
					state	<= FINISH;
				end
				FINISH: begin
					pready	<= 1'b0;
					prdata	<= {8{1'b0}};
					state	<= IDLE;
				end
			endcase
		end
	end
endmodule