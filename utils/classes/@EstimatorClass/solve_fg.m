
function solve_fg(obj, counters, params)


% total number of states to estimate
obj.m_M= (params.M + 1) * params.m;

% total number of measurements
obj.n_total= length(obj.z_fg);

% check that there are enough epochs
if counters.k_lidar <= params.M, return, end




% create optimization function 
fun= @(x) obj.optimization_fn_fg(x, params);

% initial estimate for the time window
x_star= cell2mat(obj.x_ph');
x_star= [ x_star; obj.XX ];

%%%%%%%%%%%%%%%
% obj.optimization_fn_fg(x_star, params)



% solve the problem
x_star= fminunc(fun, x_star);




% from a vector to cells
inds= 1:params.m;
for i= params.M:-1:1
    % update the cell
    obj.x_ph{i}= x_star(inds);
    
    % update index
    inds= inds + params.m;
end
% current pose
obj.XX= x_star(end - params.m + 1:end);


end



