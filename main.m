% 自动探索最适合的UKF参数（自动调参）
%% initial parameter
Q0 = 0.001*diag([1,1,1]);%过程噪声方差
P0 = diag([0.04,0.04,0.25]);
R0 = 1e-5*diag([1,1,1]);
F = diag([1,1,1]); % nx*nx_aug

%% get err initial
ekf_weather;
err0 = ; %根据实际情况
fprintf('Q：%f，R：%f,mean_err(initial)：%f\n',Q(1),R(1),err0);
step = 1.5;
%% 循环
for i1 = 1:20
    Q = step^i1*Q0;
    R = R0;
    ekf_weather;
    err = mean((windekf(1,:)'-windx).^2+(windekf(2,:)'-windy).^2+(windekf(3,:)'-windz).^2);
    fprintf('Q：%f，R：%f,mean_err：%f\n',Q(1),R(1),err);
    if err>err0
        if i1==1
            fprintf('warning：check Q0, it is too small!--Evand\n');
            break;
        else
            Q0 = Q/step;
            fprintf('find the optimal Q:%f\n',Q0(1));
            break;
        end
    else
        if i1==20
            fprintf('warning:check i1,it is too small!--EVand\n');
        else
            err0 = err;
        end
    end
end
%%%%%%%%%%
for i1 = 1:20
    Q = Q0;
    R = step^i1*R0;
    ekf_weather;
    err = mean((windekf(1,:)'-windx).^2+(windekf(2,:)'-windy).^2+(windekf(3,:)'-windz).^2);
    fprintf('Q：%f，R：%f,mean_err：%f\n',Q(1),R(1),err);
    if err>err0
        if i1==1
            fprintf('warning：check R0, it is too small!--Evand\n');
            break;
        else
            R0 = R/step;
            fprintf('find the optimal R:%f\n',R0(1));
            break;
        end
    else
        if i1==20
            fprintf('warning:check i1,it is too small!--EVand\n');
        else
            err0 = err;
        end
    end
end

%% wind twice KF
windx_dynamicukf2 = windekf(1,:)';
windy_dynamicukf2 = windekf(2,:)';
windz_dynamicukf2 = windekf(3,:)';
winddynamicukfv_horizon2 = windv_horizontal(windx_dynamicukf2,windy_dynamicukf2);
winddynamicukfd_horizon2 = windd_horizontal(windx_dynamicukf2,windy_dynamicukf2);
%% end
clear err0 err
