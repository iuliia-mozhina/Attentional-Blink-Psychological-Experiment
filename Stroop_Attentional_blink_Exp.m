% Stroop task in combination with the attentional blink paradigm
Screen('Preference', 'SkipSyncTests', 0);
%PsychDebugWindowConfiguration; 

try
	addpath('functions'); 
	KbName('UnifyKeyNames');
	ListenChar(1);
    
	[w, screens, const] = initGraphics;
    vpnr = get_participant_code();
  
	% output file
	resultFileName = ['results/Attentional_blink_Exp_' num2str(vpnr) '.dat'];

    % QUEST parameters
    initialTrials = 50;
    % initial threshold estimate as a mean and standard deviation
    tGuess = 0.8;
    tGuessSd = 5;  % generous for SD
    % Parameters of the algorithm
    pThreshold = 0.82;
    beta = 3.5;
    delta = 0.01;
    gamma = 0.5;
    % Constrain minimum and maximum duration per word
    minDuration = 0.080; % Minimum 80 ms per word
    maxDuration = 0.300; % Maximum 300 ms per word

    % initialize the QUEST algorithm
    q = QuestCreate(tGuess, tGuessSd, pThreshold, beta, delta, gamma);
    q.normalizePdf = 1; % adds a few ms per call to QuestUpdate, but otherwise the pdf will underflow after about 1000 trials.

    % Load and shuffle the adjectives dictionary 
    dictionary = importdata('material/target_adjectives_cleaned.txt'); 

    [design, designlbls] = genDesign(vpnr, dictionary);
	NTRIALS = size(design,1);  % 434 now
	
    resultVars = table('Size', [NTRIALS 6], ...
        'VariableNames', {'R1', 'R2', 'correct1', 'correct2', 'RT1', 'RT2'}, ...
        'VariableTypes', {'string', 'string', 'double', 'double', 'double', 'double'});
	design = [design resultVars];

	[cx, cy] = RectCenter(const.srect);

	% timings
	% 	Raymond / Shapiro 
	times.ISI = 0.075;  % presentation time blank between two words - interstimulus interval 
	times.ISIafterFix = 0.000;  
	times.Fix = 0.500;  % presentation time fixation cross

    showInstructions(w, const, 'material/instructions.txt');

    % 50 initial trials
    for trial = 1:initialTrials  
		% specify Stimulus
		t1Pos = design.t1Pos(trial); 
        t1Word = design.t1Word(trial);
        t1ColorName = design.t1ColorName(trial);

        % recommended stimulus intensity
        intensity = QuestQuantile(q);  % Recommended by Pelli (1987)
        % presentation time cannot be shorter than 80 ms per word, and not longer than 300 ms per word
        intensity = max(minDuration, min(maxDuration, intensity));

        % generate the RSVP stream
		rsvp = generateRSVPstreamInitialTrials(const, t1Pos, t1Word, dictionary);
		% present stimulus 
		times = drawAndPresentStimulusInitialTrials(w, screens, const, times, rsvp, t1Pos, t1ColorName, intensity);

		% collect and store response  
        promptText1 = sprintf('Color of the word %s?', t1Word{1});
        [RT1, R1] = collectResponse(w, cx, cy, promptText1);

        % save trial results (stimulus intensity, subject's response) in q and update probability density
        design.R1(trial) = upper(R1);
		design.correct1(trial) = strcmp(upper(R1), upper(t1ColorName));
        design.RT1(trial) = RT1;
		writetable(design, resultFileName, 'Delimiter','\t');

        q = QuestUpdate(q, intensity, strcmp(upper(R1), upper(t1ColorName)));

        Screen('FillRect', w, [255 255 255]);
        Screen('Flip', w);
    end

    % Get the estimated threshold from QUEST
    estimatedThreshold = QuestMean(q);   % Recommended by Pelli (1989) and King-Smith et al. (1994).
    estimatedThreshold = min(max(estimatedThreshold, minDuration), maxDuration);

    % main experiment (trial 51- 434)
    showInstructions(w, const, 'material/middle_progress.txt');
    for trial = initialTrials+1:NTRIALS 
		% specify Stimulus
		t1Pos = design.t1Pos(trial);
		t2Pos = design.t2Pos(trial);
        t1Word = design.t1Word(trial);
        t2Word = design.t2Word(trial);
        t1ColorName = design.t1ColorName(trial);
        t2ColorName = design.t2ColorName(trial);

        % generate the RSVP stream
		rsvp = generateRSVPstreamMainExp(const, t1Pos, t2Pos, t1Word, t2Word, dictionary);
		% present stimulus 
		times = drawAndPresentStimulusMainExp(w, screens, const, times, rsvp, t1Pos, t2Pos, t1ColorName, t2ColorName, estimatedThreshold);

		% collect and store response  
        promptText1 = 'Color of the first target word?';
        [RT1, R1] = collectResponse(w, cx, cy, promptText1);
        promptText2 = 'Color of the second target word?';
        [RT2, R2] = collectResponse(w, cx, cy, promptText2);
        Screen('FillRect', w, [255 255 255]);
        Screen('Flip', w);

        design.R1(trial) = upper(R1);
        design.R2(trial) = upper(R2);
		design.correct1(trial) = strcmp(upper(R1), upper(t1ColorName));
		design.correct2(trial) = strcmp(upper(R2), upper(t2ColorName));
        design.RT1(trial) = RT1;
        design.RT2(trial) = RT2;
		writetable(design, resultFileName, 'Delimiter','\t');
    end

    showInstructions(w, const, 'material/end_of_experiment.txt');
	Priority(0);
	Screen('CloseAll')
	ListenChar(1);

catch 
	ListenChar(1);
	Screen('CloseAll');
    rethrow(lasterror);
end	

