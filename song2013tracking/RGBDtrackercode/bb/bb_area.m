function a = bb_area(bb)
    a = abs((bb(1,:)-bb(3,:)) .* (bb(2,:)-bb(4,:)));
end

