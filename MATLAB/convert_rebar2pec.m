%% Grabs .in files in ./in_files_pec and converts all instances of rebar under shapes and replaces them with 'pec' material instead

%% 

fname = './in_files_pec/sim1.in';

fid=fopen(fname,'r');  % check for success in real life...

% Take everything as a string. Find instances of rebar after header.
% Replace

%% Gross way of skipping header lines
header_size = 18;
temp = '';
for i=1:header_size
   temp = strcat(temp, fgets(fid), '\n');    
end

%% Now go scan
while ~feof(fid)
    line = fgets(fid);
    new_line = strrep(line,'rebar','pec');
    temp = strcat(temp, new_line, '\n');
end
fclose(fid);

fid=fopen(fname,'w');
fprintf(fid, temp);
fid = fclose(fid);