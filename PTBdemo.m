
% Clear the workspace and the screen
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
% Default colormode to use: 0 = clamped, 0-255 range. 1 = unclamped 0-1 range.
global psych_default_colormode;
psych_default_colormode = 1;

% Define maximum supported featureLevel for this Psychtoolbox installation:
maxFeatureLevel = 2;

% Always AssertOpenGL:
AssertOpenGL;

%return;
try
% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

screenDim = get(screenNumber,'screensize'); % note: 0,0 is the top left corner of the screen
resX = screenDim(3); resY = screenDim(4); % max screen size (should be resolution of your computer)
bgArea = screenDim; %This sets the coordinate space of the screen window, WHICH MAY HAVE A DIFFERENT SIZE


% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey = white / 2;


[theScreen, WindowRect] = Screen('OpenWindow', 0, 127.5); % % open a screen


% Open an on screen window using PsychImaging and color it grey.
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo.
KbStrokeWait;

% Clear the screen.
sca;
catch

    % section above.  Importantly, it closes the onscreen windowPtr if it's open.
    sca;
    ShowCursor()
    fclose('all');
    psychrethrow(psychlasterror);
end

