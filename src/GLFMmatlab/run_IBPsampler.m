function hidden = run_IBPsampler(data,varargin)
    % Wrapper .m function to call .cpp functions and make call simpler
    %
    %   Inputs:
    %       data: structure with all input data information
    %           (*) data.X: N*D observation matrix (raw)
    %           (*) data.C: 1*D string array with input data types
    %
    %       ------------- optional ---------------------
    %
    %       hidden: hidden structure to initialize inference algorithm
    %             hidden.Z: feature assignment N*K matrix
    %       params: structure with sim. parameters and hyperparameters
    
    switch length(varargin)
        case 0
            % initialize Z
            hidden.Z = double(rand(N,2)>0.8);
            % default values for params
            params = init_default_params(data, []);
            
        case 1, hidden = varargin{1};
            params = init_default_params(data, []);
            
        case 2, hidden = varargin{1}; params = varargin{2};
            params = init_default_params(data, params); % eventually complete params structure
            
        otherwise
            error('Incorrect number of input parameters: should be 1, 2 or 3');
    end
    
    % replace missings + preprocess
    data.X(isnan(data.X)) = params.missing;
    
    %[Xnorm,suffStats] = preprocess(X,C,missings)
    [Xmiss, suffStats] = preprocess(data.X, data.C, params.missing);
    
    % call .cpp wrapper function
    [Z B Theta]= IBPsampler(Xmiss,data.C, hidden.Z, params.bias, params.s2Y, ...
        params.s2u, params.s2B, params.alpha, params.Niter, params.maxK, params. missing);
    
    hidden.Z = Z'; % it returns a K*N matrix, should be inverted
    hidden.B = B;
    hidden.Theta = Theta;
    hidden.suffStats = suffStats; % mapping functions info (necessary for plotting)
    
end