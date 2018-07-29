plot_fs=1;
plot_fe=18000;
figure(1)
periodogram(Labels_H1(plot_fs:plot_fe,18))

figure(2)

periodogram(Labels(plot_fs:plot_fe,22))
