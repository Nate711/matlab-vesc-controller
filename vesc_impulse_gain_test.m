instrreset;
clc;
close all;

teensy = open_serial();

reset_teensy(teensy);
pause(0.1);

begin_teensy(teensy);
pause(0.1);

send_vesc_command(teensy,180.0, 0.1, 0.001);

pause(2.0);

estop_teensy(teensy);

close_serial(teensy);

function send_vesc_command(ser_port, pos, kp, kd)
    str = sprintf('G1 X%4.2f P%1.4f D%1.4f',pos,kp,kd);
    fprintf(ser_port,str);
end
    
function close_serial(port)
    fclose(port);
end

function serial_port = open_serial()
    serial_port = serial('/dev/tty.usbmodem3018921','BAUD',115200);
    fopen(serial_port);
    delete(serial_port)
    clear serial_port
    serial_port = serial('/dev/tty.usbmodem3018921','BAUD',115200);
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
    




