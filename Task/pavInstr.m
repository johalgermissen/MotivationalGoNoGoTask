%==========================================================================
% Script to display the instructions
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
% last changes  20-04-2015
%==========================================================================

% setup.
spacing     = 3; % distance between lines.
wrap        = 90; % breaks line if more than this amount of characters.

tx = 1;
while tx <= numel(img.instructions)
    switch tx
        case 0
            tx = 1;
            Screen('DrawTexture',wd,img.instructions{tx},[],[0 0 wdw wdh])
        case prep.par.pract.page
            iSes = find(tx == cell2mat(prep.par.pract.page));
            iResp = mod(sID+iSes,prep.par.pract.nStim)+1;
            iPage = prep.par.pract.page{iResp};
            Screen('DrawTexture',wd,img.instructions{iPage},[],[0 0 wdw wdh])
        otherwise
            Screen('DrawTexture',wd,img.instructions{tx},[],[0 0 wdw wdh])
    end
    
    Screen('Flip',wd);
        
    % wait for response.
    if prep.par.keymode == 1 && skipMRI == 1 
%     if prep.par.keymode == 1 % if long instructions with button box in MRI is required.
        WaitSecs(.5)
        B.clearResponses(); 
        resp = B.getResponse(10*60,true);
        if resp == prep.par.key.instr.left; tx = tx-1;
        else tx = tx + 1;
        end
    else % elseif prep.par.keymode == 2
        [~,keyCode,~] = KbWait([],3);
        if find(keyCode) == prep.par.key.instr.left; tx = tx-1;
        else tx = tx + 1;
        end
    end
    
    switch tx-1; case prep.par.pract.page; pavPractice; end
    
end % end while-loop.

Screen('FillRect',wd,backgroundCol);
Screen('Flip', wd);
WaitSecs(1);

if skipMRI == 0;
    
    if strcmp(prep.par.lang, 'ned')
        txtMRI = {'Verplaatsen naar de MRI scanner',...
            ' ','(Wacht op de onderzoeker om verder te gaan met de taak.)'};
    elseif strcmp(prep.par.lang, 'eng')
        txtMRI = {'Move to MRI scanner',' ',...
            '(Wait for the researcher to continue.)'};
    end
    disptxt(txtMRI,wd,wdw,wdh,0,0,prep.par.col.white,0,0);
    WaitSecs(2);
    inBreak = true;
    while inBreak
        resp = KeyboardResponse(inf,true);
        if resp == prep.par.key.resume
            blackscreen;
            WaitSecs(1);
            clear resp
            inBreak = false;
        end
    end % end while inBreak.
    
end % end if skipMRI.