% HW 8 --> guessing position of each joint to get to rcan3
% check example 3 in 09 live notebook & function packTrajGoal

% connecting gazebo & matlab
rosinit('192.168.152.129')

trajAct = rosactionclient('/pos_joint_traj_controller/follow_joint_trajectory','control_msgs/FollowJointTrajectory') 
trajGoal = rosmessage(trajAct)

