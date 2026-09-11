% %% Indices des instants de mesure choisis pour l'identification
% %index = [5, 10, 15];   % tu peux en mettre autant que tu veux, dans n'importe quel ordre
% 
% <<<<<<< HEAD
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
    alpha_ = alpha(idx);
    beta_ = beta(idx);
    gamma_ = gamma(idx);
    alpha_dot = vit_alpha(idx);
    beta_dot = vit_beta(idx);
    gamma_dot = vit_gamma(idx);
    alpha_ddot = acc_alpha(idx);
    beta_ddot = acc_beta(idx);
    gamma_ddot = acc_gamma(idx);

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
% =======
% idx_min = find(t >= 0.01, 1);                  % indice correspondant a t=0.1s
% idx_max = find(t >= 0.5, 1);                  % indice correspondant a t=0.7s
% index   = round(linspace(idx_min, idx_max, 100));   % 100 points repartis entre 0.1s et 0.7s
% 
% A = [];
% b = [];
% 
% for j = 1:length(index)
%     i = index(j);
% 
%     alpha_ = alpha(i);
%     beta_  = beta(i);
%     gamma_ = gamma(i);
% 
%     alpha_dot = vit_alpha(i);
%     beta_dot  = vit_beta(i);
%     gamma_dot = vit_gamma(i);
% 
%     alpha_ddot = acc_alpha(i);
%     beta_ddot  = acc_beta(i);
%     gamma_ddot = acc_gamma(i);
% 
%     A_i = [
%         alpha_, alpha_-beta_,  0,             alpha_dot, alpha_dot-beta_dot, 0,                   alpha_ddot, 0,          0;
%         0,      alpha_-beta_,  gamma_-beta_,  0,         alpha_dot-beta_dot, gamma_dot-beta_dot,  0,          -beta_ddot, 0;
%         0,      0,             beta_-gamma_,  0,         0,                  beta_dot-gamma_dot,   0,          0,          -gamma_ddot
%     ];
% 
%     b_i = [f(i); 0; 0];
% 
%     A = [A; A_i];   % concatenation verticale
%     b = [b; b_i];
% end
% 
% 
% x_hat = A \ b;
% 
% %% Diagnostic de la matrice A
% fprintf('Taille de A         : %d x %d\n', size(A,1), size(A,2));
% fprintf('Conditionnement de A : %.2e\n\n', cond(A));
% 
% %% Comparaison predictions vs realite
% x_real = [k0, k1, k2, b0, b1, b2, m1, m2, m3]';   % transposee en vecteur colonne (comme x_hat)
% 
% erreur_abs = x_hat - x_real;                       % erreur absolue, parametre par parametre
% erreur_rel = abs(erreur_abs) ./ abs(x_real) * 100;  % erreur relative en %
% 
% norme_abs = norm(erreur_abs);                       % norme globale de l'erreur absolue
% norme_rel = norm(erreur_abs) / norm(x_real) * 100;   % norme relative globale (%)
% 
% %% Affichage sous forme de tableau
% noms = {'k0';'k1';'k2';'b0';'b1';'b2';'m1';'m2';'m3'};
% T = table(noms, x_real, x_hat, erreur_abs, erreur_rel, ...
%     'VariableNames', {'Parametre','Valeur_reelle','Valeur_estimee','Erreur_abs','Erreur_rel_pct'})
% 
% fprintf('\nNorme de l''erreur absolue  : %.4f\n', norme_abs);
% fprintf('Norme de l''erreur relative : %.2f %%\n', norme_rel);
% >>>>>>> 63ac3464d741b3222e1e76bd934f65ccef79dc5a
