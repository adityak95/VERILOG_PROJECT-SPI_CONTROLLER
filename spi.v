module spi(pclk,prst,pwdata,paddr,penable,pready,pwr_rd,prdata,sclk_ref,sclk,mosi,miso,cs);

parameter MAX_TXN=8;
parameter WIDTH=8;

parameter S_IDLE=5'b0_0001;
parameter S_ADDR=5'b0_0010;
parameter S_IDLE_BTN_ADDR_DATA=5'b0_0100;
parameter S_DATA=5'b0_1000;
parameter S_EXTRA_TXN_PENDING=5'b1_0000;

input pclk;
input prst;
input penable;
input [WIDTH-1:0]pwdata;
input [WIDTH-1:0]paddr;
input pwr_rd;
input sclk_ref;
input miso;

output reg [WIDTH-1:0] prdata;
output reg pready;
output reg mosi;
output sclk;
output reg [3:0] cs;

// SPI registers
reg [WIDTH-1:0]addr_reg [MAX_TXN-1:0];
reg [WIDTH-1:0]data_reg [MAX_TXN-1:0];
reg [WIDTH-1:0]ctrl_reg;

// extra register
reg [4:0] present_state,next_state;
integer i,count;
reg [3:0]num_txn_pending;  //[3:1]+1
reg [2:0]current_txn_index;
reg [WIDTH-1:0]data_rxn;
reg [WIDTH-1:0]data_txn;
reg [WIDTH-1:0]addr_txn;
reg sclk_running_flag;



always@(posedge pclk)begin 
	if(prst==1)begin 
		prdata=0;
		pready=0;
		mosi=1;
		cs=3'b001;
		next_state=S_IDLE;
		present_state=S_IDLE;
		ctrl_reg=0;
		count=0;
		for(i=0;i<MAX_TXN;i=i+1)begin 
			addr_reg[i]=0;		
			data_reg[i]=0;		
		end
		data_rxn=0;
		data_txn=0;
		addr_txn=0;
		sclk_running_flag=0;
		num_txn_pending=0;
		current_txn_index=0;
	end
	else begin 
		if(penable)begin 
			pready=1;
			if(pwr_rd)begin 
				if(paddr>=8'h00 && paddr<=8'h07)begin
					addr_reg[paddr]=pwdata;		
				end
				if(paddr>=8'h10 && paddr<=8'h17)begin
					data_reg[paddr-8'h10]=pwdata;		
				end
				if(paddr==8'h20)begin
					ctrl_reg=pwdata;
				end
			end
			else begin 
				if(paddr>=8'h0 && paddr<=8'h7)begin
					prdata=addr_reg[paddr];		
				end
				if(paddr>=8'h10 && paddr<=8'h17)begin
					prdata=data_reg[paddr-8'h10];		
				end
				if(paddr==8'h20)begin
					prdata=ctrl_reg;
				end
			end
		end
	end

end

//clock generation
assign sclk=sclk_running_flag ? (sclk_ref) : (1'b1);

// SPI as state machine

always@(posedge sclk_ref)begin 
		if(prst!=1)begin 
			case(present_state)
				S_IDLE:begin 
					sclk_running_flag=0;
					mosi=1;
					if(ctrl_reg[0]==1)begin 
						count=0;
						num_txn_pending=ctrl_reg[3:1]+1;
						current_txn_index=ctrl_reg[6:4];
						addr_txn=addr_reg[current_txn_index];
						data_txn=data_reg[current_txn_index];
						next_state=S_ADDR;

					end
				end
				S_ADDR:begin 
					sclk_running_flag=1;
					mosi=addr_txn[count];
					count=count+1;
					if(count==8)begin 
						count=0;
						next_state=S_IDLE_BTN_ADDR_DATA;
					end
				end
				S_IDLE_BTN_ADDR_DATA:begin 
					sclk_running_flag=0;
					mosi=1;
					count=count+1;
					if(count==4)begin 
						count=0;
						next_state=S_DATA;
					end
				end
				S_DATA:begin
					sclk_running_flag=1;
					if(addr_txn[WIDTH-1]==1)begin 
						mosi=data_txn[count];
						count=count+1;
					end
					else begin 
						data_rxn[count]=miso;
						count=count+1;
					end
					if(count==8)begin 
						current_txn_index=current_txn_index+1;
						num_txn_pending=num_txn_pending-1;
						if(num_txn_pending==0)begin
							count=0;
							ctrl_reg[WIDTH-1]=1;
							ctrl_reg[0]=0;
							next_state=S_IDLE;
						end
						else begin 
							count=0;
							next_state=S_EXTRA_TXN_PENDING;
						end
					end
				end
				S_EXTRA_TXN_PENDING:begin 
					sclk_running_flag=0;
					mosi=1;
					count=count+1;
					if(count==4)begin 
						count=0;
						addr_txn=addr_reg[current_txn_index];
						data_txn=data_reg[current_txn_index];
						next_state=S_ADDR;
					end
				end
			endcase
		end
end

//updating states in state machine

always@(next_state)begin 
	present_state=next_state;
end
endmodule
