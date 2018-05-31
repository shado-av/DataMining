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

fileID1 = fopen('March17Distributions.csv', 'w');

fprintf(fileID1,'Shift, OK Time Distributsion, Clear Time Distribution\n');


table = readtable('TRACK WARRANTS 03-17-18.xlsx');
table_num = size(table,1);

OKtimeOrig = table.OKTime;
CLEARtimeOrig = table.ClearedAt;
Day=17;
Month= 'March';
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

if OKs0_num==0
    OKshift0=[];
    OKshift1=OKresult(1:OKs1_num-1);
  	OKshift2=OKresult(OKs1_num:OKs1_num+OKs2_num-1);
    OKshift3=OKresult(OKs1_num+OKs2_num:OKs1_num+OKs2_num+OKs3_num-1);
    OKshift03=[OKshift3; OKshift0];
else
    OKshift0=OKresult(1:OKs0_num-1);
    OKshift1=OKresult(OKs0_num:OKs0_num+OKs1_num-1);
    OKshift2=OKresult(OKs0_num+OKs1_num:OKs0_num+OKs1_num+OKs2_num-1);
    OKshift3=OKresult(OKs0_num+OKs1_num+OKs2_num:OKs0_num+OKs1_num+OKs2_num+OKs3_num-1);
    OKshift03=[OKshift3; OKshift0];
end


CLEARtemp = [CLEARtimes;0] - [0;CLEARtimes];
CLEARresult = CLEARtemp(2:size(CLEARtemp,1)-1,:) * 1440;
CLEARresult_cell = cat(2,CLEARresult_cell, CLEARresult);

if CLEARs0_num==0
    CLEARshift0=[];
    CLEARshift1=CLEARresult(1:CLEARs1_num-1);
    CLEARshift2=CLEARresult(CLEARs1_num:CLEARs1_num+CLEARs2_num-1);
    CLEARshift3=CLEARresult(CLEARs1_num+CLEARs2_num:CLEARs1_num+CLEARs2_num+CLEARs3_num-1);
    CLEARshift03=[CLEARshift3; CLEARshift0];
else
    CLEARshift0=CLEARresult(1:CLEARs0_num-1);
    CLEARshift1=CLEARresult(CLEARs0_num:CLEARs0_num+CLEARs1_num-1);
    CLEARshift2=CLEARresult(CLEARs0_num+CLEARs1_num:CLEARs0_num+CLEARs1_num+CLEARs2_num-1);
    CLEARshift3=CLEARresult(CLEARs0_num+CLEARs1_num+CLEARs2_num:CLEARs0_num+CLEARs1_num+CLEARs2_num+CLEARs3_num-1);
    CLEARshift03=[CLEARshift3; CLEARshift0];
end
s=0;
while(s<5)
    if s==0
        OKdata=OKshift0;
        CLEARdata=CLEARshift0;
        shift='Shift_0';
        num1=OKs0_num;
        num2=CLEARs0_num;
    elseif s==1
        OKdata=OKshift1;
        CLEARdata=CLEARshift1;
        shift='Shift_1';
        num1=OKs1_num;
        num2=CLEARs1_num;
    elseif s==2
        OKdata=OKshift2;
        CLEARdata=CLEARshift2;
        shift='Shift_2';
        num1=OKs2_num;
        num2=CLEARs2_num;
    elseif s==3
        OKdata=OKshift3;
        CLEARdata=CLEARshift3;
        shift='Shift_3';
        num1=OKs3_num;
        num2=CLEARs3_num;
    elseif s==4
        OKdata=OKshift03;
        CLEARdata=CLEARshift03;
        shift='Shift_03';
        num1=OKs0_num+OKs3_num;
        num2=CLEARs0_num+CLEARs3_num;
        
    end
    
    OKfigname=strcat('3-17-18 Figures/OK_Distribution_',shift);
    OKfilename=strcat('3-17-18 Data/OK_interarrival_times_',shift);
    CLRfigname=strcat('3-17-18 Figures/CLEAR_Distribution_',shift);
    CLRfilename=strcat('3-17-18 Data/CLEAR_interarrival_times_',shift);
    
    if isempty(OKdata)
        OKdata(1)=NaN;
    end
    
    if isempty(CLEARdata)
        CLEARdata(1)=NaN;
    end
    
    
    xlswrite(OKfilename, OKdata);
    xlswrite(CLRfilename, CLEARdata);
    
    [e1,d1,f1,v]=RailroadDistributionFitter('OK',shift, round(OKdata));
    
    if ~v
        fprintf(fileID1,'%s,Invalid Distribution: %d tasks occurred,',shift,num1);
    else
        print(OKfigname,'-djpeg')
        fprintf(fileID1,'%s,%s,',shift,d1);
    end
    [e2,d2,f2,v]=RailroadDistributionFitter('CLEAR',shift, round(CLEARdata));
    
    if ~v
        fprintf(fileID1,'Invalid Distribution: %d tasks occurred\n',num2);
    else
        print(CLRfigname,'-djpeg')
        fprintf(fileID1,'%s\n',d2);
    end
    s=s+1;
end
