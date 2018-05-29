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
DepTime = table.Dptr;
ArrTime = table.Arvl;

Rresult_cell = {};
Aresult_cell = {};
Dresult_cell = {};

fileID1 = fopen('DeltaReleaseTimeDistributions.csv', 'w');
fileID2 = fopen('DeltaDepartureTimeDistributions.csv', 'w');
fileID3 = fopen('DeltaArrivalTimeDistributions.csv', 'w');

fprintf(fileID1,'Desk, Number of Flights, Interarrival Time Distribution\n');
fprintf(fileID2,'Desk, Number of Flights, Interarrival Time Distribution\n');
fprintf(fileID3,'Desk, Number of Flights, Interarrival Time Distribution\n');

for desk_name = 2 : desk_num
    %% Collecting release data of a single shift at each desk
    RLSfilename = strcat('task_input/RLS_desk_',desk{desk_name});
    RLSfigureName = strcat('RLS_Figures/RLSfig_desk_',desk{desk_name});
    Rtime = [];
    for i = 1 : table_num
        if strcmp(table.Desk{i}, desk{desk_name})
            if (desk_name==66)
                if(RLStime(i,1) > 1.1)                            %these are desks that have shifts over night
                    Rtime = [Rtime;RLStime(i,1)-1];
                else
                    Rtime = [Rtime;RLStime(i,1)];
                end
            elseif (RLStime(i,1) > 1) && (desk_name<58 || desk_name>64)
                Rtime = [Rtime;RLStime(i,1)-1];
            else
                Rtime = [Rtime;RLStime(i,1)];
            end
        end
    end
    Rtime = sort(Rtime);
    minTime=Rtime(1);
    maxTime=Rtime(length(Rtime));
    Rtemp = [Rtime;0] - [0;Rtime];
    Rresult = Rtemp(2:size(Rtemp,1)-1,:) * 1440;
    Rresult_cell = cat(2, Rresult_cell,Rresult);
    %xlswrite(RLSfilename, Rresult);
    
    
    [eR,dR,fR,v]=DistributionFitter('Release',desk{desk_name}, round(Rresult));
    if ~v
        fprintf(fileID1,'Desk %s: Invalid Distribution, %d tasks occurred\n',desk{desk_name},length(Rtime));
    else
        print(RLSfigureName,'-djpeg')
        fprintf(fileID1,'Desk %s,%f, %s\n',desk{desk_name},length(Rtime),dR);
    end
    
    
    %% Collecting departure and arrival data of a single shift at each desk
    Depfilename = strcat('DEPtask_input/Dptr_desk_',desk{desk_name});
    DepfigureName = strcat('DEP_Figures/Dtprfig_desk_',desk{desk_name});
    Arrfilename = strcat('ARRtask_input/Arr_desk_',desk{desk_name});
    ArrfigureName = strcat('ARR_Figures/Arrfig_desk_',desk{desk_name});
    
    Dtime=[];
    Atime=[];
    for i = 1 : table_num
        if strcmp(table.Desk{i}, desk{desk_name})
            if ((desk_name>=58 && desk_name<=64)||(desk_name==66))     %these are desks that have shifts over night
                if DepTime(i,1)<.5
                    DepTime(i,1)=1+DepTime(i,1);
                end
            end
            if (DepTime(i,1) > minTime) && (DepTime(i,1) < maxTime)     %checks is arrival/departure is during shift
                Dtime = [Dtime;DepTime(i,1)];
                
                if (DepTime(i,1)>ArrTime(i,1))     %these are desks that have shifts over night
                    ArrTime(i,1)=1+ArrTime(i,1);
                end
                if (ArrTime(i,1) > minTime) && (ArrTime(i,1) < maxTime)     %checks is arrival/departure is during shift
                    %fprintf('%f\n', ArrTime(i,1))
                    Atime = [Atime;ArrTime(i,1)];
                end
            end
            
        end
    end
    Dtime = sort(Dtime);
    Dtemp = [Dtime;0] - [0;Dtime];
    
    Atime = sort(Atime);
    Atemp = [Atime;0] - [0;Atime];
    
    Dresult = Dtemp(2:size(Dtemp,1)-1,:) * 1440;
    Aresult = Atemp(2:size(Atemp,1)-1,:) * 1440;
    
    % Checks if there was not valid departure/arrival data during shift
    % Nonvalid if no flights departed or a single flight departed
    
    if isempty(Dtime) || length(Dtime)==1
        fprintf('Nonvalid Departure Data\n')
        Dresult=[];
    end
    if isempty(Atime) || length(Atime)==1
        fprintf('Nonvalid Arrival Data\n')
        Aresult=[];
    end
    
    Dresult_cell = cat(2, Dresult_cell,Dresult);
    Aresult_cell = cat(2, Aresult_cell,Aresult);
    
    %xlswrite(Depfilename, Dresult);
    %xlswrite(Arrfilename, Aresult);
    
    [eD,dD,fD,v]=DistributionFitter('Departure',desk{desk_name}, round(Dresult));
    
    if ~v
        fprintf(fileID2,'Desk %s,%f, Invalid Distribution: %d tasks occurred\n',desk{desk_name},length(Dtime),length(Dtime));
    else
        print(DepfigureName,'-djpeg')
        fprintf(fileID2,'Desk %s,%f, %s\n',desk{desk_name}, length(Dtime),dD);
    end
    
    [eA,dA,fA,v]=DistributionFitter('Arrival',desk{desk_name}, round(Aresult));
    
    if ~v
        fprintf(fileID3,'Desk %s,%f, Invalid Distribution: %d tasks occurred\n',desk{desk_name},length(Atime),length(Atime));
    else
        print(ArrfigureName,'-djpeg')
        fprintf(fileID3,'Desk %s,%f, %s\n',desk{desk_name},length(Atime),dA);
    end
end

fclose(fileID1);fclose(fileID2);fclose(fileID3);

