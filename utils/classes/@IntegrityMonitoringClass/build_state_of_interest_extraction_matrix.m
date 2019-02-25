function alpha= build_state_of_interest_extraction_matrix(obj, params, current_state)
alpha= [ zeros( obj.M * params.m, 1 );...
        -sin( current_state(params.ind_yaw) );...
         cos( current_state(params.ind_yaw) );...
         0 ];
end