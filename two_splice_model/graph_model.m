function fig = graph_model(model, path, title)
    data = clean_data(path);

    [~, score] = model.predictFcn(data);

    data = [data score];

    data(:,end:end) = [];

    fig = figure("Name", title);
    stackedplot(data);
end