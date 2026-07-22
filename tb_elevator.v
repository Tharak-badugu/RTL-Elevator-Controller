`timescale 1ns / 1ps
`include "elevator.v"

module tb_elevator;
    reg rst;
    reg clk;
    reg emergency_stop;
    reg [3:0] floor_req;

    wire up;
    wire down;
    wire motor_stop;
    wire [1:0] current_floor;

    elevator uut (
        .rst(rst),
        .clk(clk),
        .emergency_stop(emergency_stop),
        .floor_req(floor_req),
        .up(up),
        .down(down),
        .motor_stop(motor_stop),
        .current_floor(current_floor)
    );
    //for gtk wave
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0,tb_elevator);
end

initial  begin
        clk=0;
        forever #5 clk=~clk;
    end

    initial begin
        rst = 1;               //resetting 
        //initializing to 0
        emergency_stop = 0;
        floor_req = 4'b0000;
        #10;
        rst = 0;               //releasing reset
        #20;
        //checkig that floor transition 0 to 2
        @(posedge clk);
        floor_req = 4'b0100; 
        
        wait(current_floor == 2'd2);          //reached to floor 2
        #10;
        floor_req = 4'b0000;    //clearing the request
        #20;                 
        //checkig the priority by giving user request to 1 and 3 floor simultaniously(currently at floor 2)
        @(posedge clk);
        floor_req = 4'b1010;          //first it will go to 1st floor beacuse of priority
        wait(current_floor == 2'd1);
        #10;
        floor_req = 4'b1000;           //reached to floor 1, now it should go to floor 3
        wait(current_floor == 2'd3);
        #20;
        //checking the emergency stop(currently at floor 3)
        @(posedge clk);
        floor_req = 4'b0001;           //requesting for floor 0
        
        #10; 
        @(posedge clk);
        emergency_stop = 1;             //applying emergency stop
    
        #20; 

        @(posedge clk);           
        emergency_stop = 0;              //releasing the emergency stop
        #20;
        
        wait(current_floor == 2'd0);             //reached to floor 0 beacuse emergency is cleared
        #10;
        floor_req = 4'b0000;                     //resttin the user request
        
        #80;
        $finish; 
    end

endmodule