function output = graph_model(KNN, path, title)
    data = clean_data(path);

    [~, score] = predict(KNN, data);

    data = [data score];

    data(:,end:end) = [];

    fig = figure("Name", title);
    stackedplot(data);
    
    output = fig;
end