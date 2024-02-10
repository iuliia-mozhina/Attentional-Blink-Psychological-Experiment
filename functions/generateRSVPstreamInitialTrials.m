function rsvp = generateRSVPstreamInitialTrials(const, t1Pos, t1Word, dictionary)
% FUNCTION rsvp = generateRSVPstreamInitialTrials(const, t1Pos, t1Word, dictionary)
%
% const: some symbolic constant
% t1Pos: position of T1
% t1Word: first target word 
% dictionary: dictionary with adjectives

    streamLength = 18;
	rsvp = cell(1, streamLength);

    nAdjectives = length(dictionary);
    shuffledDictionary = dictionary(randperm(nAdjectives));

    % Remove t1Word from the shuffled dictionary
    t1WordIndex = find(strcmp(shuffledDictionary, t1Word));
    if ~isempty(t1WordIndex)
        shuffledDictionary(t1WordIndex) = [];
    end

    % Add an adjective at the potential position of T1 to the stream
    rsvp{t1Pos} = t1Word{1};

    % Create a pool of available indices excluding the position of T1
    availableIndices = setdiff(1:streamLength, t1Pos);

    % Fill the rest of the stream with randomly chosen adjectives
    for i = 1:(streamLength - 1)
        idx = randi(length(availableIndices));
        rsvp{availableIndices(idx)} = shuffledDictionary{i};
        availableIndices(idx) = [];
    end


