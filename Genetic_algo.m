
xy = xlsread('location2');
userConfig = struct('xy',xy); 
resultStruct = tsp_ga(userConfig);