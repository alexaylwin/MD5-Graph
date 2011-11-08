function md5_passwords()
tic;
disp('MD5 WORDLIST HASH FUNCTION');
file_in_name = input('Wordlist input: ', 's');
file_out_name = input('Hash output file: ', 's');
file_in = fopen(file_in_name);
c = textscan(file_in, '%s');
fclose(file_in);
n_words = length(c{1});
disp('Word count:');
disp(n_words);
disp('');

file_out = fopen(file_out_name, 'wt');
disp('Starting hash');
for i = 1:1:n_words
%for i = 1:1:10
    curr = md5(c{1}{i});
    fprintf(file_out,'%s\n',curr);
    disp(i);
end

fclose(file_out);
toc;

end