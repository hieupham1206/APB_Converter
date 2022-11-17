module apb_converter(
    input pclk,
    input presetn,
    
    input [7:0]write_addr,
    input [7:0]write_data,
    input write_req,
    output reg [7:0]pwdata,

    input pready,

    input read_req,
    input [7:0]read_addr,
    output reg [7:0]read_data,
    input  [7:0]prdata,

    output reg write_ack,
    output reg read_ack,
    output reg pwrite,
    output reg psel,
    output reg penable,
    output reg[7:0]paddr,
    output reg [1:0]stage
);

localparam IDLE = 2'b00;
localparam SETUP = 2'b01;
localparam ACCESS = 2'b10;
localparam WAIT = 2'b11;


always @(posedge pclk or negedge presetn) begin
    if(!presetn) begin
        stage <= IDLE;
        read_data <= 8'h00;
        write_ack <= 1'b0;
        read_ack <= 1'b0;
        pwrite <= 1'b0;
        psel <= 1'b0;
        penable <= 1'b0;
        pwdata <= 8'h00;
        paddr <= 8'h00;
    end
    else begin
        case(stage)
            IDLE:begin
                penable <= 0;
                if(write_req || read_req) begin
                    stage <= SETUP;
                end
                else begin
                stage <= IDLE; end
            end
            SETUP:begin
                psel <= 1;
                if(write_req) begin
                    pwdata <= write_data;
                    pwrite <= 1'b1;
                    paddr <= write_addr;
                    stage <= ACCESS;
                end
                else if (read_req) begin
                    pwrite <= 0;
                    paddr <= read_addr;
                    stage <= ACCESS;
                end
            end
            ACCESS:begin
                penable <= 1;
                if(pready) begin
                    if(write_req) begin
                    write_ack <= 1'b1;
                    psel <= 0;
                    penable <= 0;
                    pwrite <= 0;
                    stage <= WAIT;
                    end
                    else if(read_req) begin
                    read_ack <= 1'b1;
                    read_data <= prdata;
                    psel <= 0;
                    penable <=0;
                    stage <= WAIT;
                    end
                end
                else begin
                    stage <= ACCESS;
                end
            end
            WAIT: begin
                read_ack <= 1'b0;
                write_ack <= 1'b0;
                stage <= IDLE;
            end
      endcase
end
end
endmodule
