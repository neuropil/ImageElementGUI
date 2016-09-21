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

% Last Modified by GUIDE v2.5 21-Sep-2016 11:41:42

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


%%%% TO DO
% 1. Map numbers to Neighbor elements
% 2. Make Neighbor selection function separate from Next File function


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

set(handles.load_im,'Enable','off');
set(handles.makeMask,'Enable','off');
set(handles.idBlobs,'Enable','off');


handles.curCen = nan;



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
[~ , dataLOC] = uigetfile('*.tiff','Select this FILE: 141221_3_aavtoRN_terms...');
cd(dataLOC)
testIm = imread('141221_3_aavtoRN_terms in dentate_5 - Position 0 [600].Project Maximum Z Montage_XY1431635444_Z0_T0_C0.tiff');
normIM = double(testIm)/double(max(max(testIm)));
normIM2 = normIM;
normIM2(normIM2 <= 0.28) = 0;
BW = imbinarize(normIM2,0.28);
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


set(handles.makeMask,'Enable','on');
set(handles.saveExp,'Enable','off');
set(handles.load_im,'Enable','off');

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
prompt = {'Enter NAME of POLYGON location'};
name = 'ROI Anatomy';
defaultans = {'Red Nucleus'};
options.Interpreter = 'tex';
answer = inputdlg(prompt,name,[1 40],defaultans,options);

% Save name of MASK for dataOUT
handles.dataOUT.polyName = string(answer);


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

% Remove small stuff
sizeBlobs = cellfun(@(x) size(x,1), allBlobs);
smallActInd = find(sizeBlobs <= 9);
smallInd = sizeBlobs <= 9;
nallBlobs = allBlobs(~smallInd);

for bi = 1:length(smallActInd)
   
    tmpLabs = false(size(allLabels));
    tmpLabs(allLabels == smallActInd(bi)) = 1;
    allLabels(tmpLabs) = 0;
    
end



handles.allBlobs = nallBlobs;
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

dataOUTp.polygon = handles.polygonMask;
dataOUTp.polyName = handles.dataOUT.polyName;
cd(handles.SaveLoc);
save(handles.dataFname,'-append','dataOUTp');

% Update buttons

set(handles.makeMask,'Enable','off');
set(handles.load_im,'Enable','off');
set(handles.idBlobs,'Enable','on');



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


set(handles.makeMask,'Enable','off');
set(handles.load_im,'Enable','off');
set(handles.idBlobs,'Enable','off');



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


% Aggregate Data to save
dataOUT.elemData = handles.elemData;
dataOUT.elemMasks = handles.allBlobs;
dataOUT.numericIDs = handles.allLabels; %#ok<*STRNU>
curElement = handles.eleCur; %#ok<NASGU>

handles.dataOUT = dataOUT;
% Save temp data
cd(handles.SaveLoc)
save(handles.dataFname, '-append','dataOUT','curElement'); 

% Advance to next element
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


% Clear the current axes
cla(handles.imAGE)

if handles.eleCur > max(unique(handles.allLabels))
    return
else
    
    
    % ALL labels - Mask based on dimensions of pixel box with INTEGER IDs
    % 1) All Labels
    curAllLabs = handles.allLabels;
    curAllcens = handles.allCentroids;
    % 1) Binary matrix
    curLabel = false(size(handles.allLabels));
    % 2) Check for current element in current labels
    if sum(sum(handles.allLabels == handles.eleCur)) == 0
        handles.eleCur = handles.eleCur + 1;
        
        [handles] = next_file(handles);
    end
    
    % 3) Binary matrix with TRUE for current element
    curLabel(handles.allLabels == handles.eleCur) = 1;
    % 4)
    tmpBox = handles.ImageBox;
    tmpBox(~curLabel) = 0;
    
    [sizeCheck,~,~,~] = bwboundaries(tmpBox,'noholes');
    
    if size(sizeCheck{1,1},1) < 9
        
        % Remove element centroid
        rmIND = false(length(curAllcens),2);
        rmIND(handles.eleCur,:) = true;
        newAllcens = curAllcens;
        newAllcens(rmIND) = nan;
        handles.allCentroids = newAllcens;
        % Remove element centroid and blob
        curAllLabs(curAllLabs == handles.eleCur) = 0;
        handles.allLabels = curAllLabs;
        
        handles.eleCur = handles.eleCur + 1;
        
        [handles] = next_file(handles);
        
    end
    
    handles.elemData{handles.eleCur,1} = curLabel;
    handles.elemData{handles.eleCur,2} = tmpBox;
    
    if isnan(handles.curCen)
        
        centrO = regionprops(curLabel,'centroid');
        centroi = round(centrO.Centroid);
        centrOii = centrO.Centroid;
        
    else
        
        centroi = handles.curCen;
        centrOii = handles.curCen;
        
    end
    
    exhaustMDL = ExhaustiveSearcher(curAllcens);
    neighINDS = knnsearch(exhaustMDL,centrOii,'K',6);
    
    neighINDSuse = neighINDS(~ismember(neighINDS,handles.eleCur));
    handles.neighElInds = neighINDSuse;
    
    % Create mask for neighbors
    curAllLabel = false(size(handles.allLabels));
    neighBlobs = zeros(size(handles.allLabels));
    neighCens = false(size(handles.allLabels));
    % tmpNeighLabs = [11:11:55];
    for ni = 1:numel(neighINDSuse)
        
        tmpLabMask = curAllLabs == neighINDSuse(ni);
        curAllLabel(tmpLabMask) = true;
        neighBlobs(tmpLabMask) = neighINDSuse(ni);
        neighCens(tmpLabMask) = true;
        
    end
    
    handles.neighBlobs = neighBlobs;
    
    handles.tmpCen = centroi;
    
    centroids = centroi;
    
    [ xStrt , xEnd , yStrt , yEnd ] = viewBoxDims( centroids );
    
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
    for ci = 1:length(B3)
        
        plot(handles.B3{ci,1}(:,2), handles.B3{ci,1}(:,1), 'r','LineWidth',0.05);
        
    end
    for pi = 1:length(B4)
        
        plot(handles.B4{pi,1}(:,2), handles.B4{pi,1}(:,1), 'g','LineWidth',0.05);
        text(min(handles.B4{pi,1}(:,2)),max(handles.B4{pi,1}(:,1)),num2str(pi),...
            'Color','m',...
            'FontWeight','Bold',...
            'FontSize',14,'VerticalAlignment','top')
        
    end
    
    set(handles.actComb,'Enable','on');
    
end
    
    
    


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



