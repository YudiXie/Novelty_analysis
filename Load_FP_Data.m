function [cart_GCaMP, cart_tdTom, cart_water] = Load_FP_Data(fpath)
disp(['load_photometry_raw: ' fpath]);
file_ID = fopen(fpath, 'r');
CC_cart_analog = fread(file_ID, inf, 'double', 0, 'b');
fclose(file_ID);

if isempty(CC_cart_analog)
    cart_GCaMP = []; cart_tdTom = []; cart_water = [];
    return;
end

A = reshape(CC_cart_analog, 2, [ ]);
B = reshape (A, 2, 3, [ ]);

cart_GCaMP = B (:,1,:);
cart_GCaMP = reshape (cart_GCaMP,[],1);

cart_tdTom = B (:,2,:);
cart_tdTom = reshape (cart_tdTom,[],1);

cart_water = B (:,3,:);
cart_water = reshape (cart_water,[],1);