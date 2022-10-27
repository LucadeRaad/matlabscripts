function graph_gabor(raw_data, n, overlap, shouldBandPass, startIndex)
%GRAPH_GABOR Summary of this function goes here
%   Detailed explanation goes here

for index = 1:length(raw_data)
    output = gabor_transform(raw_data{index}, n, overlap, shouldBandPass);

    dp = find(output, 1);

    output(1:dp,:) = 0;

%     collapsed_output = sum(output, 2);
% 
%     % Take out all values below the median
%     mask = 4 / 5 * median(nonzeros(collapsed_output));
%     collapsed_output(collapsed_output < mask) = 0;
% 
%     mask = median(nonzeros(collapsed_output));
%     collapsed_output(collapsed_output < mask) = 0;

%    graph = [raw_data{index}, collapsed_output];

   graph = zeros(size([raw_data{index}, output]));

    for jindex = 1:width(raw_data{index})
        gindex = jindex - 1;
        gindex = gindex * 2;
        gindex = gindex + 1;

        graph(:,gindex) = bandpass(graph(:,gindex), [1, 50], 300);

        graph(:,gindex) = raw_data{index}(:,jindex);

        graph(:,gindex + 1) = output(:,jindex);
    end
    
    figure(index + startIndex);
    stackedplot(graph);
end


end

