function varargout = ElementID_GUI_3(varargin)
% ELEMENTID_GUI_3 MATLAB code for ElementID_GUI_3.fig
%      ELEMENTID_GUI_3, by itself, creates a new ELEMENTID_GUI_3 or raises the existing
%      singleton*.
%
%      H = ELEMENTID_GUI_3 returns the handle to a new ELEMENTID_GUI_3 or the handle to
%      the existing singleton*.
%
%      ELEMENTID_GUI_3('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELEMENTID_GUI_3.M with the given input arguments.
%
%      ELEMENTID_GUI_3('Property','Value',...) creates a new ELEMENTID_GUI_3 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ElementID_GUI_3_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ElementID_GUI_3_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ElementID_GUI_3

% Last Modified by GUIDE v2.5 11-Dec-2016 20:30:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ElementID_GUI_3_OpeningFcn, ...
    'gui_OutputFcn',  @ElementID_GUI_3_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%%%% TO DO
% 1. Map numbers to Neighbor elements
% 2. Make Neighbor selection function separate from Next File function


% --- Executes just before ElementID_GUI_3 is made visible.
function ElementID_GUI_3_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ElementID_GUI_3 (see VARARGIN)

% Choose default command line output for ElementID_GUI_3
handles.output = hObject;

handles.countLoc = 1;

handles.zState = 'Zo';

handles.xyCounts = nan(10000,2);
handles.xyBoxLocs = nan(10000,1);

% Turn buttons off to START
set(handles.startCount,'Enable','off')
set(handles.zIn,'Enable','off')
set(handles.zOut,'Enable','off')
set(handles.saveExp,'Enable','off')
set(handles.act_Opts,'Enable','off')



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ElementID_GUI_3 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ElementID_GUI_3_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function fileOpts_Callback(hObject, eventdata, handles)
% hObject    handle to fileOpts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function act_Opts_Callback(hObject, eventdata, handles) %#ok<*DEFNU,*INUSD>
% hObject    handle to act_Opts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function makeMask_Callback(hObject, eventdata, handles) %#ok<*INUSL>
% hObject    handle to makeMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ASK user to input MASK location

if handles.countLoc == 1
    handles.MasterMask = zeros(size(handles.currentIM));
    handles.TotalAllMask = false(size(handles.currentIM));
end

h = imrect;

roiPosition = wait(h);

tmpMask = h.createMask;
handles.tempMask{handles.countLoc,1} = tmpMask;

if handles.countLoc == 1
    handles.MasterMask(tmpMask) = 1;
else
    handles.MasterMask(tmpMask) = handles.countLoc;
end

delete(h)

xCoords = [roiPosition(1), roiPosition(1)+roiPosition(3), roiPosition(1)+roiPosition(3), roiPosition(1), roiPosition(1)];
yCoords = [roiPosition(2), roiPosition(2), roiPosition(2)+roiPosition(4), roiPosition(2)+roiPosition(4), roiPosition(2)];

axes(handles.imAGE);
hold on

handles.MaskCoords{handles.countLoc} = [xCoords ; yCoords];

plot(xCoords, yCoords, 'Color', 'y', 'linewidth', 2);

handles.currentIcrop = imcrop(handles.currentIM,round(roiPosition));

cla(handles.imAGE)
hold off
axes(handles.imAGE)
imshow(handles.currentIcrop)

handles.countLoc = handles.countLoc + 1;

handles.zState = 'Zi';


% TURN ON Ability to COUNT
set(handles.startCount,'Enable','on')
set(handles.zIn,'Enable','on')
set(handles.zOut,'Enable','on')

% Update handles structure
guidata(hObject, handles);



% --------------------------------------------------------------------
function saveExp_Callback(hObject, eventdata, handles)
% hObject    handle to saveExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Create generic Name based on date and time

curFname = 'O' + replace(string(datestr(now)),{'-',':',' '},'') + '_eleData.mat';

% Get user save location

[~,saveLOC,~] = uiputfile(char(curFname));

% Save empty mat file to that location
% Create data file to save .mat and .xlsx
% 1. Locations
% 2. Number
varNames = cell(1,handles.countLoc - 1);

for vi = 1:length(varNames)
    varNames{1,vi} = ['G_',num2str(vi)];
end
varNames = ['Total' , varNames];

tmpGroups = handles.xyBoxLocs(~isnan(handles.xyBoxLocs));
uniqueBls = unique(tmpGroups);
uniTots = zeros(1,numel(uniqueBls));
for ui = 1:numel(uniqueBls)
    
    uniTots(1,ui) = sum(ismember(tmpGroups,uniqueBls(ui)));
    
end


values = [sum(~isnan(handles.xyCounts(:,1))) , uniTots];

outTable = array2table(values);
outTable.Properties.VariableNames = varNames;

curFnameCSV = 'O' + replace(string(datestr(now)),{'-',':',' '},'') + '_eleData.csv';

cd(saveLOC);
save(char(curFname),'outTable');
writetable(outTable,['O' , char(replace(string(datestr(now)),{'-',':',' '},'')) , '_eleData.csv'])

handles.SaveLoc = saveLOC;
handles.dataFname = char(curFname);



set(handles.load_image,'Enable','on');
set(handles.startCount,'Enable','off')
set(handles.zIn,'Enable','off')
set(handles.zOut,'Enable','off')
set(handles.saveExp,'Enable','off')
set(handles.act_Opts,'Enable','off')


% Update handles structure
guidata(hObject, handles);





% --- Executes on button press in startCount.
function startCount_Callback(hObject, eventdata, handles)
% hObject    handle to startCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




handles.tCcounts = str2double(handles.cellCountstr.String);

keepGoing = true;

startMat = handles.tempMask{handles.countLoc - 1,1};
ind = find(startMat);


rowVals = nan(1,1000000);
for si = 1:size(startMat,1)
    ri = startMat(si,:);
    if sum(ri) == 0
        continue
    else
        rowVals(si) = si;
    end
end

rowVals = rowVals(~isnan(rowVals));

rotTot = (rowVals(end) - rowVals(1)) + 1;

colVals = nan(1,1000000);
for si = 1:size(startMat,2)
    ci = startMat(:,si);
    if sum(ci) == 0
        continue
    else
        colVals(si) = si;
    end
end

colVals = colVals(~isnan(colVals));

colTot = (colVals(end) - colVals(1)) + 1;



blankCanvas3 = false(rotTot ,colTot);



[y1, x1] = ind2sub(size(startMat), ind(1));
[y2, x2] = ind2sub(size(startMat), ind(end));
tempCanvas = startMat(y1:y2, x1:x2);
tempCanvas2 = reshape(startMat(find(startMat)), max(sum(startMat)), max(sum(startMat')));
blankCanvas = false(size(tempCanvas));
blankCanvas2 = false(size(tempCanvas2));
while keepGoing
    
    [neurPtsX , neurPtsY , buttonDn] = JATginput(1);
    
    if buttonDn ~= 1
        break
    end
    
    handles.xyCounts(handles.tCcounts,1) = neurPtsX;
    
    handles.xyCounts(handles.tCcounts,2) = neurPtsY;
    
    handles.xyBoxLocs(handles.tCcounts,1) = handles.countLoc - 1;
    
    blankCanvas(round(neurPtsX),round(neurPtsY)) = true;
    blankCanvas2(round(neurPtsX),round(neurPtsY)) = true;
    blankCanvas3(round(neurPtsX),round(neurPtsY)) = true;
    
    hold on
    
    plot(neurPtsX , neurPtsY, 'r*')
    
    handles.cellCountstr.String = num2str(handles.tCcounts);
    
    handles.tCcounts = handles.tCcounts + 1;
    
end

% BURN xy Coordinates into BW Mask
% Replace MasterMask with Burned in image
%%%%%%%%%%%%%% THIS IS WHERE I AM AT

tempryMask = handles.tempMask{handles.countLoc - 1,1};
tempryMask2 = tempryMask;

if sum(sum(tempryMask2)) == numel(blankCanvas)
    tempryMask2(tempryMask2) = blankCanvas;
elseif sum(sum(tempryMask2)) == numel(blankCanvas2)
    tempryMask2(tempryMask2) = blankCanvas2;
elseif sum(sum(tempryMask2)) == numel(blankCanvas3)
    tempryMask2(tempryMask2) = blankCanvas3;
end

handles.TotalAllMask(tempryMask == 1) = tempryMask2(tempryMask == 1);


% TURN ON SAVE
set(handles.saveExp,'Enable','on')

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in zIn.
function zIn_Callback(hObject, eventdata, handles)
% hObject    handle to zIn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if strcmp(handles.zState,'Zo')
    
    cla(handles.imAGE)
    axes(handles.imAGE)
    imshow(handles.currentIcrop)
    handles.zState = 'Zi';
    
end

guidata(hObject, handles);

% --- Executes on button press in zOut.
function zOut_Callback(hObject, eventdata, handles)
% hObject    handle to zOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

coloRS = 'rbgycm';

if strcmp(handles.zState,'Zi')
    
    cla(handles.imAGE)
    
    axes(handles.imAGE);
    
    imshow(handles.currentIM)
    drawnow
    pause(0.1)
    hold on
    
    for ci = 1:handles.countLoc - 1
        
        plot(handles.MaskCoords{1,ci}(1,:),...
            handles.MaskCoords{1,ci}(2,:),...
            'Color', coloRS(ci), 'linewidth', 2);
        pause(0.1)
    end
    handles.zState = 'Zo';
    
    pause(0.1)
    drawnow
    
    hold off
end

guidata(hObject, handles);


% --------------------------------------------------------------------
function load_image_Callback(hObject, eventdata, handles)
% hObject    handle to load_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


set(handles.updateT,'String','Working...');
set(handles.updateT,'ForegroundColor','b');
drawnow;
[imageName , dataLOC] = uigetfile('*.tiff','Select this FILE: 141221_3_aavtoRN_terms...');
cd(dataLOC)
testIm = imread(imageName);

set(handles.updateT,'String','Image file loaded...');
set(handles.updateT,'ForegroundColor','r');

axes(handles.imAGE);

handles.currentIM = testIm;

imshow(handles.currentIM)

set(handles.load_image,'Enable','off');
set(handles.act_Opts,'Enable','on')

guidata(hObject, handles);
