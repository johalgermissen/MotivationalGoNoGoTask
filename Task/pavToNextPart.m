%==========================================================================
% Script to display the instructions for second part of the game
%
% Hanneke den Ouden,
% start:        16-08-2009
% last changes  02-08-2011
%
% Jennifer Swart,
% start:        03-02-2014
% last changes  23-04-2015
%
% Jessica M‰‰tt‰,
% start:        20-04-2015
% last changes  29-04-2015
%==========================================================================

% setup.
spacing     = 3; % distance between lines.
wrap        = 90; % breaks line if more than this amount of characters.

tx = 1;
while tx <= numel(img.nextPart)
    if tx <1; tx = 1; end
    Screen('DrawTexture',wd,img.nextPart{tx},[],[0 0 wdw wdh])
    Screen('Flip',wd);
        
    % wait for response.
    if prep.par.keymode == 1
        WaitSecs(.5)
        B.clearResponses(); 
        resp = B.getResponse(10*60,true);
        if resp == prep.par.key.left; tx = tx-1;
        else tx = tx + 1;
        end
    elseif prep.par.keymode == 2
        [~,keyCode,~] = KbWait([],3);
        if find(keyCode) == prep.par.key.left; tx = tx-1;
        else tx = tx + 1;
        end
    end
        
end % end while-loop.

Screen('FillRect',wd,backgroundCol);
Screen('Flip', wd);
WaitSecs(1);