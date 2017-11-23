% Kp = 0.1, Kd = 0.001, I_max = 5A, Iz = 14e-6
% Output Y
clc
close all

% load angle data from test
run('data.m')

% prepare input output matrices
size(y)
u = [ones(250,1)*180; ones(250,1)*90; ones(249,1)*180];

% Create data model from input output data
data_model = iddata(y,u,0.002);

% Estimate 2-pole transfer function
sys = tfest(data_model,2)

% plot step response against actual response
step(sys)
y_sim = step(sys);

figure
plot(y(500:end))
hold on
plot(y_sim*90+90)
legend('actual','sim')


% Simulate the response for the entire step routine
y_sim_whole = sim(sys,u);

% state space model for fun
ss_model = ssest(data_model,2)


% Plot simulated response using transfer function estimate
figure

time = [0:0.002:1.496];
plot(time,y)
hold on
plot(time,y_sim_whole)
legend('actual','sim')
title('Actual motor angle vs TF simulated motor angle')
