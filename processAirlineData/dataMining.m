 %-------------------------------------------------------------------
 % This program: load the excel file
 %               read the task time table grouped by desks
 %               write the task arrive interval into excel files
 %
 % Please put the .xlsx file in the same folder with this program
 %-------------------------------------------------------------------
 
 table = readtable('Delta workload_20180426.xlsx');
 table_num = size(table,1);
 
 desk = unique(table.Desk);
 desk_num = size(desk,1);
 
 RLStime = table.RLSTIME;
 
for desk_name = 2 : desk_num
    filename = strcat('task_input/desk_',desk{desk_name});
    time = [];
    for i = 1 : table_num
        if strcmp(table.Desk{i}, desk{desk_name})
            if RLStime(i,1) < 1
                time = [time;RLStime(i,1)];
            else
                time = [time;RLStime(i,1)-1];
            end
        end
    end
    time = sort(time);
    temp = [time;0] - [0;time];
    result = temp(2:size(temp,1)-1,:) * 1440;
    xlswrite(filename, result);
end