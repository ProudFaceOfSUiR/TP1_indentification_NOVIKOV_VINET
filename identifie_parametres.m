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