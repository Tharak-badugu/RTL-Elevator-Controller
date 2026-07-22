module elevator (input rst,clk,emergency_stop,
input [3:0]floor_req,
output reg up,                    // motor rotating upwards
output reg down,                 // motor rotating downwards
output reg motor_stop,            // motor stops
output reg [1:0] current_floor       //used to hold the current floor
);
//declaring the states for fsm
parameter idle =2'b00;
parameter move_up=2'b01;
parameter move_down=2'b10;
parameter emergency=2'b11;

reg [1:0] present_state, next_state;
reg [1:0] target_floor;              //holds the user input 0,1,2,3 floors

always@(posedge clk or posedge rst) begin
    if(rst) begin
present_state<=idle;
    end
else begin
    present_state<=next_state;
end
end
//FSM logic
always @(*)begin
    next_state=present_state;    //deafult logic to prevent latches

    if(emergency_stop) begin                      
        next_state=emergency;                 ///if emergency detects,  elevator stops instantly(top priority)
    end
    else begin
        case(present_state)
        idle: begin
            if(target_floor>current_floor) begin
                next_state=move_up;                          //moving to up
            end
            else if(target_floor<current_floor)begin
                next_state=move_down;                        //moving to down
            end
        end
        move_up: begin
            if(current_floor == target_floor) begin
                next_state= idle;                                  //floor reached, the state set to idel
            end 
                else begin
                    next_state=move_up;                            //not reached yet, still moving up
                end
        end
        move_down: begin
            if(current_floor == target_floor) begin
                next_state= idle;                                  //floor reached, the state set to idel
            end
            else begin
                next_state= move_down;                             // not reached yet, still moving down
            end
        end
        emergency: begin
            if(emergency_stop) begin
                next_state= emergency;                             //emergency detected
            end
            else begin
                next_state= idle;
            end
        end
        default : next_state=idle;
        endcase
    end
end
    //priority logic from the user
    always@(*) begin
        target_floor=current_floor;

       if(floor_req[0])begin
        target_floor=2'd0;                                      // user requested the floor 0(target loaded)
       end
       else if(floor_req[1])begin
        target_floor=2'd1;                                      // user requested the floor 1(target loaded)
       end
       else if(floor_req[2])begin
        target_floor=2'd2;                                      // user requested the floor 2(target loaded)
       end
       else if(floor_req[3]) begin
        target_floor=2'd3;                                      // user requested the floor 3(target loaded)
       end
    end
//floor increment logic 
always @(posedge clk or posedge rst) begin
    if (rst) begin
        current_floor <= 2'd0;
    end 
    else if (next_state == move_up && current_floor != target_floor) begin
        current_floor <= current_floor + 1'b1;
    end 
    else if (next_state == move_down && current_floor != target_floor) begin
        current_floor <= current_floor - 1'b1;
    end
end

// output logic
    always@(*) begin
        //initializing outputs
        up=1'b0;              
        down=1'b0;
        motor_stop=1'b0;

        case(present_state)
        idle:motor_stop=1'b1;
        move_up:up=1'b1;
        move_down:down=1'b1;
        emergency:motor_stop=1'b1;
        default: motor_stop=1'b1;
        endcase
    end
endmodule

        


     
