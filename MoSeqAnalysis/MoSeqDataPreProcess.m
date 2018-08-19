load('my_model.mat');

for iter=1:16
    eval(['MSLabels{' num2str(iter) '}=MSlabels' num2str(iter) ';']);
end

for iter=1:16
    MSLabels{iter}=double(MSLabels{iter});
end
clearvars -except MSLabels MSid
save('ModelData.mat')