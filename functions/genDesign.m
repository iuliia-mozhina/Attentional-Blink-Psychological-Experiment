function [design_table, designlbls] = genDesign(vpnr, dictionary)
% FUNCTION [design_table, designlbls] = genDesign(vpnr, dictionary)
%
% vpnr: subject-ID
% dictionary: dictionary with adjectives

v=version;
if str2num(v(1:3))>=8
% % matlab
    RandStream('mt19937ar', 'seed', 1000*vpnr);
% octave
else
    rand('seed', 1000*vpnr);
end

% randomized factors
% The lag between the first and the second target is to be set to 1,2,...,8
t2Lag = 1:8;
% The 1st target color word is either congruent or not 
% Create 128 zeros and 128 ones
t1Congruent = 0:1;
% color of the 2nd target color word should be always congruent 
% more of a dummy column 
t2Congruent = 1;

ColorNames = {'red', 'green', 'yellow', 'blue'};
% 4 possibilities for the color of t1
t1Color = 1:4;
% 3 possibilities for the color of t2
t2Color = 1:3;

% create minimal orthogonal design (all combinations of factors)
% 2 (congruency T1) x 4 (color T1) x 3 (color T2) x 8 (lag T1-T2) - repeated 2 times 
% --> 384 trials
nRepetitions = 2;
design = genGeneralDesign([length(t1Congruent) length(t1Color) length(t2Color) length(t2Lag)]); 
design = repmat(design, [nRepetitions 1]);

% Ensure t2Color is different from t1Color in each trial
for i = 1:size(design, 1)
    while design(i, 2) == design(i, 3)
        design(i, 3) = randi(length(t2Color));
    end
end

% replace by associated levels
design(:,1) = t1Congruent(design(:,1))';
design(:,2) = t1Color(design(:,2))';
design(:,3) = t2Color(design(:,3))';

% add the lag between t1 and t2
design(:,4) = t2Lag(design(:,4))';

% calculate the number of trials (should be 384)
ntrials = size(design, 1);

% control variable: t1 position randomly at positions between 4 and 9
t1Pos = randi(6, ntrials, 1) + 3;
design(:,5) = t1Pos;

% calculate the position of t2 and add it to the design matrix
t2Pos = design(:,4) + design(:,5);
design(:,6) = t2Pos;
design(:,7) = t2Congruent;

design_table = array2table(design, 'VariableNames', {'t1Congruent', 't1Color', 't2Color', 't2Lag', 't1Pos', 't2Pos', 't2Congruent'});

% encode the color names:
design_table.t1ColorName = ColorNames(design_table.t1Color)';
design_table.t2ColorName = ColorNames(design_table.t2Color)';

% create the second target word
% since it is always congruent - take the value from the t2Color column
design_table.t2Word = ColorNames(design_table.t2Color)';

% create the first target word based on the condition in t1Congruent
design_table.t1Word = cell(size(design_table, 1), 1);
    for i = 1:size(design_table, 1)
        if design_table.t1Congruent(i) == 1
            % If t1Congruent = 1, use the same value as t1ColorName
            design_table.t1Word{i} = design_table.t1ColorName{i};
        else
            % If t1Congruent = 0, use any other value from {'red', 'green', 'yellow', 'blue'}
            % except for the current t1ColorName
            availableColors = setdiff(ColorNames, design_table.t1ColorName{i});
            design_table.t1Word{i} = availableColors{randi(length(availableColors))};
        end
    end

% randomize presentation order
random_ix = randperm(ntrials);
design_table = design_table(random_ix, :);

% create 50 additional trials for the QUEST algorithm
numAdditionalTrials = 50;

% An adjective is placed randomly at any of the potential T1 locations from the main experiment (4, 5,..., 9).
t1Pos = randi([4, 9], numAdditionalTrials, 1);
% assign a random color to the adjective
t1Color = randi([1, 4], numAdditionalTrials, 1);
% Map t1Color values to color names
t1ColorName = cell(numAdditionalTrials, 1);
for i = 1:numAdditionalTrials
    t1ColorName{i} = ColorNames{t1Color(i)};
end

% Create a table for the additional trials
% the columns that we don't need in the initial 50 trials are set either to
% 0 or to "none"
additionalTrials = table(...
    zeros(numAdditionalTrials, 1), ...   % t1Congruent
    t1Color, ...                           % t1Color
    zeros(numAdditionalTrials, 1), ...   % t2Color
    zeros(numAdditionalTrials, 1), ...        % t2Lag
    t1Pos, ...                             % t1Pos
    zeros(numAdditionalTrials, 1), ...        % t2Pos
    zeros(numAdditionalTrials, 1), ...   % t2Congruent
    t1ColorName, ...                       % t1ColorName
    repmat({'none'}, numAdditionalTrials, 1), ...   % t2ColorName
    repmat({'none'}, numAdditionalTrials, 1), ...   % t2Word
    repmat({'none'}, numAdditionalTrials, 1), ...   % t1Word
    'VariableNames', design_table.Properties.VariableNames ...
);

% Combine the additional trials with the main experiment
design_table = [additionalTrials; design_table];
% calculate the new number of trials (384 + 50 = 434)
newNtrials = ntrials + numAdditionalTrials;
design_table.trialNo = (1:newNtrials)';

% Generate random indices to select adjectives
nAdjectives = length(dictionary);
shuffledDictionary = dictionary(randperm(nAdjectives));
randomAdjectiveIndices = randi([1, nAdjectives], numAdditionalTrials, 1);
% Assign the selected adjectives to the t1Word column
t1Word = shuffledDictionary(randomAdjectiveIndices);
% Update the t1Word column for the first 50 trials with an adjective
design_table.t1Word(1:numAdditionalTrials) = t1Word;

designlbls = design_table.Properties.VariableNames;


