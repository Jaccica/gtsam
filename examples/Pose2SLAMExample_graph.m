%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GTSAM Copyright 2010, Georgia Tech Research Corporation,
% Atlanta, Georgia 30332-0415
% All Rights Reserved
% Authors: Frank Dellaert, et al. (see THANKS for the full author list)
%
% See LICENSE for the license information
%
% @brief Read graph from file and perform GraphSLAM
% @author Frank Dellaert
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize graph, initial estimate, and odometry noise
import gtsam.*
model = noiseModel.Diagonal.Sigmas([0.05; 0.05; 5*pi/180]);
maxID = 0;
addNoise = false;
smart = true;
[graph,initial]=load2D('Data/w100-odom.graph',model,maxID,addNoise,smart);
initial.print(sprintf('Initial estimate:\n'));

%% Add a Gaussian prior on pose x_1
import gtsam.*
priorMean = Pose2(0.0, 0.0, 0.0); % prior mean is at origin
priorNoise = noiseModel.Diagonal.Sigmas([0.01; 0.01; 0.01]);
graph.addPosePrior(0, priorMean, priorNoise); % add directly to graph

%% Plot Initial Estimate
figure(1);clf
P=initial.poses;
plot(P(:,1),P(:,2),'g-*'); axis equal

%% Optimize using Levenberg-Marquardt optimization with an ordering from colamd
result = graph.optimize(initial,1);
P=result.poses;
hold on; plot(P(:,1),P(:,2),'b-*')
result.print(sprintf('\nFinal result:\n'));

%% Plot Covariance Ellipses
marginals = graph.marginals(result);
P={};
for i=1:result.size()-1
    pose_i = result.pose(i);
    P{i}=marginals.marginalCovariance(i);
    plotPose2(pose_i,'b',P{i})
end
fprintf(1,'%.5f %.5f %.5f\n',P{99})