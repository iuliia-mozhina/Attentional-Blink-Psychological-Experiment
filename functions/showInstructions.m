function showInstructions(w, const, filepath)

    fileID = fopen(filepath, 'r', 'n', 'UTF-8' );
    Instructions = fread(fileID,'*char')';
    fclose(fileID);

    oldTextSize = Screen('TextSize', w , 24);
	oldFont = Screen('TextFont', w , 'Times New Roman');
	[nx, ny, textbounds] = DrawFormattedText(w, double(Instructions),  round(RectWidth(const.srect) / 10), 'center', const.fgcolor, 80, [], [], 1.3);
	Screen('TextFont', w , oldFont);		
	Screen('TextSize', w , oldTextSize);		
	Screen(w, 'Flip');
	while KbCheck; end
	while ~KbCheck; WaitSecs(.01); end