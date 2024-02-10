function times = drawAndPresentStimulusMainExp(w, screens, const, times, rsvp, t1Pos, t2Pos, t1ColorName, t2ColorName, estimatedThreshold)
% FUNCTION times = drawAndPresentStimulusMainExp(w, screens, const, times, rsvp, t1Pos, t2Pos, t1ColorName, t2ColorName, estimatedThreshold)
%
% w: window pointer to main screen
% screens.fixation: pointer to fixation point texture
% const: some symbolic constant
% times.Fix: presentation time fixation cross
% times.ISI:  presentation time blank between two words
% rsvp: stream of targets to be presented 
% t1Pos: position of T1
% t2Pos: position of T2
% t1ColorName: color of T1
% t2ColorName: color of T2
% estimatedThreshold: estimated presentation time for words in RSVP stream

% self-paced: trial starts after space bar
waitForSpaceKey();

deltat = 1/120;
stimRect = CenterRect([0 0 64 64], Screen('Rect', w));
xchr = const.cx - const.letterWidth/2;
ychr = const.cy - const.letterHeight/3;
dx = .3 * const.ppd(1);
dy = .3 * const.ppd(2);

Screen('DrawTexture', w, screens.fixation);
t0 = Screen('Flip', w);

% variable to store the previously selected color index
prevColorIndex = NaN;

% Define colors
colorMatrix = {'red', 'green', 'blue', 'yellow'; 
                [255 0 0], [0 255 0], [0 0 255], [255 255 0]}; 
numColors = size(colorMatrix, 2);
    
Screen('FillRect', w, const.bgcolor, stimRect);
t1 = Screen('Flip', w, t0 + times.Fix);

Screen('FillRect', w, const.bgcolor, stimRect);
Screen('DrawText', w, double(rsvp{1}), xchr, ychr, [0 0 0], const.bgcolor);

t2s = NaN*ones(length(rsvp)+1, 1);
t2s(1) = Screen('Flip', w, t1 + times.ISIafterFix);
cnt = 1;

for i = 1:length(rsvp)
    % assign a color for the first target
	if i == t1Pos
        % we know the color of t1Word on position t1pos --> t1Color
        index = strcmp(colorMatrix(1, :), t1ColorName);
        colorValue = colorMatrix{2, index};
        prevColorIndex = find(index);
		Screen('DrawText', w, double(rsvp{i}), xchr, ychr, colorValue, const.bgcolor);
    else
        % assign a color for the second target
        if i == t2Pos
            index = strcmp(colorMatrix(1, :), t2ColorName);  
            colorValue = colorMatrix{2, index};
            prevColorIndex = find(index);
		    Screen('DrawText', w, double(rsvp{i}), xchr, ychr, colorValue, const.bgcolor);
        else
            % Assign a random color for adjectives
            possibleColors = setdiff(1:numColors, prevColorIndex);
            % if next word is one of the target words
            % make sure that nearby items don't have the same color
            if i == t1Pos - 1
                possibleColors = setdiff(possibleColors, [find(strcmp(colorMatrix(1,:), t1ColorName))]);
            end
            if i == t2Pos - 1
                possibleColors = setdiff(possibleColors, [find(strcmp(colorMatrix(1,:), t2ColorName))]);
            end
            
            randomIndex = possibleColors(randi(length(possibleColors)));
            
            prevColorIndex = randomIndex; % Update the previous color index
            randomRGB = colorMatrix{2, randomIndex};
            Screen('DrawText', w, double(rsvp{i}), xchr, ychr, randomRGB, const.bgcolor);
            
        end    
    end

	t2s(cnt+1) = Screen('Flip', w, t2s(cnt) + estimatedThreshold - deltat);
    t2s(cnt+2) = Screen('Flip', w, t2s(cnt+1) + times.ISI- deltat);
    cnt = cnt + 2;
end
Screen('FillRect', w, const.bgcolor, stimRect);
t3 = Screen('Flip', w, t2s(end) + estimatedThreshold - deltat);

times.t0 = t0;
times.t1 = t1;
times.t2 = t2s;
times.t3 = t3;
