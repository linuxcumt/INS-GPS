
function A= return_A_fg(obj, x, params)
% this function retuns the A jacobian for the optimization problem

% from a vector to cells
inds= 1:params.m;
for i= params.M:-1:1
    % update the cell
    obj.x_ph{i}= x(inds);
    
    % update index
    ind= ind + params.m;
end
% current pose
obj.XX= x(end - params.m + 1:end);



% initialize normalized Jacobian
A= zeros( obj.n_total, obj.m_M );

% plug the prior in A
A( 1:params.m, 1:params.m )= sqrtm( inv(obj.PX_prior) );

% pointers to the next part of A to be filled
r_ind= params.m + 1;
c_ind= 1;

% build A whithen Jacobian
for i= obj.M : -1 : 2
    
    % ---------- gyro submatrix ----------
    obj.A( r_ind, c_ind : c_ind + params.m - 1 )= ...
        params.sig_gyro_z^(-1) * [0,0,1/params.dt_sim];
    
    obj.A( r_ind, c_ind + params.m : c_ind + 2*params.m - 1 )= ...
        -params.sig_gyro_z^(-1) * [0,0,1/params.dt_sim];
    % ------------------------------------
    
    % update the row index to point towards the next msmt
    r_ind= r_ind + 1;
    
    % ---------- odometry submatrix ----------
    [Phi, D_bar, ~, ~]= obj.compute_Phi_and_D_bar(...
        obj.x_ph{i}, obj.odometry{i}(1), obj.odometry{i}(2), params);
    
    [~,S,V]= svd( D_bar );
    r_S= rank(S);
    sqrt_inv_D_bar= sqrtm( inv(S(1:r_S,1:r_S)) ) * V(:,1:r_S)';
    
    obj.A( r_ind : r_ind + r_S - 1, c_ind : c_ind + params.m - 1 )= ...
        sqrt_inv_D_bar * Phi;
    
    obj.A( r_ind : r_ind + r_S - 1, c_ind + params.m : c_ind + 2*params.m -1)= ...
        -sqrt_inv_D_bar;
    % ------------------------------------
    
    % update the row & column indexes
    r_ind= r_ind + r_S;
    c_ind= c_ind + params.m;
    
    % ---------- lidar submatrix ----------
    A_lidar= obj.return_lidar_A(obj.x_ph{i+1}, obj.association_ph{i+1}, params);
    n_L= length(obj.association_ph{i+1});
    n= n_L * params.m_F;
    obj.A( r_ind : r_ind + n - 1, c_ind : c_ind + params.m - 1)= A_lidar;
    % ------------------------------------
    
    % update the row index
    r_ind= r_ind + n;
end

% ---------- gyro submatrix ----------
obj.A( r_ind, c_ind : c_ind + params.m - 1 )= ...
    params.sig_gyro_z^(-1) * [0,0,1/params.dt_sim];

obj.A( r_ind, c_ind + params.m : c_ind + 2*params.m - 1 )= ...
    -params.sig_gyro_z^(-1) * [0,0,1/params.dt_sim];
% ------------------------------------

% update the row index to point towards the next msmt
r_ind= r_ind + 1;

% ---------- odometry submatrix ----------
[Phi, D_bar, ~, ~]= obj.compute_Phi_and_D_bar(...
    obj.x_ph{1}, obj.odometry{1}(1), obj.odometry{1}(2), params);

[~,S,V]= svd( D_bar );
r_S= rank(S);
sqrt_inv_D_bar= sqrtm( inv(S(1:r_S,1:r_S)) ) * V(:,1:r_S)';

obj.A( r_ind : r_ind + r_S - 1, c_ind : c_ind + params.m - 1 )= ...
    sqrt_inv_D_bar * Phi;

obj.A( r_ind : r_ind + r_S - 1, c_ind + params.m : c_ind + 2*params.m -1)= ...
    -sqrt_inv_D_bar;
% ------------------------------------

% update the row & column indexes
r_ind= r_ind + r_S;
c_ind= c_ind + params.m;

% ---------- lidar submatrix ----------
A_lidar= obj.return_lidar_A(obj.XX, obj.association, params);
n_L= length(obj.association);
n= n_L * params.m_F;
obj.A( r_ind : r_ind + n - 1, c_ind : c_ind + params.m - 1)= A_lidar;
% ------------------------------------

end







