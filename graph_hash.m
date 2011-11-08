function graph_hash()

    file_in_name = input('Hash file: ', 's');
    file_in = fopen(file_in_name);

    c = textscan(file_in, '%s');
    fclose(file_in);

    n_words = length(c{1});
    disp('Hash count:');
    disp(n_words);
    disp('starting arrays');
    X = [0];
    Y = [0];
    tic;
    
    for i = 1:1:n_words
        curr = c{1}{i};
        temp = hex2dec(curr(9:16));
        X = [X; temp];
        temp = hex2dec(curr(1:8));
        Y = [Y; temp];
    end
    disp('done making arrays');
    disp('starting scatter');
    scatter(X, Y, 2);
    disp('done scatter');
    toc;

end