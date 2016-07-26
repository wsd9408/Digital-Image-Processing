function varargout = Design(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Design_OpeningFcn, ...
                   'gui_OutputFcn',  @Design_OutputFcn, ...
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
function Design_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
set(handles.axes1,'visible','off');%读取图片前，设置坐标系不可见
set(handles.axes2,'visible','off');%读取图片前，设置坐标系不可见
set(handles.imshow,'enable','off');             %获取检测图以及模板图之前，图像匹配不可使用
set(handles.change2gray,'enable','off');%获取到模板图之后，灰度转换的按钮不可以使用
function varargout = Design_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function change2gray_Callback(hObject, eventdata, handles)
global ima                                    %转化前的检测图
global moban                               %转化前的模板图
global ima2gray                          %转换后的检测图
global moban2gray                     %转换后的模板图

ima2gray=rgb2gray(ima);%将原图象转换为灰度图象
moban2gray=rgb2gray(moban);%将匹配图象转换为灰度图象
axes(handles.axes1),imshow(ima2gray);
axes(handles.axes2),imshow(moban2gray);
function imshow_Callback(hObject, eventdata, handles)
global ima                                    %转化前的检测图
global moban                               %转化前的模板图
global ima2gray                          %转换后的检测图
global moban2gray                     %转换后的模板图
global current_huidu;                  %统计执行过程中的时间
ima_detect = rgb2gray(ima);
moban_detect = rgb2gray(moban);
if get(handles.tezheng,'value')
ima_detect  = edge(ima_detect,'Sobel');
moban_detect = edge(moban_detect,'Sobel')
%基于特征的图像匹配算法
t1 = clock;
n1=0;n2=0;
global ii
global  jj
for i=1:256
for j=1:256
for m=1:68 %为了简化计算时间，规定模板大小为68*68
for n=1:68
if moban_detect(m,n)==ima_detect(i+m-1,j+n-1)
n1=n1+1;
end
end
end
if n1>n2
n2=n1;
ii=i
jj=j
end
n1=0;
end
end
ii
jj
for z=ii:ii+68
ima(z,jj+68)=1;
ima(z,jj)=1;
end
for z=jj:jj+68
ima(ii,z)=1;
ima(ii+68,z)=1;
end
t2 = clock;
axes(handles.axes1),imshow(ima);
axes(handles.axes2),imshow(moban);
end
if get(handles.huidu,'value')
%基于灰度的图像匹配算法
axes(handles.axes1),imshow(ima);
[moban_height,moban_width]=size(moban_detect);    %获取模板图象的大小尺寸，其值为[长，宽],将匹配图象的长度值赋给moban_width,将匹配图象的宽度值赋给moban_height
[ima_height,ima_width]=size(ima_detect);                    %获取检测图象的大小尺寸，其值为[长，宽],将原图象的长度值赋给moban_height,将原图象的宽度值赋给moban_widt
hold on;
t1 = clock;                                                           %起始时间
[a b d]=size(ima_detect);
[m n d]=size(moban_detect);
N=n;%模板尺寸，默认模板为正方形
M=a;%代搜索图像尺寸，默认搜索图像为正方形
dst=zeros(M-N,M-N);
for i=1:M-N         %行
for j=1:M-N
temp=ima_detect(i:i+N-1,j:j+N-1);
dst(i,j)=dst(i,j)+sum(sum(abs(temp-moban_detect)));
end
end
abs_min=min(min(dst));
[x,y]=find(dst==abs_min);

rectangle('position',[x,y,N-1,N-1],'edgecolor','b');
t2 = clock;                                                          %终止时间
axes(handles.axes2),imshow(moban);
end
current_huidu = etime(t2,t1);                            %统计执行过程的时间
set(handles.edit,'string',current_huidu);              %将执行时间赋值给Edit文本中

%%加入噪声
function imnoise_Callback(hObject, eventdata, handles)
global ima;
ima = imnoise(ima,'salt & pepper',0.02); %加入椒盐噪声
axes(handles.axes1),imshow(ima);            %将带有噪声的图像展示出来
%%消除噪声
function removeNoise_Callback(hObject, eventdata, handles)
global ima;
hsi_R = ima(:,:,1);
hsi_G  = ima(:,:,2);
hsi_B  = ima(:,:,3);
hsi_R = removeNoise(hsi_R);
hsi_G = removeNoise(hsi_G);
hsi_B = removeNoise(hsi_B); %利用高斯均值滤波器对噪声进行过滤
ima = cat(3,hsi_R,hsi_G,hsi_B);%把三幅图像加载一起
axes(handles.axes1),imshow(ima);  %将消除噪声的图像展示出来

% --------------------------------------------------------------------
%%保存图像
function m_save_Callback(hObject, eventdata, handles)
[filename,pathname] = uiputfile({'*.bmp','BMPfiles';'*.jpg;','JPGfiles'},'请选择保存的图片');
if isequal(filename ,0)||isequal(pathname,0)
return ;%如果点了“取消”
else
fpath = fullfile(pathname,filename);%获得全路径的另一种方法
end
img_dst=getimage(handles.axes1);
imwrite(img_dst,fpath);%保存图片
% --------------------------------------------------------------------
%退出系统
function m_quit_Callback(hObject, eventdata, handles)
close(handles.figure1);
clear global variable
% --------------------------------------------------------------------
%打开
function m_detect_Callback(hObject, eventdata, handles)
%加载检测图片
global ima  %检测图的全局变量
[filename,path] = uigetfile({'*.bmp;  *.jpg;  *.png;*.jpeg;'  'Image File(*.bmp,*.jpg,*.png,*.jpeg)';...
    '*.*','All Files(*.*)'},'请选择检测图');
str = [path filename];    %获取检测图的路径
ima = imread(str);         %读取检测图
axes(handles.axes1);
imshow(ima);
% --------------------------------------------------------------------
%加载模板图片
function m_moban_Callback(hObject, eventdata, handles)
global moban %模板图的全局变量
[filename,path] = uigetfile({'*.bmp;  *.jpg;  *.png;*.jpeg;'  'Image File(*.bmp,*.jpg,*.png,*.jpeg)';...
    '*.*','All Files(*.*)'},'请选择模板图');
str = [path filename];    %获取检测图的路径
moban = imread(str);         %读取检测图
axes(handles.axes2);
imshow(moban);
set(handles.imshow,'enable','on');   %获取到模板图之后，图像匹配的按钮可以使用
set(handles.change2gray,'enable','on');%获取到模板图之后，灰度转换的按钮可以使用
function edit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
set(hObject,'BackgroundColor','white');
end
% --------------------------------------------------------------------
%清除工作区间
function clear_Callback(hObject, eventdata, handles)
delete(allchild(handles.axes1)); %
delete(allchild(handles.axes2));
set(handles.edit, 'String', ' ');

%以下函数没有实际功能，但是如果删除会导致报错。
% --------------------------------------------------------------------
function m_open_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_file_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function m_help_Callback(hObject, eventdata, handles)
