
% 1 - id
% 2 - white name
% 3 - black name
% 4 - white wins? boolean
% 5 - win condition (1checkmate, 2time, 3resign, 4abandoned, 5drawstalemate, 6drawagree, -1aborted)
% 6 - rating, black
% 7 - rating, white
% 8 - date days, string
% 9 - date time, string
% 10 - date timestamp, integer
% 11 - time condition, string

spl=0; % Save plots?



%% Read files

i=0;
N=30000;
urlid=zeros(N,1);
wwins=zeros(N,1);
wincond=zeros(N,1);
scores=zeros(N,2);
scores_win_sort=zeros(N,2);
dates=zeros(N,1);

% read files with format: [id white black ww? win_type rating_w rating_b win_string utc_date time_type]
fn4{1} = '/your/file/path/chess_scores04.csv'; % the file made by myScrapeGames_incr01.py
for jj=1:length(fn4)
  chessfile = fopen(fn4{jj});
  
  while(~feof(chessfile))
    i=i+1;
    
    line = fgetl(chessfile);
    tmp = textscan(line,'%f %s %s %d %d %d %d %d %s');
    
    urlid(i) = tmp{1};
    white(i) = tmp{2};
    black(i) = tmp{3};
    wwins(i) = cell2mat(tmp(4));
    wincond(i) = cell2mat(tmp(5));
    scores(i,:) = [cell2mat(tmp(6)) cell2mat(tmp(7))];
    dates(i) = tmp{8};
    timeset{i} = tmp{9};
    
    if wwins(i)
      scores_win_sort(i,:) = scores(i,[2 1]);
    else
      scores_win_sort(i,:) = scores(i,[1 2]);
    end
  end
end



%% Clean data

% Clean up data
urlid=urlid(I);
white=white(I);
black=black(I);
wwins=wwins(I);
wincond=wincond(I);
scores=scores(I,:);
scores_win_sort=scores_win_sort(I,:);
dates=dates(I);

N=sum(I);



%% plots

% Has average rating changed over time?
date_plot = (dates - 1230768000)/3600 / 24 / 365.26; % Jan 1 2009
figure,hold on
scatter(date_plot,scores(:,1),10,'k')
dateRange=linspace(date_plot(1)-.1,date_plot(end)-.05,100);
dt=1/4;
meanelo=zeros(length(dateRange)-1,1);
for di=1:length(dateRange)-1
  dd = dateRange(di);
  I=date_plot>dd & date_plot<dd+dt;
  tmp=scores(I,:);
  meanelo(di)=mean(tmp(:));
end
plot(dateRange(1:end-1)+dt*.5, meanelo, 'r','linewidth',2)
legend('Games','Running avg','My score')
xlabel('Date (year)','fontsize',15)
ylabel('ELO rating','fontsize',15)
ylim([400 3000])
xlim([0.5 6.25])
set(gca,'xtick',1:6,'xticklabel',{'2010' '2011' '2012' '2013' '2014' '2015'},'fontsize',13)
set(gcf,'color','w','PaperUnits', 'centimeters','paperposition',[0 0 16 8])
sf=['/Users/Mercy/Professional/Website/BlogPosts/04chessscrape/' 'Fig01a'];
if spl;saveas(gcf,sf,'epsc');end

% white and black ratings
x=200:25:2500;
aa=scores(11000:end,:);
h1 = hist(aa(:),x);
figure,hold on
stairs(x,h1,'k','linewidth',3)
plot([1 1].*mean(aa(:)),[0 max(h1)*1.2],'--r')
plot([1 1].*1311,[0 max(h1)*1.2],'--g')
ylabel('Count','fontsize',15)
xlabel('ELO rating','fontsize',15)
legend('All games','Mean')
[~,p1] = ttest(scores(:,1),scores(:,2));
grid on
axis([400 2200 0 max(h1)*1.2])
set(gca,'fontsize',13,'xtick',[500 1000 1500 2000])
set(gcf,'color','w','PaperUnits', 'centimeters','paperposition',[0 0 16 8])
sf=['/Users/Mercy/Professional/Website/BlogPosts/04chessscrape/' 'Fig01b'];
if spl;saveas(gcf,sf,'png');end

% most common ways for a game to end
mr = mean(scores,2); % mean game rating
mrl = prctile(mr,25);
mrh = prctile(mr,75);
figure
wincond_hist=wincond;
wincond_hist(wincond_hist==4)=2; % draw
wincond_hist(wincond_hist==6 | wincond_hist==5)=4; % draw
h1 = hist(wincond_hist,1:4);
h1 = h1/sum(h1)*100;
h1_low = hist(wincond_hist(mr<mrl),1:4);
h1_low = h1_low/sum(h1_low)*100;
h1_high = hist(wincond_hist(mr>mrh),1:4);
h1_high = h1_high/sum(h1_high)*100;
h1_med = hist(wincond_hist(mr>mrl & mr<mrh),1:4);
h1_med = h1_med/sum(h1_med)*100;
h1_qroid = [20.6186   16.5845   61.5419    1.2550];
bar(1:4,[h1_low; h1_med; h1_high; h1_qroid])
colormap bone
xlim([0.5 4.5])
ylim([0 65])
set(gca,'fontsize',15,'xtick',1:4,'xticklabel',{'Bad' 'Mediocre' 'Good' 'Me' })
%legend('Checkmate', 'Timed out', 'Resign', 'Draw','location','northeast')
ylabel('% of games','fontsize',18)
title('How chess games end','fontsize',18)
grid on
h_l=legend('Checkmate','Time out','Resign','Draw','location','northwest');
set(h_l,'fontsize',10)
set(gcf,'color','w','PaperUnits', 'centimeters','paperposition',[0 0 16 8])
sf=['/Users/Mercy/Professional/Website/BlogPosts/04chessscrape/' 'Fig03'];
if spl;saveas(gcf,sf,'png');end



