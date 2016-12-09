function varargout = ElementID_GUI_2(varargin)
% ELEMENTID_GUI_2 MATLAB code for ElementID_GUI_2.fig
%      ELEMENTID_GUI_2, by itself, creates a new ELEMENTID_GUI_2 or raises the existing
%      singleton*.
%
%      H = ELEMENTID_GUI_2 returns the handle to a new ELEMENTID_GUI_2 or the handle to
%      the existing singleton*.
%
%      ELEMENTID_GUI_2('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELEMENTID_GUI_2.M with the given input arguments.
%
%      ELEMENTID_GUI_2('Property','Value',...) creates a new ELEMENTID_GUI_2 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ElementID_GUI_2_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ElementID_GUI_2_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ElementID_GUI_2

% Last Modified by GUIDE v2.5 06-Dec-2016 13:54:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ElementID_GUI_2_OpeningFcn, ...
    'gui_OutputFcn',  @ElementID_GUI_2_OutputFcn, ...
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


% --- Executes just before ElementID_GUI_2 is made visible.
function ElementID_GUI_2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ElementID_GUI_2 (see VARARGIN)

% Choose default command line output for ElementID_GUI_2
handles.output = hObject;


handles.countLoc = 1;



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ElementID_GUI_2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ElementID_GUI_2_OutputFcn(hObject, eventdata, handles)
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
function load_im_Callback(hObject, eventdata, handles)
% hObject    handle to load_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.updateT,'String','Working...');
set(handles.updateT,'ForegroundColor','b');
drawnow;
[~ , dataLOC] = uigetfile('*.tiff','Select this FILE: 141221_3_aavtoRN_terms...');
cd(dataLOC)
testIm = imread('141221_3_aavtoRN_terms in dentate_5 - Position 0 [600].Project Maximum Z Montage_XY1431635444_Z0_T0_C0.tiff');
% normIM = double(testIm)/double(max(max(testIm)));
% normIM2 = normIM;
% normIM2(normIM2 <= 0.28) = 0;
% BW = imbinarize(normIM2,0.28);
% bwImRfids = bwareaopen(BW,9);
% normMaskIm = normIM2;
% normMaskIm(~bwImRfids) = 0;
% handles.normalMask = normMaskIm;
%
% extraIM = bwImRfids;
% handles.bwImageFields = extraIM;
%
% set(handles.updateT,'String','Image file loaded...');
% set(handles.updateT,'ForegroundColor','r');

handles.currentIM = testIm;

axes(handles.imAGE);

imshow(testIm)




% Update handles structure
guidata(hObject, handles);





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
end

h = imrect;

roiPosition = wait(h);

tmpMask = h.createMask;

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

plot(xCoords, yCoords, 'Color', 'y', 'linewidth', 2);

handles.currentIcrop = imcrop(handles.currentIM,round(roiPosition));

cla(handles.imAGE)
hold off
axes(handles.imAGE)
imshow(handles.currentIcrop)

handles.countLoc = handles.countLoc + 1;

% Update handles structure
guidata(hObject, handles);


% --------------------------------------------------------------------
function idBlobs_Callback(hObject, eventdata, handles)
% hObject    handle to idBlobs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



cla(handles.imAGE)

[handles] = next_file(handles);

for i = 1:6
    set(handles.(['rb',num2str(i)]),'Enable','on');
end



% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in actComb.
function actComb_Callback(hObject, eventdata, handles)
% hObject    handle to actComb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of actComb

set(handles.comEle,'Visible','on');
set(handles.acpEle,'Enable','on');

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in acpEle.
function acpEle_Callback(hObject, eventdata, handles)
% hObject    handle to acpEle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% CHECK VALUES AND UPDATE HANDLES
% 1. Get current element index
% 2. Get current element blob info
% 3. Get neighbor elements indices
% 4. Get neighbor elements blobs info
% 5. Get master list of blobs
% 6. Get total number of blobs
% 7. Determine which neighbors were selected
% 8. Combine those masks into a new mask
% 9. Update the following:
% a. Current Blob info
% b. Current Blob count
% c. Total Blob info
% d. Total Blob count
% 10. FIX blob total count
% 11. Update Handles

% 1.
currentEl = handles.eleCur;
% 2.
currentBlob = handles.elemData{currentEl,1};
% 3.
neighINDS = handles.neighElInds;
% 4.
neighBlobs = handles.neighBlobs;
% 5.
curAllLabs = handles.allLabels;
% 6.
% totalElnum = handles.totalEle;
% 7.
comINDS = false(1,5);
for chI = 1:5
    
    tmpChk = get(handles.(['ele',num2str(chI)]),'String');
    if str2double(tmpChk)
        comINDS(chI) = true;
    end
    
end
comActInds = neighINDS(comINDS);
% 8.
keepNeiBmask = false(size(neighBlobs));
for kni = 1:sum(comINDS)
    keepNeiBmask(neighBlobs == comActInds(kni)) = true;
end

newBlobMask = currentBlob;
newBlobMask(keepNeiBmask) = true;

% 9.
%%%%%%%%%%%%%%%%%%%%%%% CHECK

% 10.
% a. Update CURRENT element blob mask
handles.elemData{currentEl,1} = newBlobMask;
% b. Update ALL element blobs
%    1. Overwwrite current blob
curAllLabs(curAllLabs == currentEl) = 0;
curAllLabs(newBlobMask) = currentEl;

curAllcens = handles.allCentroids;
curAllcens(comActInds,:) = nan;
handles.allCentroids = curAllcens;

%    3. Remove merged blobs
% keepBlobsInd = true(length(curAllLabs));
% keepBlobsInd(comActInds) = false;
% newAllBlobs = curAllLabs(keepBlobsInd);
handles.allLabels = curAllLabs;

handles.curCen = handles.tmpCen;

% Reinitiate Next file
[handles] = next_file(handles);

set(handles.actComb,'Enable','off');
set(handles.comEle,'Visible','off');
set(handles.acpEle,'Enable','off');



% --------------------------------------------------------------------
function saveExp_Callback(hObject, eventdata, handles)
% hObject    handle to saveExp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Create generic Name based on date and time

curFname = 'O' + replace(string(datestr(now)),{'-',':',' '},'') + '_eleData.mat';

% Get user save location

[~,saveLOC,~] = uiputfile(char(curFname));
dataOUTn.saveLOC = saveLOC;

% Save empty mat file to that location
cd(saveLOC);
save(char(curFname),'dataOUTn');

handles.SaveLoc = saveLOC;
handles.dataFname = char(curFname);



set(handles.load_pre,'Enable','off');
set(handles.load_im,'Enable','on');
set(handles.saveExp,'Enable','off');

% Update handles structure
guidata(hObject, handles);




% --------------------------------------------------------------------
function load_pre_Callback(hObject, eventdata, handles)
% hObject    handle to load_pre (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[fileName,saveLOC,~] = uigetfile();
load(fileName);


% Save empty mat file to that location


handles.SaveLoc = saveLOC;
handles.dataFname = char(fileName);

% ADD ADDitional Handles %%%%%%%% Need to ADD

% [handles] = next_file(handles);

set(handles.load_im,'Enable','on');
set(handles.load_pre,'Enable','off');
set(handles.saveExp,'Enable','off');

% Update handles structure
guidata(hObject, handles);




% --- Executes on button press in startCount.
function startCount_Callback(hObject, eventdata, handles)
% hObject    handle to startCount (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


xyCounts = zeros(10000,2);
Ccount = 1;
keepGoing = true;

while keepGoing
    
    [neurPtsX , neurPtsY, buttonDn] = JATginput(1);
    
    if buttonDn ~= 1
        break
    end
    
    xyCounts(Ccount,1) = neurPtsX;
    xyCounts(Ccount,2) = neurPtsY;
    
    hold on
    
    plot(neurPtsX , neurPtsY, 'r*')
    
    
    handles.cellCountstr.String = num2str(Ccount);
    
    Ccount = Ccount + 1;
    
    
    
    
    
    
    
end

% BURN xy Coordinates into BW Mask
% Replace MasterMask with Burned in image


% Update handles structure
guidata(hObject, handles);
