%-------------------------------------------------------------------
% This program: load the excel file
%               read the task time table grouped by task
%               write the task arrive interval into excel files organized
%               by shift
%
% Please put the .xlsx file in the same folder with this program
%-------------------------------------------------------------------
clear;clf

OKresult_cell = {};
CLEARresult_cell = {};

fileID1 = fopen('May16Distributions.csv', 'w');

fprintf(fileID1,'Shift, OK Time Distributsion, Clear Time Distribution\n');


table = readtable('TRACK WARRANTS 05-16-18.xlsx');
table_num = size(table,1);

OKtimeOrig = table.OKTime;
CLEARtimeOrig = table.ClearedAt;
Day=16;
Month= 'May';
j=1;

for i=1:table_num
    if(isempty(OKtimeOrig{i}))
        continue;
    end
    OKt=OKtimeOrig{i};
    CLEARt=CLEARtimeOrig{i};
    t1=str2double(strsplit(OKt,{'/','/',' ',':',newline}));
    t2=str2double(strsplit(CLEARt,{'/','/',' ',':',newline}));
    OKtimes(j,1)=(t1(4)+t1(5)/60)/24+t1(2)-Day;
    CLEARtimes(j,1)=(t2(4)+t2(5)/60)/24+t2(2)-Day;
    j=j+1;
end

OK_CLEAR_diff=(CLEARtimes-OKtimes) * 1440;
%DistributionFitter('OK Clear Difference','NA',round(OK_CLEAR_diff))


OKtimes = sort(OKtimes);
CLEARtimes = sort(CLEARtimes);

OKs0_num=sum(OKtimes>-2/24 & OKtimes<6/24);
OKs1_num=sum(OKtimes>6/24 & OKtimes<14/24);
OKs2_num=sum(OKtimes>14/24 & OKtimes<22/24);
OKs3_num=sum(OKtimes>22/24 & OKtimes<(1+6/24));

CLEARs0_num=sum(CLEARtimes>-2/24 & CLEARtimes<6/24);
CLEARs1_num=sum(CLEARtimes>6/24 & CLEARtimes<14/24);
CLEARs2_num=sum(CLEARtimes>14/24 & CLEARtimes<22/24);
CLEARs3_num=sum(CLEARtimes>22/24 & CLEARtimes<(1+6/24));

OKtemp = [OKtimes;0] - [0;OKtimes];
OKresult = OKtemp(2:size(OKtemp,1)-1,:) * 1440;
OKresult_cell = cat(2,OKresult_cell, OKresult);

OKshift0=OKresult(1:OKs0_num-1);
OKshift1=OKresult(OKs0_num:OKs0_num+OKs1_num-1);
OKshift2=OKresult(OKs1_num:OKs1_num+OKs2_num-1);
OKshift3=OKresult(OKs2_num:OKs2_num+OKs3_num-1);
OKshift03=[OKshift3; OKshift0];


CLEARtemp = [CLEARtimes;0] - [0;CLEARtimes];
CLEARresult = CLEARtemp(2:size(CLEARtemp,1)-1,:) * 1440;
CLEARresult_cell = cat(2,CLEARresult_cell, CLEARresult);

CLEARshift0=CLEARresult(1:CLEARs0_num-1);
CLEARshift1=CLEARresult(CLEARs0_num:CLEARs0_num+CLEARs1_num-1);
CLEARshift2=CLEARresult(CLEARs1_num:CLEARs1_num+CLEARs2_num-1);
CLEARshift3=CLEARresult(CLEARs2_num:CLEARs2_num+CLEARs3_num-1);
CLEARshift03=[CLEARshift3; CLEARshift0];
s=0;
while(s<5)
    if s==0
        OKdata=OKshift0;
        CLEARdata=CLEARshift0;
        shift='Shift_0';
    elseif s==1
        OKdata=OKshift1;
        CLEARdata=CLEARshift1;
        shift='Shift_1';
    elseif s==2
        OKdata=OKshift2;
        CLEARdata=CLEARshift2;
        shift='Shift_2';
    elseif s==3
        OKdata=OKshift3;
        CLEARdata=CLEARshift3;
        shift='Shift_3';
    elseif s==4
        OKdata=OKshift03;
        CLEARdata=CLEARshift03;
        shift='Shift_03';
        
    end
    
    OKfigname=strcat('Figures/OK_Distribution_',shift);
    OKfilename=strcat('Data/OK_interarrival_times_',shift);
    CLRfigname=strcat('Figures/CLEAR_Distribution_',shift);
    CLRfilename=strcat('Data/CLEAR_interarrival_times_',shift);
    
    xlswrite(OKfilename, OKdata);
    xlswrite(CLRfilename, CLEARdata);
    
    [e1,d1,f1,v]=RailroadDistributionFitter('OK',shift, round(OKdata));
    
    if ~v
        fprintf(fileID1,'%s,Invalid Distribution: %d tasks occurred,',shift,length(OKdata)+1);
    else
        print(OKfigname,'-djpeg')
        fprintf(fileID1,'%s,%s,',shift,d1);
    end
    [e2,d2,f2,v]=RailroadDistributionFitter('CLEAR',shift, round(CLEARdata));
    
    if ~v
        fprintf(fileID1,'Invalid Distribution: %d tasks occurred\n',length(CLEARdata)+1);
    else
        print(CLRfigname,'-djpeg')
        fprintf(fileID1,'%s\n',d2);
    end
    s=s+1;
end
