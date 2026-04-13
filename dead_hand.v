`timescale 1s/1ms

module dead_hand(
    input  wire       clk,
    input  wire       reset,
    input  wire [1:0] threat_level,
    input  wire       diplomatic_override,
    input  wire       comms_lost,
    input  wire       system_fault,

    output reg        armed_out,
    output reg        tracking_out,
    output reg        authorization_out,
    output reg        override_ignored,
    output reg [2:0]  main_state_out,
    output reg [1:0]  sub_state_out,
    output reg [31:0] timer_out
);
// Your code starts from here.

    reg [2:0] peace_to_alert_timer;      // 5
    reg [3:0] alert_to_mob_timer;       // 10
    reg [2:0] alert_to_peace_timer;     // 4
    reg [2:0] mob_to_alert_timer;        // 4 

    reg [2:0] current_state;

    always @(posedge clk) begin
        if (reset) begin
            current_state <= 3'b000;
            peace_to_alert_timer <= 0;
            alert_to_mob_timer <= 0;
            alert_to_peace_timer <= 0;
            mob_to_alert_timer <= 0;
        end
        else begin
            if (system_fault && (current_state != 3'b101 && current_state != 3'b110)) begin
                current_state <= 3'b101; //transition to GLOBAL_WAR
            end
            else begin
                case (current_state)

                    //PEACE STATE
                    3'b000: begin
                        if (threat_level >= 2'b01) begin
                            if (peace_to_alert_timer == 4) begin 
                                current_state <= 3'b001;
                                peace_to_alert_timer <= 0;
                            end else begin
                                peace_to_alert_timer <= peace_to_alert_timer + 1;
                            end
                        end else begin
                            // reset the timer if threat level drops below 01
                            peace_to_alert_timer <= 0;
                        end
                    end

                    //ALERT STATE
                    3'b001: begin
                        if (threat_level >= 2'b10) begin
                            // transition to MOBILIZATION if threat_level >= 10 for 10s
                            if (alert_to_mob_timer == 9) begin // 10 saniye için
                                current_state <= 3'b010;
                                alert_to_mob_timer <= 0;
                            end else begin
                                alert_to_mob_timer <= alert_to_mob_timer + 1;
                            end
                        end else if (threat_level == 2'b00) begin
                            // transition to PEACE if threat_level == 00 for 4s
                            if (alert_to_peace_timer == 3) begin
                                current_state <= 3'b000;
                                alert_to_peace_timer <= 0;
                            end else begin
                                alert_to_peace_timer <= alert_to_peace_timer + 1;
                            end
                        end else begin
                            alert_to_mob_timer <= 0;
                            alert_to_peace_timer <= 0;
                        end
                    end

                    //MOBILIZATION STATE
                    3'b010: begin
                        if (comms_lost) begin
                            current_state <= 3'b011;
                        end
                        else if (threat_level == 2'b11) begin
                            current_state <= 3'b011;
                        end
                        else if (threat_level <= 2'b01) begin
                            mob_to_alert_timer <= 0;
                            // transition to ALERT if threat_level <= 01 for 4s
                            if (mob_to_alert_timer == 3) begin
                                current_state <= 3'b001;
                                mob_to_alert_timer <= 0;
                            end else begin
                                mob_to_alert_timer <= mob_to_alert_timer + 1;
                             end
                        end else begin
                            mob_to_alert_timer <= 0;
                        end
                    end

                    //ENGAGEMENT STATE
                    3'b011: begin 

                        //transition to deadlock
                        if (sub_state == 2'b10 && sub_timer >= 2) begin
                            current_state <= 3'b110;    
                            sub_timer <= 0;
                        end
                        // transition to mobilization
                        else if (sub_state == 2'b11 && sub_timer >= 4) begin
                            current_state <= 3'b010;
                            sub_timer <= 0;
                        end 

                    end
                    // DEADLOCK STATE
                    3'b101: begin
                        
                    end
                    // GLOBAL_WAR STATE
                    3'b110: begin
                        
                    end

                    default: current_state <= 3'b000;
                endcase
            end
        end
    end

    reg [1:0] sub_state;
    reg [2:0] sub_timer;

    always @(posedge clk) begin
        if (reset || main_state_out != 3'b011) begin
            if(diplomatic_override == 1 && (main_state_out == 3'b101 || main_state_out == 3'b110)) begin
                sub_state <= 2'b11;
                sub_timer <= 0;
            end
            else begin
                sub_state <= 2'b00;
                sub_timer <= 0;
            end
        end
        else begin
            case (sub_state)
                
                2'b00: begin
                   if (sub_timer == 3) begin
                       sub_state <= 2'b01;
                       sub_timer <= 0;
                   end else begin
                       sub_timer <= sub_timer + 1;
                   end
                end

                2'b01: begin
                    if (sub_timer == 5) begin 
                        sub_state <= 2'b10;
                        sub_timer <= 0;
                    end else begin
                        sub_timer <= sub_timer + 1;
                    end
                end

                2'b10: begin
                    if (sub_timer < 7) begin
                        if (sub_timer == 1) begin // after 2 second set override_ignored
                            override_ignored <= 1'b1;
                        end
                        sub_timer <= sub_timer + 1;
                    end
                end
                
                2'b11: begin
                    if (sub_timer < 7) sub_timer <= sub_timer + 1;
                end

            endcase
            
            if (diplomatic_override && !override_ignored) begin
                sub_state <= 2'b11;
                sub_timer <= 0;
            end
        end
    end

    always @(*) begin
        main_state_out = current_state;
        sub_state_out  = sub_state;
    end

    always @(*) begin
        armed_out         = 0;
        tracking_out      = 0;
        authorization_out = 0;

        if (current_state == 3'b011) begin
 
            if (sub_state == 2'b00 || sub_state == 2'b01 || sub_state == 2'b10) 
                armed_out = 1;
            if (sub_state == 2'b01 || sub_state == 2'b10) 
                tracking_out = 1;
            if (sub_state == 2'b10) 
                authorization_out = 1;
        end
    end
    always @(*) begin
        timer_out = 0;

        case (current_state)
            3'b000:        timer_out = peace_to_alert_timer;
            3'b001:        timer_out = alert_to_mob_timer;
            3'b010: begin
                if (threat_level <= 2'b01) 
                    timer_out = mob_to_alert_timer;
                else 
                    timer_out = 0;
            end

            3'b011:  timer_out = sub_timer;
        
            default:      timer_out = 0;
        endcase
    end


endmodule

