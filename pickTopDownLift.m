% HW 8 Part D --> pick up rCan3

rosshutdown
rosinit('192.168.152.129')

trajAct = rosactionclient('/pos_joint_traj_controller/follow_joint_trajectory','control_msgs/FollowJointTrajectory') 
trajGoal = rosmessage(trajAct)

jointSub = rossubscriber("/joint_states")


% Now, let's receive the data and use it to compute the IKs and get the pose of the end-effector.
jointStateMsg = jointSub.LatestMessage


% Setup Robot Model for Inverse Kinematics
UR5e = loadrobot('universalUR5e', DataFormat="row")


% Adjust the forward kinematics to match the URDF model in Gazebo:
tform=UR5e.Bodies{3}.Joint.JointToParentTransform;    
UR5e.Bodies{3}.Joint.setFixedTransform(tform*eul2tform([pi/2,0,0]));

tform=UR5e.Bodies{4}.Joint.JointToParentTransform;
UR5e.Bodies{4}.Joint.setFixedTransform(tform*eul2tform([-pi/2,0,0]));

tform=UR5e.Bodies{7}.Joint.JointToParentTransform;
UR5e.Bodies{7}.Joint.setFixedTransform(tform*eul2tform([-pi/2,0,0]));


% Create the numerical IK solver:
ik = inverseKinematics("RigidBodyTree",UR5e); % Create Inverse kinematics solver


% Set the weights
ikWeights = [0.25 0.25 0.25 0.1 0.1 .1]; % configuration weights for IK solver [Translation Orientation] see documentation


% Before proceeding, get the latest joint angles of the robot by calling receive (blocking function).
jointStateMsg = receive(jointSub,10) % receive current robot configuration


% Let's set the numerical IK guess to the current configuration:
initialIKGuess = homeConfiguration(UR5e)


% One thing to be careful is to copy the correct order from jointStateMsg.Position to our structure initialIKGuess. 
% To know the order, look at the names:
jointStateMsg.Name
% So, order is: 
% elbow:3
% knuckle: 7
% lift: 2
% pan:1
% wrist1: 4
% wrist2: 5
% wist3:6 
initialIKGuess(1) = jointStateMsg.Position(4); % update configuration in initial guess
initialIKGuess(2) = jointStateMsg.Position(3);
initialIKGuess(3) = jointStateMsg.Position(1);
initialIKGuess(4) = jointStateMsg.Position(5) - 0.5; % elbow up configuration
initialIKGuess(5) = jointStateMsg.Position(6);
initialIKGuess(6) = jointStateMsg.Position(7);
show(UR5e,initialIKGuess)


% Set End-Effector Pose
gripperX = -0.038;
gripperY = 0.80;
% maintain initial height
gripperZ1 = 0.34;
% lower height to rCan3
gripperZ2 = 0.13;

gripperTranslation1 = [gripperX gripperY gripperZ1];
gripperTranslation2 = [gripperX gripperY gripperZ2];
gripperRotation = [-pi/2 -pi 0]; %  [Z Y X]radians

tform = eul2tform(gripperRotation); % ie eul2tr call
tform(1:3,4) = gripperTranslation1'; % set translation in homogeneous transform
tform(1:3,4) = gripperTranslation2'; % set translation in homogeneous transform


% Finally, compute the IKs:
[configSoln, solnInfo] = ik('tool0',tform,ikWeights,initialIKGuess)

show(UR5e,configSoln)

UR5econfig = [configSoln(3)... 
              configSoln(2)...
              configSoln(1)...
              configSoln(4)...
              configSoln(5)...
              configSoln(6)]


% Let's use a packing function to appropriately fill names and positions:
trajGoal = packTrajGoal(UR5econfig,trajGoal)

% Send to the action server:
if waitForServer(trajAct)
    [move_result,move_state,move_status] = sendGoalAndWait(trajAct,trajGoal);
else 
    move_result = -1; move_state = 'failed'; move_status = 'could not find server';
end

% closing gripper around can
grip_client = rosactionclient('/gripper_controller/follow_joint_trajectory','control_msgs/FollowJointTrajectory', 'DataFormat', 'struct');
gripGoal = rosmessage(grip_client);
gripPos = 0.23;
gripGoal = packGripGoal(gripPos,gripGoal);

if waitForServer(grip_client)
    [grip_result,grip_state,grip_status] = sendGoalAndWait(grip_client,gripGoal);
else
    grip_result = -1; grip_state = 'failed'; grip_status = 'could not find server';
end

% pause of 3 secs to allow gripper to close around can
pause(3)

% lift can
joint_state_sub = rossubscriber("/joint_states");
ros_cur_jnt_state_msg = receive(joint_state_sub,1);

pick_traj_act_client = rosactionclient('/pos_joint_traj_controller/follow_joint_trajectory',...
                                           'control_msgs/FollowJointTrajectory', ...
                                           'DataFormat', 'struct');
    
% Create action goal message from client
traj_goal = rosmessage(pick_traj_act_client);

% "ready" configuration
q = [0 0 pi/2 -pi/2 0 0];

traj_goal = convert2ROSPointVec(q,ros_cur_jnt_state_msg.Name,1,1,traj_goal);
    
% Finally send ros trajectory with traj_steps
if waitForServer(pick_traj_act_client)
    disp('Connected to action server. Sending goal...')
    [resultMsg,state,status] = sendGoalAndWait(pick_traj_act_client,traj_goal);
else
    resultMsg = -1; state = 'failed'; status = 'could not find server';
end