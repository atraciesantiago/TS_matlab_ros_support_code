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
gripperX = -0.03;
gripperY = 0.80;
% maintain initial height
gripperZ1 = 0.34;
% lower height to rCan3
gripperZ2 = 0.15;

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
sendGoal(trajAct,trajGoal)

% closing gripper around can
grip_client = rosactionclient('/gripper_controller/follow_joint_trajectory','control_msgs/FollowJointTrajectory', 'DataFormat', 'struct');
gripGoal = rosmessage(grip_client);
gripPos = 0.8;
gripGoal = packGripGoal(gripPos,gripGoal);

sendGoal(grip_client,gripGoal)

% pick up can
gripperX_1 = -0.03;
gripperY_1 = 0.80;
gripperZ_1 = 0.34;

gripperTranslation_1 = [gripperX_1 gripperY_1 gripperZ_1];
gripperRotation_1 = [-pi/2 -pi 0]; %  [Z Y X]radians


tform = eul2tform(gripperRotation_1); % ie eul2tr call
tform(1:3,4) = gripperTranslation_1'; % set translation in homogeneous transform

% Finally, compute the IKs:
[configSoln, solnInfo] = ik('tool0',tform,ikWeights,initialIKGuess);

UR5econfig = [configSoln(3)... 
              configSoln(2)...
              configSoln(1)...
              configSoln(4)...
              configSoln(5)...
              configSoln(6)];

% Let's use a packing function to appropriately fill names and positions:
trajGoal = packTrajGoal(UR5econfig,trajGoal);

% Send to the action server:
sendGoal(trajAct,trajGoal)