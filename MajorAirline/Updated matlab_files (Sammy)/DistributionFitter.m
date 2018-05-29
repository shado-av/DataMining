function [error,Distribution, Histogram, valid]=DistributionFitter(dataType,deskName,x)

format long
clf;
if length(x)<4
    valid=0;
    error=0;
    Distribution=0;
    Histogram=0;
    return; 
end

valid=1;

minx=min(x);
maxx=max(x);
modex=mode(x);

% Data
frequencyProbs = zeros(maxx,1);
xpos =  x;
for i = 1:length(x)
    if x(i)==0
        xpos(i)=1e-10;
    end
end
for i = 0:maxx
    frequencyProbs(i+1) = sum(x==i)/length(x);
end
y=linspace(minx,maxx,maxx+1);

% Compute PDFs (Triangular, Uniform, Exponential, Lognormal)
if ( minx~=maxx)
    pd1 = makedist('Triangular','a',minx,'b',modex,'c',maxx);
    pdf1 = pdf(pd1,y);
else
    pdf1=zeros(maxx+1);
end
pdf2 = linspace(1/length(x),1/length(x),max(x)+1);
mu1=expfit(x);
pdf3 = exppdf(y,mu1);
parmhat = lognfit(xpos);
mu2=parmhat(1);
sigma=parmhat(2);
pdf4= lognpdf(y,mu2,sigma);


% Plot the Data
figure(1);
hold on;
H=histogram(x,maxx+2,'Normalization', 'pdf' );
HistVals=H.Values;

%Calculate Errors
for i=1:max(x)
    er1(i)=pdf1(i)-HistVals(i);
    er2(i)=pdf2(i)-HistVals(i);
    er3(i)=pdf3(i)-HistVals(i);
    er4(i)=pdf4(i)-HistVals(i);
    
end
errorTri=sum((er1).^2)/(maxx+1);
errorUni=sum((er2).^2)/(maxx+1);
errorExp=sum((er3).^2)/(maxx+1);
errorLogn=sum((er4).^2)/(maxx+1);


% Find Best Fit
errorVec=[errorTri errorUni errorExp errorLogn];
minErr=min(errorVec);

if minErr==errorTri
    BestFit='Triangular';
elseif minErr==errorUni
    BestFit='Uniform';
elseif minErr==errorExp
    BestFit='Exponential';
elseif minErr==errorLogn
    BestFit='Lognormal';
end


switch BestFit
    case 'Triangular'
        Histogram=plot(y,pdf1,'r','LineWidth',2);
        legend('Data PDF','Triangular Distribution');
        error=errorTri;
        Distribution=strcat(BestFit,'(',num2str(minx),'; ', ...
            num2str(modex),'; ',num2str(maxx),')');
        
    case 'Uniform'
        Histogram=plot(y,pdf2,'y','LineWidth',2);
        legend('Data PDF','Uniform Distribution');
        error=errorUni;
        Distribution=strcat(BestFit,'(',num2str(minx),'; ', ...
            num2str(maxx),')');
    case 'Exponential'
        Histogram=plot(y,pdf3,'b','LineWidth',2);
        legend('Data PDF','Exponential Distribution');
        mu=mu1;
        error=errorExp;
        Distribution=strcat(BestFit,'(',num2str(mu1),')');
    case 'Lognormal'
        Histogram=plot(y,pdf4,'k','LineWidth',2);
        legend('Data PDF','Lognormal Distribution');
        error=errorLogn;
        mu=mu2;
        stddev=sigma;
        Distribution=strcat(BestFit,'(',num2str(mu2),'; ' ...
            ,num2str(sigma),')');
        
end
T=strcat('Best fit of',{' '},dataType,{' '}, 'data for Desk ',{' '}, deskName);
title(T)
xlabel('Interarrival Time (minutes)')
ylabel('Probability Distributions')
hold off;
