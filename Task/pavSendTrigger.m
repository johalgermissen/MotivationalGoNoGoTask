function pavSendTrigger(prep,B,triggerValue)

if prep.par.comport == 1
    fprintf(B,'%d',triggerValue);
else
    B.sendTrigger(triggerValue);
end
fprintf(prep.timingfile,'%d\t%d\n',triggerValue,GetSecs);

end