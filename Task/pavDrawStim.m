function wd = pavDrawStim(wd,prep,cond,RGchoice,results,iTrial,img,iSes,iPart)

%==========================================================================
% Code for drawing the different stimulus events. There are several
% different types of events, or conditions, all of which start with drawing
% the stimuli:
%   cond = 0 draw stimulus
%   cond = 1 draw 
%   cond = 2 smileys
%
% Hanneke den Ouden,
% start:        16-08-2009
% last changes  02-08-2012
% Annelies van Nuland,
% start:        10-10-2013
% last changes  02-01-2014
% Jennifer Swart,
% start:        03-02-2014
% last changes  22-04-2015
%==========================================================================

drawfix;

% Assign rectangle locations
switch cond
    case 1
        % Draw the stimuli - learning phase. 
        Screen('DrawTexture',wd,img.stim{iPart,RGchoice(iTrial,1)},[],prep.par.draw.rect.stim);

    case 2
        % Draw the feedback - learning phase.
        if ismember(RGchoice(iTrial),prep.par.rewStim) % reward trials.
            if results.learn{iPart}.outcome(iTrial,1) == 1 % reward.
                Screen('DrawTexture', wd, img.outcome{1},[],prep.par.draw.rect.feedback);
            else % no reward.
                Screen('DrawTexture', wd, img.outcome{3},[],prep.par.draw.rect.feedback);
            end
        elseif ismember(RGchoice(iTrial),prep.par.punStim) % punishment trials.
            if results.learn{iPart}.outcome(iTrial,1) == -1 % punishment.
                Screen('DrawTexture', wd, img.outcome{2},[],prep.par.draw.rect.feedback);
            else % no punishment.
                Screen('DrawTexture', wd, img.outcome{4},[],prep.par.draw.rect.feedback);
            end
        end
    
    case 3
        % Draw the stimuli - transfer phase. 
        for side = 1:2
            Screen('DrawTexture',wd,img.trans{iPart,prep.seq.trans.stim(iTrial,side)},[],prep.par.draw.rect.transfer{side});
        end
        
    case 4
        % draw stimuli - practice session.
        Screen('DrawTexture',wd,img.examp{RGchoice},[],prep.par.draw.rect.stim);

end % end switch cond.

end % end pavDrawStim.
