definit_parametres
k_1 = 500000;
b_1 = 40000;
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

idx_all = 1:length(alpha);
indexes = idx_all;
N = length(indexes);

A_hat = [];
y_hat = [];

alpha_bruit = zeros(1, N);
beta_bruit = zeros(1, N);
gamma_bruit = zeros(1, N);
alpha_dot_bruit = zeros(1, N);
beta_dot_bruit = zeros(1, N);
gamma_dot_bruit = zeros(1, N);
alpha_ddot_bruit = zeros(1, N);
beta_ddot_bruit = zeros(1, N);
gamma_ddot_bruit = zeros(1, N);

for i = 1:N
    idx = indexes(i);

    % Extract and round values for the current index
    alpha_bruit(i) = 0.00001 * round(alpha(idx) * 100000);
    beta_bruit(i) = 0.00001 * round(beta(idx) * 100000);
    gamma_bruit(i) = 0.00001 * round(gamma(idx) * 100000);

    alpha_dot_bruit(i) = 0.0001 * round(vit_alpha(idx) * 10000);
    beta_dot_bruit(i) = 0.0001 * round(vit_beta(idx) * 10000);
    gamma_dot_bruit(i) = 0.0001 * round(vit_gamma(idx) * 10000);

    alpha_ddot_bruit(i) = 0.001 * round(acc_alpha(idx) * 1000);
    beta_ddot_bruit(i) = 0.001 * round(acc_beta(idx) * 1000);
    gamma_ddot_bruit(i) = 0.001 * round(acc_gamma(idx) * 1000);
end

% Mouvement relatif entre m1 et m2 : reel vs mesure
figure;
subplot(2,1,1);
plot(t, alpha - beta, 'b', t, alpha_bruit - beta_bruit, 'r', 'LineWidth', 1.2);
xlabel('temps (s)'); ylabel('\alpha - \beta (m)');
legend('reel', 'quantifie');
title('Ecart de position entre m1 et m2');
grid on;

subplot(2,1,2);
plot(t, vit_alpha - vit_beta, 'b', t, alpha_dot_bruit - beta_dot_bruit, 'r', 'LineWidth', 1.2);
xlabel('temps (s)'); ylabel('d\alpha/dt - d\beta/dt (m/s)');
legend('reel', 'quantifie');
title('Ecart de vitesse entre m1 et m2');
grid on;

%% 1) Modele complet (9 parametres) : l'identification echoue

for i = 1:N
    idx = indexes(i);

    % Extract values for the current index
    alpha_ = alpha_bruit(idx);
    beta_ = beta_bruit(idx);
    gamma_ = gamma_bruit(idx);

    alpha_dot = alpha_dot_bruit(idx);
    beta_dot = beta_dot_bruit(idx);
    gamma_dot = gamma_dot_bruit(idx);

    alpha_ddot = alpha_ddot_bruit(idx);
    beta_ddot = beta_ddot_bruit(idx);
    gamma_ddot = gamma_ddot_bruit(idx);

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

stats;


%% 2) Modele reduit : m1 et m2 rigidement lies, x = [k0, k2, b0, b2, m1+m2, m3]
% equation 1 + equation 2 : f = k0*alpha + b0*alpha_dot + k2*(beta-gamma) + b2*(beta_dot-gamma_dot) + (m1+m2)*alpha_ddot
% equation 3              : 0 = k2*(beta-gamma) + b2*(beta_dot-gamma_dot) - m3*gamma_ddot

indexes = idx_all(2:end);   % t = 0 exclu : m1 accelere seule pendant quelques microsecondes
N = length(indexes);

A_hat = [];
y_hat = [];

for i = 1:N
    idx = indexes(i);

    % Extract values for the current index
    alpha_ = alpha_bruit(idx);
    beta_ = beta_bruit(idx);
    gamma_ = gamma_bruit(idx);

    alpha_dot = alpha_dot_bruit(idx);
    beta_dot = beta_dot_bruit(idx);
    gamma_dot = gamma_dot_bruit(idx);

    alpha_ddot = alpha_ddot_bruit(idx);
    beta_ddot = beta_ddot_bruit(idx);
    gamma_ddot = gamma_ddot_bruit(idx);

    % Construct the reduced A matrix for the current index
    A = [
        alpha_, beta_ - gamma_, alpha_dot, beta_dot - gamma_dot, alpha_ddot, 0;
        0, beta_ - gamma_, 0, beta_dot - gamma_dot, 0, -gamma_ddot
    ];

    A_hat = [A_hat; A];
    y_hat = [y_hat, [1, 0]];
end
cond(A_hat)
y_hat = y_hat';
theta_hat = A_hat\y_hat

fprintf('Taille de A         : %d x %d\n', size(A_hat,1), size(A_hat,2));
fprintf('Conditionnement de A : %.2e\n\n', cond(A_hat));

%% Comparaison predictions vs realite
x_real = [k_0, k_2, b_0, b_2, m_1 + m_2, m_3]';

erreur_abs = theta_hat - x_real;                       % erreur absolue, parametre par parametre
erreur_rel = abs(erreur_abs) ./ abs(x_real) * 100;  % erreur relative en %

norme_abs = norm(erreur_abs);                       % norme globale de l'erreur absolue
norme_rel = norm(erreur_abs) / norm(x_real) * 100;   % norme relative globale (%)

%% Affichage sous forme de tableau
noms = {'k0';'k2';'b0';'b2';'m1+m2';'m3'};
T = table(noms, x_real, theta_hat, erreur_abs, erreur_rel, ...
    'VariableNames', {'Parametre','Valeur_reelle','Valeur_estimee','Erreur_abs','Erreur_rel_pct'})

fprintf('\nNorme de l''erreur absolue  : %.4f\n', norme_abs);
fprintf('Norme de l''erreur relative : %.2f %%\n', norme_rel);
