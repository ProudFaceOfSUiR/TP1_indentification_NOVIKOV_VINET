definit_parametres;
simule_systeme;

alpha_ = 0;
beta_ = 0;
gamma_ = 0;
alpha_dot = 0;
beta_dot = 0;
gamma_dot = 0;
alpha_ddot = 0;
beta_ddot = 0;
gamma_ddot = 0;

A = [
    alpha_, -beta_ + gamma_, 0, alpha_dot, alpha_dot - beta_dot, 0, alpha_ddot, 0, 0;
    0, alpha_ - beta_, gamma_ - beta_, 0, alpha_dot - beta_dot, 0, -beta_ddot, 0, 0;
    0, 0, beta_ - gamma_, 0, 0, beta_dot - gamma_dot, 0, 0, -gamma_ddot
]

y = []
% indexes = [1:];

idx_all = 1:length(alpha);
% % e.g. require meaningful motion, not just any index
% eps_v = 0.001
% mask = abs(vit_alpha) > eps_v | abs(vit_beta) > eps_v | abs(vit_gamma) > eps_v;
% indexes = idx_all(mask);
% 
% indexes = [1:400];
indexes = idx_all;
N = length(indexes);

A_hat = [];
y_hat = [];

for i = 1:N
    idx = indexes(i);

    % Extract values for the current index
    alpha_ = 0.00001*round(alpha(idx)*100000) ;
    beta_ = 0.00001*round(beta(idx)*100000) ;
    gamma_ = 0.00001*round(gamma(idx)*100000) ;
    alpha_dot =0.001*round(vit_alpha(idx)*1000) ;
    beta_dot = 0.001*round(vit_beta(idx)*1000) ;
    gamma_dot = 0.001*round(vit_gamma(idx)*1000) ;
    alpha_ddot = 0.001*round(acc_alpha(idx)*1000) ;
    beta_ddot = 0.001*round(acc_beta(idx)*1000) ;
    gamma_ddot = 0.001*round(acc_gamma(idx)*1000) ;

    % Construct the A matrix for the current index
    A = [
        alpha_, -beta_ + alpha_, 0, alpha_dot, alpha_dot - beta_dot, 0, alpha_ddot, 0, 0;
        0, alpha_ - beta_, gamma_ - beta_, 0, alpha_dot - beta_dot, gamma_dot-beta_dot, 0, -beta_ddot, 0;
        0, 0, beta_ - gamma_, 0, 0, beta_dot - gamma_dot, 0, 0, -gamma_ddot
    ];

    A_hat = [A_hat; A];
    y_hat = [y_hat, [1, 0, 0]];
end
cond(A_hat)
y_hat = y_hat';
theta_hat = A_hat\y_hat