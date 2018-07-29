subplot(2,1,1);
plot(Labels(plot_fs:plot_fe,1)./1800,Labels(plot_fs:plot_fe,17),'linewidth',2);
hold on
plot(Labels(plot_fs:plot_fe,1)./1800,Labels(plot_fs:plot_fe,18),'linewidth',2);
hold on
plot(Labels(plot_fs:plot_fe,1)./1800,Labels(plot_fs:plot_fe,19),'linewidth',2);
hold on
plot(Labels(plot_fs:plot_fe,1)./1800,Labels(plot_fs:plot_fe,20),'linewidth',2);
title(['Distance (first 3min) radius=' num2str(radius)]);
xlabel('time min')
ylabel('Distance pixels')

diff_dis=80;
Y= Labels((plot_fs+diff_dis):(plot_fe+diff_dis),17)-Labels(plot_fs:plot_fe,17);
Y0=zeros(1,5400)
subplot(2,1,2);
plot(Labels(plot_fs:plot_fe,1)./1800,Y,'linewidth',2);
hold on
plot(Labels(plot_fs:plot_fe,1)./1800,Y0,'linewidth',2);
title(['Velocity (first 3min) radius=' num2str(radius)]);
xlabel('time min')
ylabel('Velocity pixels/s')