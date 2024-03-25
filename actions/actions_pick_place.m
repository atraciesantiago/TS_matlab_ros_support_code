% Pick and place

% 01 Connect to ROS (use your own masterhost IP address)
% rosinit("192.168.122.128")

% 02 Extract a list of models via a ga
models = getModels; 

% Loop through each one to pick and place
for i=1:length(models.ModelNames)

    %% 03 Get Gazebo model pose (note wrt to a world not in the base of the
    % arm)
    model_name = models.ModelNames{26};         % 'rCan3'
    %model_name = models.ModelNames{i}
    model_pose = get_model_pose(model_name);
    
    %% 04 Go Home
    % goHome % moves robot arm to a good starting configuration
   

    %% 05 Pick Model
    ret = pick(model_pose);
    
    %% 06 Logic to set bin according to object
    placePose = selectBin(model_name); 
    ret = place(placePose);
end