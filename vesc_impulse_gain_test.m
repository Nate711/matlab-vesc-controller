%% INIT
instrreset;
clc;
close all;

%% Start serial
teensy = init_serial();

%% Reset teensy and begin
reset_teensy(teensy);
pause(0.1);

begin_teensy(teensy);
pause(0.1);

start_encoder(teensy);
pause(0.01);

%% Send initial 180 command
send_vesc_command(teensy,180.0, 0.1, 0.001);

%% Clear serial
% discard (by reading) all the bytes in the input buffer
fread(teensy, teensy.BytesAvailable);

%% Begin reading data from teensy

phase1_angle = 180.0;
phase2_angle = 90.0;
phase3_angle = 180.0;
Kp = 0.1;
Kd = 0.001;

% Set up phase variable
% 0 = init program
% 0-500ms: 1 = 180
% 500-1000ms: 2 = 90
% 1000-1500ms: 3 = 180
% >1500ms; 4 = exit and estop
phase = 0;

% Set up storage variables
duration = 3; % seconds
avg_sampling_freq = 1000; % how many samples/sec the teensy sends
time_onboard = NaN(duration*avg_sampling_freq,1);
encoder_readings = time_onboard;
index = 1;

% Start stop watch for timing purposes
start = tic;

% Execute for 2 seconds
while toc(start)*1000.0 < 2000.0
    s = fgetl(teensy);
    millis = toc(start)*1000.0;        
%     fprintf('Time: %f Angle: %s\n',toc,s);
    
    split_str = split(s,' ');
    % Attempt reading encoder angle
    angle = str2double(split_str(2));
    t = str2double(split_str(1));
    if ~isnan(angle)
        encoder_readings(index) = angle;
        time_onboard(index) = t;
        index = index + 1;
    else
        % display non-angle messages to console
        disp(s);
    end  
    
    if phase == 0
        send_vesc_command(teensy,phase1_angle,Kp,Kd);
        phase = 1;
    elseif phase == 1 && millis > 500.0
        send_vesc_command(teensy,phase2_angle,Kp,Kd);
        phase = 2;
    elseif phase == 2 && millis > 1000.0
        send_vesc_command(teensy,phase3_angle,Kp,Kd);    
        phase = 3;
    elseif phase == 3 && millis > 1500.0
        break;
    end
end

%% Stop encoder and estop and close serial
stop_encoder(teensy);

estop_teensy(teensy);

close_serial(teensy);

%% Helper functions
function send_vesc_command(ser_port, pos, kp, kd)
    str = sprintf('G1 X%4.2f P%1.4f D%1.4f',pos,kp,kd);
    fprintf(ser_port,str);
end
    
function close_serial(port)
    fclose(port);
    delete(port);
    clear port
end

function port = open_port()
    port = serial('/dev/tty.usbmodem3018921','BaudRate',115200, 'Timeout',0.002);
end

function serial_port = init_serial()
    serial_port = open_port();
    fopen(serial_port);
    delete(serial_port);
    clear serial_port
    serial_port = open_port();
    fopen(serial_port);
    
    pause(1.0);
end

function flush_all(ser_port)
end

function reset_teensy(ser_port)
    fprintf(ser_port, 'r\n');
end

function begin_teensy(ser_port)
    fprintf(ser_port, 'b\n');
end

function start_encoder(ser_port)
    fprintf(ser_port, 'e\n');
end

function stop_encoder(ser_port)
    fprintf(ser_port,'!e\n');
end

function estop_teensy(ser_port)
    fprintf(ser_port,'s\n');
end
    