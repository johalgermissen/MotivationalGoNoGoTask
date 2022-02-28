function [response, timestamp]= KeyboardResponse(timeout, return_after_response)
% This function is nearly identical to the Bitsi getResponse function, the
% only difference for those intersted is the find in
% 'response=find(keycode)' line. This is because the keyboard returns a
% different type of signal than the Bitsi-box; it gives a series of zeros
% in which one is changed to a different number, the location is related to
% the key that is pressed. By using find you therefore get the same result
% as the bitsi gives as a keycode.
    response = 0;
    % start stopwatch
    tic
    while toc < timeout
        % poll the state of the keyboard
        [keyisdown, when, keyCode] = KbCheck;
 
        % if there wasn't a response before and there is a
        % keyboard press available
        if response == 0 && logical(keyisdown)
            timestamp = when;
            response = find(keyCode);
            if return_after_response
                break;
            end
        end
    end

    % if no response yet after timeout
    if (response == 0)
        timestamp = GetSecs;% - startTime;
    end
end