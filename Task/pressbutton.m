%==========================================================================
% script to display and wait for a keypress to continue
%
% Hanneke den Ouden,
% start:        16-08-2009
% last changes  02-08-2012
% Annelies van Nuland,
% last changes  28-10-2013
% Jennifer Swart,
% start:        03-02-2014
% last changes  03-02-2014
%==========================================================================
if strcmp(prep.par.lang, 'eng')
    tekst = 'Press any key to continue';
elseif strcmp(prep.par.lang, 'ned')
    tekst = 'Druk op een knop om door te gaan';
end
[wt]=Screen(wd,'TextBounds',tekst);
Screen('Drawtext',wd,tekst,wdw*0.1,wdh-(prep.par.draw.top+2*prep.par.draw.txtsize ),white);
Screen('Flip', wd);

WaitSecs(0.2)
if prep.par.keymode == 1
    B.clearResponses();
    tmp = B.getResponse(10*60,true);
else
    tmp = KeyboardResponse(10*60,true);
end