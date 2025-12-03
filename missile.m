clear all; close all; clc;

d2r = pi/180;

%target parameters
V_T = 900;
X_T0 = 110;
Z_T0 = 20000;
l_T0 = -2.5*d2r;

%missile 
X_M0 = 2000;
Z_M0 = 0;
l_M0 = 80*d2r;

%control loop gains 
Kdc = 1.1;
Ka = 4.5;
Ki = 14.3;
Kr = -0.37;