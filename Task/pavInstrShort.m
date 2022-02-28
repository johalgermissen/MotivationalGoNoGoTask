%==========================================================================
% Script to display the short instructions for the MRI task
% 
% Emma van Dijk,
% start:        25-10-2016
% last changes  25-10-2016
%==========================================================================

% setup.
spacing     = 3; % distance between lines.
wrap        = 90; % breaks line if more than this amount of characters.

tx = 1;
while tx <= numel(img.ShortInstructions)
    if tx <1; tx = 1; end
    Screen('DrawTexture',wd,img.ShortInstructions{tx},[],[0 0 wdw wdh])
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

