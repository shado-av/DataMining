%-------------------------------------------------------------------
% This program: load the excel file
%               read the task time table grouped by desks
%               write the task arrive interval into excel files
%
% Please put the .xlsx file in the same folder with this program
%-------------------------------------------------------------------
flightInfo = readtable('DeltaFlightInfo.xlsx');
flightInfo_num = size(flightInfo,1);

AMdesksTable = readtable('AMdesks.xls');
PMdesksTable = readtable('PMdesks.xls');
MIDdesksTable = readtable('MIDdesks.xls');

AMdesks = AMdesksTable.AMDESK;
AMdesks_num = length(AMdesks);
PMdesks = PMdesksTable.PMDESK;
PMdesks_num = length(PMdesks);
MIDdesks = MIDdesksTable.MIDDESK;
MIDdesks_num = length(MIDdesks);


desk = unique(flightInfo.Desk);
desk_num = size(desk,1);

RLStime = flightInfo.RLSTIME;
flightLength=flightInfo.MILES;

result_cell = {};

fileID1 = fopen('DistributionsByShift.csv', 'w');

AMtimes = [];
PMtimes = [];
MIDtimes = [];
AM_longHaul = [];
PM_longHaul = [];
MID_longHaul = [];
AM_shortHaul = [];
PM_shortHaul = [];
MID_shortHaul = [];
AM_numFlights = [];
PM_numFlights = [];
MID_numFlights = [];

for desk_num = 1 : AMdesks_num
    d=strsplit(AMdesks{desk_num},'N');
    d=d{1};
    Rtime = [];
    long = 0;
    short = 0;
    total_flights = 0;
    for i = 1 : flightInfo_num
        if strcmp(flightInfo.Desk{i}, d)
            if (RLStime(i,1) > 1)
                Rtime = [Rtime;RLStime(i,1)-1];
            else
                Rtime = [Rtime;RLStime(i,1)];
            end
            if (flightLength(i)>1000)
                long = long + 1;
            else
                short = short + 1;
            end
            total_flights = total_flights + 1;
        end
    end
    AM_longHaul = [AM_longHaul; long];
    AM_shortHaul = [AM_shortHaul; short];
    AM_numFlights = [AM_numFlights; total_flights];
    Rtime = sort(Rtime);
    Rtemp = [Rtime;0] - [0;Rtime];
    Rresult = Rtemp(2:size(Rtemp,1)-1,:) * 1440;
    AMtimes = [AMtimes; Rresult];
end

xlswrite('RLSInterarrivalTimes_AM.xlsx', AMtimes);
[error_AM,dist_AM,fig_AM,v_AM]=DistributionFitter('Release','Morning Shift', round(AMtimes));
fprintf(fileID1,'Morning Shifts, %s\n',dist_AM);
print('Release Interrarrival Times (AM)','-djpeg')


for desk_num = 1 : PMdesks_num
    d = strsplit(PMdesks{desk_num},'N');
    d = d{1};
    Rtime = [];
    long = 0;
    short = 0;
    total_flights = 0;
    for i = 1 : flightInfo_num
        if strcmp(flightInfo.Desk{i}, d)
            if (desk_num == 17)
                if(RLStime(i,1) > 1.1)
                    Rtime = [Rtime;RLStime(i,1)-1];
                else
                    Rtime = [Rtime;RLStime(i,1)];
                end
            elseif (RLStime(i,1) > 1)
                Rtime = [Rtime;RLStime(i,1)-1];
            else
                Rtime = [Rtime;RLStime(i,1)];
            end
            if (flightLength(i)>1000)
                long = long + 1;
            else
                short = short + 1;
            end
            total_flights = total_flights + 1;
        end
    end
    PM_longHaul = [PM_longHaul; long];
    PM_shortHaul = [PM_shortHaul; short];
    PM_numFlights = [PM_numFlights; total_flights];
    Rtime = sort(Rtime);
    Rtemp = [Rtime;0] - [0;Rtime];
    Rresult = Rtemp(2:size(Rtemp,1)-1,:) * 1440;
    PMtimes = [PMtimes; Rresult];
end

xlswrite('RLSInterarrivalTimes_PM.xlsx', PMtimes);
[error_PM,dist_PM,fig_PM,v_PM]=DistributionFitter('Release','Afternoon Shift', round(PMtimes));
fprintf(fileID1,'Aftermoon Shifts, %s\n',dist_PM);
print('Release Interrarrival Times (PM)','-djpeg')

for desk_num = 1 : MIDdesks_num
    d = strsplit(MIDdesks{desk_num},'N');
    d = d{1};
    Rtime = [];
    long = 0;
    short = 0;
    total_flights = 0;
    for i = 1 : flightInfo_num
        if strcmp(flightInfo.Desk{i}, d)
            Rtime = [Rtime;RLStime(i,1)];
            if (flightLength(i)>1000)
                long = long + 1;
            else
                short = short + 1;
            end
            total_flights = total_flights + 1;
        end
    end
    MID_longHaul = [MID_longHaul; long];
    MID_shortHaul = [MID_shortHaul; short];
    MID_numFlights = [MID_numFlights; total_flights];
    Rtime = sort(Rtime);
    Rtemp = [Rtime;0] - [0;Rtime];
    Rresult = Rtemp(2:size(Rtemp,1)-1,:) * 1440;
    MIDtimes = [MIDtimes; Rresult];
end

xlswrite('RLSInterarrivalTimes_Overnight.xlsx', MIDtimes);
[error_MID,dist_MID,fig_MID,v_MID]=DistributionFitter('Release','Overnight Shift', round(MIDtimes));
fprintf(fileID1,'Overnight Shifts, %s\n',dist_MID);
print('Release Interrarrival Times (Overnight)','-djpeg')

%% To get Number of Flight Departures per shift

AMdep_num = [];
PMdep_num = [];
MIDdep_num = [];

depTable = readtable('DepartureTimeDistributions.csv');
numDep = depTable.NumberOfFlights;
depDesks = depTable.Desk;

for desk_num = 1 : AMdesks_num
    d=strsplit(AMdesks{desk_num},'N');
    d=d{1};
    for i=1:length(depDesks)
        d2=strsplit(depDesks{i});
        d2 = d2{2};
        if strcmp(d2, d)
            AMdep_num = [AMdep_num; numDep(i)];
        end
    end 
end
for desk_num = 1 : PMdesks_num
    d=strsplit(PMdesks{desk_num},'N');
    d=d{1};
    for i=1:length(depDesks)
        d2=strsplit(depDesks{i});
        d2 = d2{2};
        if strcmp(d2, d)
            PMdep_num = [PMdep_num; numDep(i)];
        end
    end
    
end
for desk_num = 1 : MIDdesks_num
    d=strsplit(MIDdesks{desk_num},'N');
    d=d{1};
    for i=1:length(depDesks)
        d2=strsplit(depDesks{i});
        d2 = d2{2};
        if strcmp(d2, d)
            MIDdep_num = [MIDdep_num; numDep(i)];
        end
    end
end


[error_AM_dep,dist_AM_dep,fig_AM_dep,v_AM_dep]=DistributionFitter('Departure','Morning Shift', AMdep_num);
print('Number of Flights Following Distribution (AM)','-djpeg')
[error_PM_dep,dist_PM_dep,fig_PM_dep,v_PM_dep]=DistributionFitter('Long Haul','Afternoon Shift', PMdep_num);
print('Number of Flights Following Distribution (PM)','-djpeg')
[error_MID_dep,dist_MID_dep,fig_MID_dep,v_MID_dep]=DistributionFitter('Long Haul','Overnight Shift', MIDdep_num);
print('Number of Flights Following Distribution (Overnight)','-djpeg')


fileID2 = fopen('AMFlightData.csv', 'w');
fileID3 = fopen('PMFlightData.csv', 'w');
fileID4 = fopen('MIDFlightData.csv', 'w');

[error_AM_H,dist_AM_H,fig_AM_H,v_AM_H]=DistributionFitter('Long Haul','Morning Shift', AM_longHaul);
print('Long Haul Flight Distribution (AM)','-djpeg')
[error_PM_H,dist_PM_H,fig_PM_H,v_PM_H]=DistributionFitter('Long Haul','Afternoon Shift', PM_longHaul);
print('Long Haul Flight Distribution (PM)','-djpeg')
[error_MID_H,dist_MID_H,fig_MID_H,v_MID_H]=DistributionFitter('Long Haul','Overnight Shift', MID_longHaul);
print('Long Haul Flight Distribution (Overnight)','-djpeg')

fprintf(fileID2,'Total Flights, Number Long Haul, Number Short Haul, Number Departed\n');
for i=1:AMdesks_num
    fprintf(fileID2,'%d,%d,%d, %d\n', AM_numFlights(i), AM_longHaul(i),AM_shortHaul(i), AMdep_num(i));
end
fprintf(fileID2,'\n ,%s,,%s \n',dist_AM_H, dist_AM_dep);
fprintf(fileID3,'Total Flights, Number Long Haul, Number Short Haul, Number Departed\n');
for i=1:PMdesks_num
    fprintf(fileID3,'%d,%d,%d,%d\n', PM_numFlights(i), PM_longHaul(i),PM_shortHaul(i), PMdep_num(i));
end
fprintf(fileID3,'\n ,%s,,%s \n',dist_PM_H, dist_PM_dep);
fprintf(fileID4,'Total Flights, Number Long Haul, Number Short Haul, Number Departed\n');
for i=1:MIDdesks_num
    fprintf(fileID4,'%d,%d,%d,%d\n', MID_numFlights(i), MID_longHaul(i),MID_shortHaul(i), MIDdep_num(i));
end
fprintf(fileID4,'\n ,%s,,%s \n',dist_MID_H, dist_MID_dep);







