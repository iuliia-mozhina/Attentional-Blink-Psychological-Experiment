function participant_code = get_participant_code()
% ask for participant in  Matlab dialog (works only before Screen('OpenwWindow' is called))
%
% Jochen Laubrock 2013

participant_code = inputdlg('Participant number:', '', 1, {'999'});
tmp = str2num(char(participant_code));
if ~isempty(tmp)
	participant_code=tmp;
else
	error('Valid participant numbers have to be numeric.')
end

