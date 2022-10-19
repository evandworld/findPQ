% 自动探索最适合的UKF参数（自动调参）
%% initial parameter
Q0 = 0.001*diag([1,1,1]);%过程噪声方差
P0 = diag([0.04,0.04,0.25]);
R0 = 1e-5*diag([1,1,1]);
F = diag([1,1,1]); % nx*nx_aug

%% get err initial
ekf_weather;
err0 = ; %根据实际情况写误差的表达式
fprintf('Q：%f，R：%f,mean_err(initial)：%f\n',Q(1),R(1),err0);
step = 1.5; %步长，>1即可，可改
%% 循环
for i1 = 1:20 %Q调优的总循环次数
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
for i1 = 1:20 %R调优的总循环次数
    Q = Q0;
    R = step^i1*R0;
    ekf_weather;
    err = ; %根据实际情况写误差的表达式
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
%% end
clear err0 err
