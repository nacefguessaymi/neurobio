%Probe Dimensions
%Parylene upper layer 10µm
%Gold layer 100nm
%Pt layer 10nm
%Parylene upper layer 10µm
%16CV2_1K_4_2





function F = euler_calculator(Eu,w,t,L,k)
    F = (pi^2*Eu*w*t^3)/(12*(k*L)^2);

end
% Eu = 2.76e9;
% w = 128e-6;
% t = 10e-6;
% L = 0.5e-3;
% k = 2;
% 
