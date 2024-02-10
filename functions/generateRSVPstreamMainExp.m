function rsvp = generateRSVPstreamMainExp(const, t1Pos, t2Pos, t1Word, t2Word, dictionary)
% FUNCTION rsvp = generateRSVPstreamMainExp(const, t1Pos, t2Pos, t1Word, t2Word, dictionary)
%
% const: some symbolic constant
% t1Pos: position of T1
% t2Pos: position of T2
% t1Word: first target word 
% t2Word: second target word 
% dictionary: dictionary with adjectives

    streamLength = 18;
	rsvp = cell(1, streamLength);

    nAdjectives = length(dictionary);
    shuffledDictionary = dictionary(randperm(nAdjectives));

    % Add the first target word to the stream
    rsvp{t1Pos} = t1Word{1};
    % Add the second target word to the stream
    rsvp{t2Pos} = t2Word{1};

    % Add distractor words (adjectives) randomly to the stream
    availableIndices = setdiff(1:streamLength, [t1Pos, t2Pos]);
    for i = 1:(streamLength - 2)
        idx = randi(length(availableIndices));
        rsvp{availableIndices(idx)} = shuffledDictionary{i};
        availableIndices(idx) = [];
    end


