function plotter
x = [1:1200000];

% figure
% for n = 1:9
% subplot(9,1,n)
% plot(x, amplifier_data(n,1:120000))
% end

figure
i=1
for n = [1,8,2,7,3,6,5,4]
    subplot(9,1,i)
plot(x, amplifier_data(n,1:1200000))
i=i+1
end
end