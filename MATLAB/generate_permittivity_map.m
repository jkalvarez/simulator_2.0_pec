%% Generates permittivity map, given relevant .in file

% Hack function - temporary
%   Grabs rebar information from .in file using format that was specified
%   in generate_environment.m
fname = './in_files/sim13.in';

%% Grab rebar information
%[x,y,radius]=textread(fname,'%*s:%f%f%*f%*f%*f%*f%f%*s','whitespace',':\n', 'headerlines',18);

%% Grab air information
%[x1, y1, x2, y2] = textread(fname,'%*s:%f%f%*f%f%f%*f%*s','whitespace',':\n', 'headerlines',18);

%% Grab general information. Test, turn into a function if it works

fid=fopen(fname,'r');  % check for success in real life...
line_data = textscan(fid,'%s%s','Delimiter',':','headerlines',18);
fid = fclose(fid);

shape = line_data{1};
size_material = line_data{2};

for i=1:size(size_material,1)
    [text,~,~,nextindex] = sscanf(size_material{i},'%f');
    text = text';
    material{i} = size_material{i}(nextindex:end);
    
    if (strcmpi(shape{i},"#box"))
    box(i,:) = text;

    
    elseif (strcmpi(shape{i},"#cylinder"))
    cylinder(i,:) = text;
    
    end
end

%material = material';

%% Environment details
discretization = 0.002;
step_size = 0.002;
x_offset = 0.1;
y_depth = 0.25;

%% draw permittivity map from location of rebars
% Permittivity scale as follows:
% e of 1 = 1, up to 1 for grayscale images
% e of 10 (concrete) = 0.5
% e of 100 (anything higher than 80 is really high and is probably water) =
% 0

% air = 1
% concrete = 0.9
% water = 0.2
% rebar = 0


% Function: divide permittivity by 100, then use negative scaled logit function
% below to calculate new image intensity values
syms f(x) g(x)
f(x) = -(0.5 +(log(x/(1-x))/log(99)/2)) + 1;
g(x) = -(0.5 +(log((x/100)/(1-(x/100)))/log(99)/2)) + 1;

air = double(g(1));
concrete = double(g(10));
water = double(g(80));
rebar = double(g(99)); 

map = ones(125, 5000);
map = map*concrete;
%map = map*0.5;

%% Due to the way layering in gprMax works, make sure to do air first then rebar

%% For air
% for i=1:size(x1,1)
%     map = insertShape(map, 'FilledRectangle',...
%         [round((x1(i)-x_offset)*1000/2), 0, ...
%         (x2(i)-x1(i))*1000*2, round((y2(i)-y1(i))*1000/2)], ...
%         'Color',[1 1 1],'Opacity', 1 );
% end

if exist('box', 'var')
    for i=1:size(box,1)
        map = insertShape(map, 'FilledRectangle',...
            [round((box(i,1)-x_offset)*1000/2), ...
            0, ...
            (box(i,4)-box(i,1))*1000*2, ...
            round((box(i,5)-box(i,2))*1000/2)], ...
            'Color',[air air air],'Opacity', 1 );
    end
end

%% For rebar
% for i=1:size(radius,1)
%     map = insertShape(map, 'FilledCircle', ...
%         [round((x(i)-x_offset)*1000/2), round((y_depth-y(i))*1000/2), radius(i)*1000*2],...
%         'Color',[0 0 0],'Opacity', 1 );     
% end



if exist('cylinder', 'var')
    cylinder_material = 0;
    
    for i=1:size(cylinder,1)
        
        if (strcmpi(material{i},"water"))
        cylinder_material = water;
        
        elseif (strcmpi(material{i},"rebar"))
        cylinder_material = rebar;
        end

        map = insertShape(map, 'FilledCircle', ...
            [round((cylinder(i,1)-x_offset)*1000/2), round(((y_depth-cylinder(i,2))*1000/2)),...
            cylinder((i),7)*1000*2],...
            'Color',...
            [cylinder_material cylinder_material cylinder_material],...
            'Opacity', 1 );     
    end
end

%% mapping
map = map(:,:,1);

im_map = mat2gray(map, [0 1]);
imshow(im_map);

imwrite(im_map,'permittivity_map_images/logit_scaled/gt13.png');

%% Added to make sure that the images are loaded fresh and variables are cleared during image creation
clear;
