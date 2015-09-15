from lxml import html, etree
from datetime import datetime, date
import requests
import mechanize
import cookielib
import calendar
import csv

# Created by Greg Stacey Sep 9, 2015
# 
# The code so far:
# Runs through consecutive chess.com urls.
# Parses their source code for
# 	i) game id (10-digit number at end of url)
#	ii) white player name
#	iii) black player name
#	iv) did white win? boolean
#	v) win condition e.g. checkmate, time, abandoned, etc
#	vi) ELO rating, black
#	vii) ELO rating, white
#	viii) Date
#	ix) Date timestamp
#	x) Time e.g. '5-0', '10-0'
#
# To add:
#   xi) Rated? boolean
#	xii) All the moves!!
#   xiii) Number of moves
    
    
# default url = url0.
# urls will be made by modifying url0.
url0 = 'http://www.chess.com/livechess/game?id=0000000004';

# initialize
N=20000;
id_list=[None]*N;
white_player=[None]*N;
black_player=[None]*N;
white_wins=[None]*N;
win_cond=[0 for x in range(N)];
rating_white=[0 for x in range(N)];
rating_black=[0 for x in range(N)];
date=[None]*N;
datenumber=[None]*N;
time_set=[None]*N;
won_str_list=[None]*N;

s="";
ii=-1;
# Increment through integer values for game id, 'game?id=e8e7e6e5e400000'
# Each time through the loop generates the data from one game id.
with open('chess_scores05.csv', 'wb') as csvfile: # This file will be analyzed by Matlab.
  for e8 in range(0,10):
    for e7 in range(0,10):
      for e6 in range(0,10):
        for e5 in range(0,10):
	      for e4 in [0, 5]:
	        import time
	        t = time.time();
	        ii=ii+1; # loop counter / data index

	        # Make the correct url
	        seq=(url0[0:40],str(e8),str(e7),str(e6),str(e5),str(e4),url0[45:49]);
	        url = s.join(seq);
	        page = requests.get(url) # Get the source code for this url.
	        tree = html.fromstring(page.text) # Parse the source code.
	        
	        # Collect data
	        id_list[ii] = url[39:49]; #### 1. Game id
	    
	        for node in tree.iter('title'):
	          tmp= node.text;
	        ind1 = tmp.find(' vs ');  
	        ind2 = tmp.find(' - Live Chess');  
	        white_player[ii] =tmp[0:ind1]; #### 2. White player name
	        black_player[ii] =tmp[ind1+4:ind2]; #### 3. Black player name

	        # example 'won_str': 'BlaBLa won - game abandoned'.
	        # parse won_str for i) white/black win, ii) win type.
	        won_str = tree.xpath('//div[@class="notice info bottom-8"]/text()')
	        won_str = str(won_str);
	        won_str_list[ii] = won_str;    
	        ind0 = won_str.find(' ');
	        ind1 = won_str.find(' won by checkmate');
	        ind2 = won_str.find(' won on time');
	        ind3 = won_str.find(' won by resignation');
	        ind4 = won_str.find(' won - game abandoned');
	        ind5 = won_str.find('Game drawn by stalemate');  
	        ind6 = won_str.find('Game drawn by agreement');  
	        
	        #### 5. Did white win? boolean
	        # white_wins == 0 means black won, 1 means white won
	        won_str_short = won_str[2:ind0];
	        if won_str_short == white_player[ii]:
	          won_bin = 1;
	        else:
	          won_bin = 0;
	        white_wins[ii] = won_bin;
	        
	        #### 6. Win condition
	        if ind1 > 0:
	          win_cond[ii] = 1; # win, checkmate
	        elif ind2 > 0:
	          win_cond[ii] = 2; # win, time
	        elif ind3 > 0:
	          win_cond[ii] = 3; # win, resignation
	        elif ind4 > 0:
	          win_cond[ii] = 4; # win, abandoned
	        elif ind5 > 0:
	          win_cond[ii] = 5; # draw, stalemate
	        elif ind6 > 0:
	          win_cond[ii] = 6; # draw, agreement
	        else:
	          win_cond[ii] = -1; # aborted by the server
	  
	        #### 7,8. White and black ratings
	        # ratings
	        scores_str = tree.xpath('//span[@class="playerrating"]/text()')
	        if len(scores_str) == 2:
	          try:
	            rating_black[ii] = int(scores_str[0]);
	            rating_white[ii] = int(scores_str[1]);
	          except: 
	            rating_black[ii] = '-1';
	            rating_white[ii] = '-1';
	        else:
	          rating_black[ii] = '-1';
	          rating_white[ii] = '-1';
	        
	        # Game date, time condition, and date-as-number
	        jj=0;
	        # date and time are in 'strong' tags, whatever that means
	        for node in tree.iter('strong'):
	          jj=jj+1;
	          if jj==1:
	            date[ii] = node.tail;
	          if jj==2:
	            time_set[ii] = node.tail;
	            break
	        if win_cond[ii] > 0:
	          date[ii] = datetime.strptime(date[ii], ' %b %d, %Y  ')
	          datenumber[ii] = calendar.timegm(date[ii].timetuple())
	        else:
	          date[ii] = -1;
	          datenumber[ii] = -1;
	          time_set[ii] = -1;
	        print seq, "   ", ii, "   ", rating_black[ii],rating_white[ii], time.time() - t
	        spamwriter = csv.writer(csvfile, delimiter=' ', quotechar='\t', quoting=csv.QUOTE_MINIMAL)
            
	        spamwriter.writerow([id_list[ii], white_player[ii], black_player[ii], white_wins[ii], win_cond[ii], rating_black[ii], rating_white[ii], datenumber[ii], time_set[ii]])

