function [reactionTime, response] = collectResponse(w, cx, cy, promptText)
% FUNCTION [reactionTime, response] = collectResponse(w, cx, cy, promptText)
%
% w: window pointer to main screen
% cx: x coordinate of the screen center
% cy: y coordinate of the screen center
    % Colors
    colors = {'red', 'yellow', 'blue', 'green'};
    colorValues = {[255 0 0], [255 255 0], [0 0 255], [0 255 0]};
    numColors = length(colors);

    % Set up rectangles for each color option
    rectWidth = 100;
    rectHeight = 100;
    rectSpacing = 50;
    rectPositions = zeros(4, numColors);
    
    for i = 1:numColors
        xLeft = cx - (numColors * rectWidth + (numColors - 1) * rectSpacing) / 2 + (i - 1) * (rectWidth + rectSpacing);
        yTop = cy - rectHeight / 2;
        rectPositions(:, i) = [xLeft; yTop; xLeft + rectWidth; yTop + rectHeight];
        Screen('FillRect', w, colorValues{i}, rectPositions(:, i));
    end

    % Present the rectangles and the prompt
    DrawFormattedText(w, promptText, 'center', cy-150, [0 0 0]);
    Screen('Flip', w);

    % Wait for the mouse click
    clicked = 0;
    startTime = GetSecs();  % start measuring the response time
    WaitSecs(0.1);
    while ~clicked
        [x, y, buttons] = GetMouse(w);
        if any(buttons) % Once a mouse click is detected 
            for i = 1:numColors
                % checks whether the position of the mouse click falls
                % within any of the rectangles' boundaries
                if x >= rectPositions(1, i) && x <= rectPositions(3, i) && y >= rectPositions(2, i) && y <= rectPositions(4, i)
                    clicked = 1;
                    reactionTime = GetSecs() - startTime;  % calculate the response time
                    reactionTime = round(reactionTime * 1000); % Convert to milliseconds
                    response = colors{i}; % store the chosen color
                    break;        
                end
            end
        end
    end
end