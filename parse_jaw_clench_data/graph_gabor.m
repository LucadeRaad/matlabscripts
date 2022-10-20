function graph_gabor(raw_data, n, overlap)
%GRAPH_GABOR Summary of this function goes here
%   Detailed explanation goes here

for index = 1:length(raw_data)
    output = gabor_transformation(raw_data{index}, n, overlap);

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

        graph(:,gindex) = raw_data{index}(:,jindex);

        graph(:,gindex + 1) = output(:,jindex);
    end
    
    figure(index);
    stackedplot(graph);
end


end

