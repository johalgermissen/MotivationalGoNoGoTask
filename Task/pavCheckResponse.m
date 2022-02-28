function [resp,t,aborted,paused] = pavCheckResponse(untiltime,returnAfterResp,...
    prep,B,aborted,paused,checkpause)

if prep.par.keymode == 1 && ~checkpause
    B.clearResponses();
    [resp,t] = B.getResponse(untiltime,returnAfterResp);
else
    [resp,t] = KeyboardResponse(untiltime,returnAfterResp);
end
if resp > 0; 
    pavSendTrigger(prep,B,resp(1)); 
end
if resp == prep.par.key.abort
    aborted = true;
elseif resp == prep.par.key.pause
    paused = true;
end

end
