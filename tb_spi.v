`timescale 1ns/1ps
`include"spi.v"
module tb;
parameter MAX_TXN=8;
parameter WIDTH=8;

parameter S_IDLE=5'b0_0001;
parameter S_ADDR=5'b0_0010;
parameter S_IDLE_BTN_ADDR_DATA=5'b0_0100;
parameter S_DATA=5'b0_1000;
parameter S_EXTRA_TXN_PENDING=5'b1_0000;

reg pclk;
reg prst;
reg penable;
reg [WIDTH-1:0]pwdata;
reg [WIDTH-1:0]paddr;
reg pwr_rd;
reg sclk_ref;
reg miso;

wire [WIDTH-1:0] prdata;
wire pready;
wire mosi;
wire sclk;
wire [3:0] cs;
integer i;
reg [8*100:0] size;


spi dut(pclk,prst,pwdata,paddr,penable,pready,pwr_rd,prdata,sclk_ref,sclk,mosi,miso,cs);

// clock generation
always begin 
	pclk=0;#5;
	pclk=1;#5;
end
always begin 
	sclk_ref=0;#10;
	sclk_ref=1;#10;
end


task reset();
begin 
	penable=0;
	paddr=0;
	pwdata=0;
	pwr_rd=0;
	miso=1;
	sclk_ref=0;
end
endtask

task write(input reg [7:0]addr,input reg [7:0]data);
begin 
	@(posedge pclk);
	pwr_rd=1;
	paddr=addr;
	pwdata=data;
	penable=1;
	wait(pready==1);
	@(posedge pclk);
	pwr_rd=0;
	paddr=0;
	pwdata=0;
	penable=0;
end
endtask

initial begin 
	prst=1;
	reset();
	repeat(2)@(posedge pclk);
	prst=0;

	//addr_regA
	for(i=0;i<MAX_TXN;i=i+1)begin
		write(i,i+8'hd3);//0-d3//1-d4//2-d5//3-d6
	end
	
	//data_regA
	for(i=0;i<MAX_TXN;i=i+1)begin
		write(i+8'h10,i+8'h12);//10-12//11-13//12-14
	end

	//Control Register
	//write(8'h20,{8'b0_000_111_1});//0_000_000_1
	$value$plusargs("size=%s",size);
		case(size)
			"full":begin 
				write(8'h20,{8'b0_000_111_1});
			end
			"half":begin 
				write(8'h20,{8'b0_000_011_1});
			end
			"half_starting_from_4":begin 
				write(8'h20,{8'b0_100_011_1});
			end
			"first_one":begin 
				write(8'h20,{8'b0_000_000_1});
			end
			"last_one":begin 
				write(8'h20,{8'b0_111_000_1});
			end
		endcase
	#1000;

	//Ending Simulation
	#5000;
	$finish;end
endmodule
