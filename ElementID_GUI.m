function varargout = ElementID_GUI(varargin)
% ELEMENTID_GUI MATLAB code for ElementID_GUI.fig
%      ELEMENTID_GUI, by itself, creates a new ELEMENTID_GUI or raises the existing
%      singleton*.
%
%      H = ELEMENTID_GUI returns the handle to a new ELEMENTID_GUI or the handle to
%      the existing singleton*.
%
%      ELEMENTID_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ELEMENTID_GUI.M with the given input arguments.
%
%      ELEMENTID_GUI('Property','Value',...) creates a new ELEMENTID_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ElementID_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ElementID_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ElementID_GUI

% Last Modified by GUIDE v2.5 14-Sep-2016 11:15:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ElementID_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ElementID_GUI_OutputFcn, ...
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


% --- Executes just before ElementID_GUI is made visible.
function ElementID_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ElementID_GUI (see VARARGIN)

% Choose default command line output for ElementID_GUI
handles.output = hObject;

for i = 1:6
    set(handles.(['rb',num2str(i)]),'Value',0);
    set(handles.(['rb',num2str(i)]),'Enable','off');
end

set(handles.actComb,'Enable','off');
set(handles.comEle,'Visible','off');
set(handles.acpEle,'Enable','off');

for i = 1:5
    set(handles.(['rb',num2str(i)]),'Enable','off');
end




% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ElementID_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ElementID_GUI_OutputFcn(hObject, eventdata, handles) 
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
cd('E:\Dropbox\Bietzel_Matlab')
testIm = imread('141221_3_aavtoRN_terms in dentate_5 - Position 0 [600].Project Maximum Z Montage_XY1431635444_Z0_T0_C0.tiff');
normIM = double(testIm)/double(max(max(testIm)));
normIM2 = normIM;
normIM2(normIM2 <= 0.28) = 0;
BW = im2bw(normIM2,0.28);
bwImRfids = bwareaopen(BW,9);
normMaskIm = normIM2;
normMaskIm(~bwImRfids) = 0;
handles.normalMask = normMaskIm;

extraIM = bwImRfids;
handles.bwImageFields = extraIM;

set(handles.updateT,'String','Image file loaded...');
set(handles.updateT,'ForegroundColor','r');

axes(handles.imAGE);

imshow(handles.bwImageFields)

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

set(handles.updateT,'String','Draw Polygon...');
set(handles.updateT,'ForegroundColor','b');
drawnow;

tmpPoly = roipoly();

handles.polygonMask = tmpPoly;

extraIM = handles.bwImageFields;

extraIM(~tmpPoly) = 0;

handles.bwImageFields = extraIM;

set(handles.updateT,'String','Polygon Saved!');
set(handles.updateT,'ForegroundColor','b');
drawnow
pause(0.5);
set(handles.updateT,'String','Computing blobs...!');
set(handles.updateT,'ForegroundColor','g');
drawnow

[polyS,~,~,~] = bwboundaries(tmpPoly,'noholes');
[pW1,pW2,pH1,pH2] = getBoxBounds(polyS{1,1},1);
% h = imrect(gca, [pH1 pW1 pH2 pW2]);

roIbox = imcrop(extraIM,[pH1 pW1 pH2 pW2]);
normBox = imcrop(handles.normalMask,[pH1 pW1 pH2 pW2]);

handles.ROIBox = roIbox;
handles.ImageBox = normBox;

[allBlobs,~,~,~] = bwboundaries(roIbox,'noholes');
allLabels = bwlabel(roIbox);

handles.allBlobs = allBlobs;
handles.allLabels = allLabels;

tmpCenAll = regionprops(handles.allLabels,'centroid');

% 2) Extract info from struct
allCentroids = zeros(length(tmpCenAll),2);
for ci = 1:length(tmpCenAll)
    allCentroids(ci,:) = tmpCenAll(ci).Centroid;
end

handles.allCentroids = allCentroids;

handles.eleCur = 1;
handles.totalEle = length(handles.allBlobs);
handles.elemData = cell(length(handles.allBlobs),4);

set(handles.updateT,'String','Blobs Done...!');
set(handles.updateT,'ForegroundColor','r');



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
    


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch get(eventdata.NewValue,'String') % Get Tag of selected object.
    case 'rosette'
        handles.elemData{handles.eleCur,3} = 'rosette';
        handles.eleCur = handles.eleCur + 1;
    case 'bouton'
        handles.elemData{handles.eleCur,3} = 'bouton';
        handles.eleCur = handles.eleCur + 1;
    case 'fil-bouton'
        handles.elemData{handles.eleCur,3} = 'fil-bouton';
        handles.eleCur = handles.eleCur + 1;
    case 'axon'
        handles.elemData{handles.eleCur,3} = 'axon';
        handles.eleCur = handles.eleCur + 1;
    case 'noise'
        handles.elemData{handles.eleCur,3} = 'noise';
        handles.eleCur = handles.eleCur + 1;
    case 'unknown'
        handles.elemData{handles.eleCur,3} = 'unknown';
        
        userNote = inputdlg('Note',...
            'Write note...', [1 40]);
        
        handles.elemData{handles.eleCur,34} = userNote;
        
        handles.eleCur = handles.eleCur + 1;
end

for i = 1:6
    set(handles.(['rb',num2str(i)]),'Value',0);
end

[handles] = next_file(handles);

% Update handles structure
guidata(hObject, handles);





% --- JAT's FUNCTION.
function [handles] = next_file(handles)

%%%% TO DO
% 1. Create combine YES or NO buttom check
% 2. If YES
% 3. Populate with all 0
% 4. Activate button to complete
% 5. When complete OVERWRITE FOLLOWING PARAMETERS
% handles.allBlobs = allBlobs;
% handles.allLabels = allLabels;
% 
% tmpCenAll = regionprops(handles.allLabels,'centroid');
% 
% % 2) Extract info from struct
% allCentroids = zeros(length(tmpCenAll),2);
% for ci = 1:length(tmpCenAll)
%     allCentroids(ci,:) = tmpCenAll(ci).Centroid;
% end
% 
% handles.allCentroids = allCentroids;
% 
% handles.eleCur = 1;
% handles.totalEle = length(handles.allBlobs);
% handles.elemData = cell(length(handles.allBlobs),4);


% Clear the current axes
cla(handles.imAGE)

% ALL labels - Mask based on dimensions of pixel box with INTEGER IDs
% 1) All Labels
curAllLabs = handles.allLabels;
curAllcens = handles.allCentroids;
% 1) Binary matrix 
curLabel = false(size(handles.allLabels));
% 2) Binary matrix with TRUE for current element
curLabel(handles.allLabels == handles.eleCur) = 1;
% 3) 
tmpBox = handles.ImageBox;
tmpBox(~curLabel) = 0;

handles.elemData{handles.eleCur,1} = curLabel;
handles.elemData{handles.eleCur,2} = tmpBox;

centrO = regionprops(curLabel,'centroid');
centroi = round(centrO.Centroid);

exhaustMDL = ExhaustiveSearcher(curAllcens);
neighINDS = knnsearch(exhaustMDL,centrOii,'K',6);

neighINDSuse = neighINDS(~ismember(neighINDS,handles.eleCur));
handles.neighElInds = neighINDSuse;

% Create mask for neighbors
curAllLabel = false(size(handles.allLabels));
neighBlobs = false(size(handles.allLabels));
% tmpNeighLabs = [11:11:55];
for ni = 1:numel(neighINDSuse)
   
    tmpLabMask = curAllLabs == neighINDSuse(ni);
    curAllLabel(tmpLabMask) = true;
    neighBlobs(tmpLabMask) = neighINDSuse(ni);
    
end

handles.neighBlobs = neighBlobs;

if centroi(1) < 150;
    xStrt = 1;
else
    xStrt = round(centroi(1)) - 150;
    if xStrt == 0
        xStrt = 1;
    end
end
xEnd = round(centroi(1)) + 150;

if centroi(2) < 150;
    yStrt = 1;
else
    yStrt = round(centroi(2)) - 150;
    if yStrt == 0
        yStrt = 1;
    end
end
yEnd = round(centroi(2)) + 150;

I2 = handles.ImageBox(yStrt:yEnd,xStrt:xEnd);
I3 = tmpBox(yStrt:yEnd,xStrt:xEnd);
I4 = curAllLabel(yStrt:yEnd,xStrt:xEnd);

handles.I2 = I2;
handles.I3 = I3;
handles.I4 = I4;
handles.tmpBox = tmpBox;

[B3,~,~,~] = bwboundaries(I3,'noholes');
handles.B3 = B3;

[B4,~,~,~] = bwboundaries(I4,'noholes');
handles.B4 = B4;
    
axes(handles.imAGE);
imshow(handles.I2);
hold on;
plot(handles.B3{1,1}(:,2), handles.B3{1,1}(:,1), 'r','LineWidth',0.05);
for pi = 1:length(B4)
    
    plot(handles.B4{pi,1}(:,2), handles.B4{pi,1}(:,1), 'g','LineWidth',0.05);
    
end

set(handles.actComb,'Enable','on');
    
    
    


% --- Executes on button press in actComb.
function actComb_Callback(hObject, eventdata, handles)
% hObject    handle to actComb (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of actComb

set(handles.comEle,'Visible','on');
set(handles.acpEle,'Enable','on');



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
% 9. Overwite current blob index with new blob and centroid info
% 10. FIX blob total count

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
totalElnum = handles.totalEle;
% 7.
comINDS = false(1,5);
for chI = 1:5
    
    tmpChk = get(handles.(['ele',num2str(chI)]),'Value');
    if tmpChk
        comINDS(chI) = true;
    end
    
end
% 8. 


% 9.


% 10.







set(handles.actComb,'Enable','off');
set(handles.comEle,'Visible','off');
set(handles.acpEle,'Enable','off');










function ele1_Callback(hObject, eventdata, handles)
% hObject    handle to ele1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ele1 as text
%        str2double(get(hObject,'String')) returns contents of ele1 as a double

% --- Executes during object creation, after setting all properties.
function ele1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ele1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ele2_Callback(hObject, eventdata, handles)
% hObject    handle to ele2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ele2 as text
%        str2double(get(hObject,'String')) returns contents of ele2 as a double

% --- Executes during object creation, after setting all properties.
function ele2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ele2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ele3_Callback(hObject, eventdata, handles)
% hObject    handle to ele3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ele3 as text
%        str2double(get(hObject,'String')) returns contents of ele3 as a double

% --- Executes during object creation, after setting all properties.
function ele3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ele3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ele4_Callback(hObject, eventdata, handles)
% hObject    handle to ele4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ele4 as text
%        str2double(get(hObject,'String')) returns contents of ele4 as a double

% --- Executes during object creation, after setting all properties.
function ele4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ele4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ele5_Callback(hObject, eventdata, handles)
% hObject    handle to ele5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ele5 as text
%        str2double(get(hObject,'String')) returns contents of ele5 as a double

% --- Executes during object creation, after setting all properties.
function ele5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ele5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



