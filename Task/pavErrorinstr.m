%==========================================================================
% Script to display the message if no or a wrong button is pressed.
%
% Annelies van Nuland
% start:        08-10-2013
% last changes  08-10-2013
% Jennifer Swart
% start:        04-02-2014
% last changes: 21-04-2015
%==========================================================================
erroridx = 1;
if inTransfer
    if strcmp(responsecode,'miss')
        erroridx = 2;
    end
end

errormsg={};
if strcmp(prep.par.lang,'ned')
    errormsg{1} = 'Druk op één van de juiste toetsen.';
    errormsg{2} = 'Te langzaam. Probeer sneller te reageren.';
elseif strcmp(prep.par.lang,'eng')
    errormsg{1} = 'Please press one of the correct keys.';
    errormsg{2} = 'Too slow. Please try to respond faster.';
end
errormsg = errormsg{erroridx};

% display the errormessage and record timing.
[wt] = Screen('TextBounds',wd,errormsg);
xpos = round(wdw/2-wt(3)/2);
ypos = round(wdh/2-wt(4)/2);
Screen('Drawtext',wd,errormsg,xpos,ypos,white);
% if inInstructions
%     tm.pract{iSes}.warning = [tm.pract{iSes}.warning; Screen('flip', wd,[])];
% else
if inTransfer
    tm.trans.warning = [tm.trans.warning; Screen('flip', wd,[])];
else
    tm.learn{iPart}.warning = [tm.learn{iPart}.warning; Screen('flip', wd,[])];
end

WaitSecs(2);
blackscreen
WaitSecs(1);