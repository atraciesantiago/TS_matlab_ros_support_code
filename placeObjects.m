% HW 9 --> picking up 3 green cans

%% 00 Connect to ROS (use your own masterhost IP address)
clc
clear
rosshutdown;
masterhostIP = "192.168.152.129";
rosinit(masterhostIP)

%% 02 Go Home
disp('Going home...');
goHome('qr');    % moves robot arm to a qr or qz start config

disp('Resetting the world...');
resetWorld;      % reset models through a gazebo service

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

%% 04 Pick Model
% Assign strategy: topdown, direct
strategy = 'topdown';
ret = pick(strategy, mat_R_T_M); % Can have optional starting opse for ctraj like: ret = pick(strategy, mat_R_T_M,mat_R_T_G);

%% 05 Place
if ~ret
    disp('Attempting place...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end
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
    disp('Attempting place...')
    greenBin = [-0.4, -0.45, 0.25, -pi/2, -pi 0];
    place_pose = set_manual_goal(greenBin);
    strategy = 'topdown';
    fprintf('Moving to bin...');
    ret = moveToBin(strategy,mat_R_T_M,place_pose);
end
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

%% 04 Pick Model
% Assign strategy: topdown, direct
strategy = 'topdown';
ret = pick(strategy, mat_R_T_M); % Can have optional starting opse for ctraj like: ret = pick(strategy, mat_R_T_M,mat_R_T_G);

%% 05 Place
if ~ret
    disp('Attempting place...')
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
