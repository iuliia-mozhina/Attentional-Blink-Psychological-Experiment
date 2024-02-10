function [w, screens, const] = initGraphics
% FUNCTION [w, srect, res, bgcolor, textSize, letterWidth] = initGraphics;
% öffnet ein Psychtoolbox-Grafikfenster mit weißem Hintergrund und Auflösung 640 x 480 Punkten. Die Bildwiederholrate wird gemessen, der Schrifttyp des Fensters soll auf 'Courier New' Fettdruck gesetzt und die Breite eines Buchstabens gemessen . Rückgabewerte:
% 	w: Handle auf das Fenster
% const: structured array with some fields, including
%   srect: stimulus rect
% 	res: structured array with fields res.width, res.height for resolution
% 	(width, height) , res.pixelSize current color depth in bits and res.hz
% 	current frame rate, res.frameInterval measured inter-frame interval
% 	bgcolor: background color
% 	textSize: letter height in points (a point at 72 dpi is 1/72 inches)
% 	letterWidth, letterHeight: width, height of a letter in pixels
%
% Jochen Laubrock 

const.bgcolor = [128 128 128]; % gray background
const.fgcolor = [255 255 255 ]; % white foreground
% rect = [0 0 800 600]; % small window
rect = []; % small window
desiredRefreshRate = 60; % for LCDs
% desiredRefreshRate = 100; % for lab

Screen('Preference','TextEncodingLocale','UTF-8');
Screen('Preference', 'TextRenderer', 1);
% open graphics window and save handle
[w, const.srect] = Screen('OpenWindow', 0, const.bgcolor, rect); 
[const.cx, const.cy] = RectCenter(const.srect);

% messen der aktuellen Bildschirmauflösung und Bildwiederholrate
const.res = Screen('Resolution', w);
% einige LCD Displays beichten (korrekterweise) keinen Wert für Hz
% simulieren aber 60 Hz
if const.res.hz == 0
	const.res.hz = 60;
end

% Bildwiederholrate messen, siehe Abschnitt im Skript
const.res.frameInterval = Screen('GetFlipInterval', w);

% Grösse der Ziel-Boxen bestimmen
ABexp.res = [const.res.width const.res.height];
ABexp.sz = [42.6720 32.0040]; % monitorgroesse in cm, nachmessen !!
ABexp.vdist = 60; % viewing distance in cm, nachmessen !!

[const.ppd, const.dpp] = visAng(ABexp);

% theFont = 'Courier New';
theFont = 'Monaco';
TEXTSIZE = 48;

% Schriftfarbe
Screen('TextColor', w, const.fgcolor);

% wieder löschen (ptb macht manchmal kleine dunkle Ränder)
Screen('FillRect', w, const.bgcolor);

screens.fixation = Screen('MakeTexture', w, const.bgcolor(1)*ones(const.srect(RectBottom), const.srect(RectRight), 3));

% =======================
% = screens vorbereiten =
% =======================
theScreens = {'w', 'screens.fixation'};
for i=1:length(theScreens)
	theScreen = eval(theScreens{i});
	% texteigenschaften setzen
	% Schriftart auf Courier einstellen
	Screen('TextFont', theScreen, theFont);
	% Schriftgröße setzen
	const.textSize = Screen('TextSize', theScreen, TEXTSIZE);
	% Fettdruck
	Screen('TextStyle', theScreen, 1);
	Screen('TextColor', theScreen, const.fgcolor);
	% loeschen
	Screen('FillRect', theScreen, const.bgcolor);
end


% =============================
% = % Fixationskreuz zeichnen =
% =============================
dx = .3 * const.ppd(1);
dy = dx;
Screen('DrawLine', screens.fixation, [0 0 0], const.cx, const.cy - dy, const.cx, const.cy + dy, 2);
Screen('DrawLine', screens.fixation, [0 0 0], const.cx - dx, const.cy, const.cx + dx, const.cy, 2);
 

% measure width and height of a letter (here: space)
[const.letterWidth, const.letterHeight, textbounds] = DrawFormattedText(w, '\n ');

