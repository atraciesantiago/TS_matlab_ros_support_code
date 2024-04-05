%clc
clear
rosshutdown;
pause(2);     
masterhostIP = "192.168.152.129";
rosinit(masterhostIP);

% Reseting robot position
disp('Going home...');
goHome('qr');    % moves robot arm to a qr or qz start config

disp('Resetting the world...');
resetWorld;      % reset models through a gazebo service

%rCan1
disp('Getting goal...')
type = 'gazebo'; % gazebo, ptcloud, cam, manual
% Via Gazebo
if strcmp(type,'gazebo')
    models = getModels;                         % Extract gazebo model list
    model_name = models.ModelNames{24};         % rCan3=26, yCan1=27,rBottle2=32...%model_name = models.ModelNames{i}  

    fprintf('Picking up model: %s \n',model_name);
    [mat_R_T_G, mat_R_T_M] = get_robot_object_pose_wrt_base_link(model_name);

% Manual
elseif strcmp(type,'manual')
    % Change this to rCan1 pose
    goal = [0.8, -0.04, 0.15, -pi/2, -pi 0];     %[px,py,pz, z y z]
    % goal = [0.4, -0.5, 0.15, -pi/2, -pi 0];     %[px,py,pz, z y z]
    mat_R_T_M = set_manual_goal(goal);
else
    % Manually
    % Change this to rCan1 pose
    goal = [-1*-0.04, 0.8, 0.10, -pi/2, -pi 0];     %[px,py,pz, z y z]
    mat_R_T_M = set_manual_goal(goal);
end

strategy = 'topdown';
ret = pick(strategy, mat_R_T_M); % Can have optional starting opse for ctraj like: ret = pick(strategy, mat_R_T_M,mat_R_T_G)

if ~ret
    disp('Attempting to place rCan1...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end

if ~ret
    ret = moveToQ('qr');
end

pause(2)

%rCan2
disp('Getting goal...')
type = 'gazebo'; % gazebo, ptcloud, cam, manual

% Via Gazebo
if strcmp(type,'gazebo')
    models = getModels;                         % Extract gazebo model list
    model_name = models.ModelNames{25};         % rCan3=26, yCan1=27,rBottle2=32...%model_name = models.ModelNames{i}  

    fprintf('Picking up model: %s \n', model_name);
    [mat_R_T_G, mat_R_T_M] = get_robot_object_pose_wrt_base_link(model_name);
    % % Manual (i.e. rCan3)
elseif strcmp(type,'manual')
    goal = [0.1, 0.7, 0.35, -pi/2, -pi 0];     %[px,py,pz, z y z]
    % switch x and y from matlab matrix
    mat_R_T_M = set_manual_goal(goal);
else
    % Manually
    goal = [-1*-0.04, 0.8, 0.10, -pi/2, -pi 0];     %[px,py,pz, z y z]
    mat_R_T_M = set_manual_goal(goal);
end

strategy = 'topdown';
ret = pick(strategy, mat_R_T_M); % Can have optional starting opse for ctraj like: ret = pick(strategy, mat_R_T_M,mat_R_T_G)

if ~ret
    disp('Attempting to place rCan2...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end

if ~ret
    ret = moveToQ('qr');
end
pause(2)

%rCan3
disp('Getting goal...')
type = 'gazebo'; % gazebo, ptcloud, cam, manual

% Via Gazebo
if strcmp(type,'gazebo')
    models = getModels;                         % Extract gazebo model list
    model_name = models.ModelNames{26};         % rCan3=26, yCan1=27,rBottle2=32...%model_name = models.ModelNames{i}  

    fprintf('Picking up model: %s \n',model_name);
    [mat_R_T_G, mat_R_T_M] = get_robot_object_pose_wrt_base_link(model_name);

% Manual (i.e. rCan3)
elseif strcmp(type,'manual')
    goal = [0.8, -0.04, 0.15, -pi/2, -pi 0];     %[px,py,pz, z y z]
    mat_R_T_M = set_manual_goal(goal);
else
    % Manually
    goal = [-1*-0.04, 0.8, 0.10, -pi/2, -pi 0];     %[px,py,pz, z y z]
    mat_R_T_M = set_manual_goal(goal);
end

strategy = 'topdown';
ret = pick(strategy, mat_R_T_M); % Can have optional starting opse for ctraj like: ret = pick(strategy, mat_R_T_M,mat_R_T_G)

if ~ret
    disp('Attempting to place rCan3...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end

if ~ret
    ret = moveToQ('qr');
end

%% 02 Go Home
disp('Going home...');
goHome('qr');    % moves robot arm to a qr or qz start config

%% 03 Get Pose - gCan1 (on box)
disp('Getting goal...')
type = 'gazebo'; % gazebo, ptcloud, cam, manual

% Via Gazebo
if strcmp(type,'gazebo')
    % gCan1 - on box
    pause(3)
    models = getModels;                         % Extract gazebo model list
    model_name = models.ModelNames{20};         % rCan3=26, yCan1=27,rBottle2=32...%model_name = models.ModelNames{i}  

    fprintf('Picking up model: %s \n',model_name);
    [mat_R_T_G, mat_R_T_M] = get_robot_object_pose_wrt_base_link(model_name);
end

%% 04 Pick gCan1
% Assign strategy: topdown, direct
strategy = 'topdown';
ret = pick(strategy, mat_R_T_M); % Can have optional starting opse for ctraj like: ret = pick(strategy, mat_R_T_M,mat_R_T_G);

%% 05 Place gCan1
if ~ret
    disp('Attempting to place gCan1...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end
%% Return to home
if ~ret
    ret = moveToQ('qr');
end

pause(2)

%% 03 Get Pose - gCan2 (laying down on table)
disp('Getting goal...')
type = 'manual'; % gazebo, ptcloud, cam, manual

% Via Gazebo
if strcmp(type,'manual')
    % gCan1 - on box
    pause(3)
    goal = [0.0220, 0.3213, 0.09, -pi/2, -pi 0];     %[px,py,pz, z y z]
    mat_R_T_M = set_manual_goal(goal);
end

%% 04 Pick Model
% Assign strategy: topdown, direct
strategy = 'topdown';
ret = pick(strategy, mat_R_T_M); % Can have optional starting opse for ctraj like: ret = pick(strategy, mat_R_T_M,mat_R_T_G);

%% 05 Place
if ~ret
    disp('Attempting to place gCan2...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end
%% Return to home
if ~ret
    ret = moveToQ('qr');
end

pause(2)

%% 03 Get Pose - gCan4 (in box)
disp('Getting goal...')
type = 'gazebo'; % gazebo, ptcloud, cam, manual

% Via Gazebo
if strcmp(type,'gazebo')
    models = getModels;                         % Extract gazebo model list
    model_name = models.ModelNames{23};         % rCan3=26, yCan1=27,rBottle2=32...%model_name = models.ModelNames{i}  

    fprintf('Picking up model: %s \n',model_name);
    [mat_R_T_G, mat_R_T_M] = get_robot_object_pose_wrt_base_link(model_name);
end

%% 04 Pick gCan4
% Assign strategy: topdown, direct
strategy = 'topdown';
ret = pick(strategy, mat_R_T_M); % Can have optional starting opse for ctraj like: ret = pick(strategy, mat_R_T_M,mat_R_T_G);

%% 05 Place gCan4
if ~ret
    disp('Attempting to place gCan4...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end
%% Return to home
if ~ret
    ret = moveToQ('qr');
end

%% 02 Go Home
disp('Going home...');
goHome('qr');    % moves robot arm to a q-ready position

pause(2)

%% 03 Get Pose yCan1
disp('Getting goal...')
type = 'gazebo'; 

% Via Gazebo
if strcmp(type,'gazebo')
    models = getModels;                         % Extract gazebo model list
    model_name = models.ModelNames{27};         % yCan1

    fprintf('Picking up model: %s \n',model_name);
    [mat_R_T_G, mat_R_T_M] = get_robot_object_pose_wrt_base_link(model_name);
end 
%% 04 Pick yCan1
strategy = 'topdown';
ret = pick(strategy, mat_R_T_M);

%% 05 Place yCan1
if ~ret
    disp('Attempting to place yCan1...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end
%% Return to home
if ~ret
    ret = moveToQ('qr');
end

pause (2)
%% 03 Get Pose yCan3
disp('Getting goal...')
type = 'gazebo'; 

% Via Gazebo
if strcmp(type,'gazebo')
    models = getModels;                         % Extract gazebo model list
    model_name = models.ModelNames{29};         % yCan3

    fprintf('Picking up model: %s \n',model_name);
    [mat_R_T_G, mat_R_T_M] = get_robot_object_pose_wrt_base_link(model_name);
end 

%% 04 Pick yCan3
strategy = 'topdown';
ret = pick(strategy, mat_R_T_M);

%% 05 Place yCan3
if ~ret
    disp('Attempting place yCan3...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end
%% Return to home
if ~ret
    ret = moveToQ('qr');
end

pause (2)

%% 03 Get Pose yCan4
disp('Getting goal...')
type = 'manual';

% Via Gazebo
if strcmp(type,'manual')
   goal = [0.43,0.3669,0.09, pi/4, -pi 0];    %[px,py,pz, z y z]                  
    mat_R_T_M = set_manual_goal(goal);        % yCan4
end 

%% 04 Pick yCan4
strategy = 'topdown';
ret = pick(strategy, mat_R_T_M);

%% 05 Place yCan4
if ~ret
    disp('Attempting to place yCan4...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end
%% Return to home
if ~ret
    ret = moveToQ('qr');
end

pause (5)

% Reseting robot position
disp('Going home...');
goHome('qr');    % moves robot arm to a qr or qz start config