function file_path = file_name( class_name, folder_name, iteration )
%FILE_NAME Takes a class name and formats it to be used by saveas

% remove ponctuation and spaces
file_path = regexprep(class_name, '[^A-Za-z ]', '');
file_path = regexprep(file_path, '\s+', '-');
file_path = lower(file_path);

% Crop name
file_path = file_path(1: min(20, length(file_path)) );

file_path = strcat(folder_name, '/', file_path, '-iter-', string(iteration));
end

