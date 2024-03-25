% HW 8 Part C --> close gripper around can




grip_client = rosactionclient('/gripper_controller/follow_joint_trajectory','control_msgs/FollowJointTrajectory', 'DataFormat', 'struct')
gripGoal    = rosmessage(grip_client);
gripPos     = 0;
gripGoal    = packGripGoal(gripPos,gripGoal)
sendGoal(grip_client,gripGoal)