%==========================================================================
% pavStartBlock asks at the beginning of each block whether we want to 
% continue or abort the task.
%
% Jennifer Swart,
% start:        26-06-2014
% last changes: 21-04-2015
%==========================================================================

% check whether to abort or continue at the beginning of each block.
if ismember(iTrial,prep.par.learn.break+1)
    iBlock = iBlock + 1;
    fprintf(logfile, 'BLOCK:\t\t\t%d   \n\n',iBlock);
    txtBreak = {'(Shimming scanner)',' ','Please specify:','Continue(c) / Quit(q)'};
    disptxt(txtBreak,wd,wdw,wdh,0,0,prep.par.col.white,0,0);
            
    inBreak = true; 
    while inBreak
        WaitSecs(0.1);
        cmnd = KeyboardResponse(inf,true);
        cmnd = KbName(cmnd);
        
        if strcmpi(cmnd,'q')
            fprintf(logfile, 'Task aborted.\n\n\n');
            aborted = true; break;
        end 
        
        if any(strcmpi(cmnd,{'q','c'}))
            blackscreen;
            WaitSecs(2);
            if skipMRI == 0;
                %present a black screen saying 'waiting to start' while waiting for first
                if strcmp(prep.par.lang, 'ned')
                waittxt = {'Wachten op de scanner...','(Start scanner)'};
                elseif strcmp(prep.par.lang, 'eng')
                waittxt = {'Wait for the scanner...','(Start scanner)'};
                end
                disptxt(waittxt,wd,wdw,wdh,0,0,prep.par.col.white,0,0);
%                 B_MRI.clearResponses(); %triggers are cleared, ready for new set up
                %scantrigger
                B_MRI.close();
                B_MRI = Bitsi(prep.par.comMRI);
                first_scan = 0;
                while first_scan == 0
                    [trigger, tm.MRIstart{iPart,iBlock}] = B_MRI.getResponse(10, true);
                    if trigger == prep.par.trigger.MRI % not hard-coded; depends on prep in params
                        first_scan = 1;
                    end;
                end;
                % WaitSecs(prep.par.learn.time.MRI-3); not needed if dummy
                % scans don't send a trigger. -3 added because without MRI you already wait 3 seconds
            end; 
            drawfix;
            Screen(wd, 'Flip');
            WaitSecs(10);
            pavSendTrigger(prep,B,prep.par.code.resume);
            breaktime = breaktime + GetSecs - tm.learn{iPart}.break(iBlock);
            inBreak = false;
        end 
        
    end % end while inBreak.
    
end % end if ismember.