fprintf('Taille de A         : %d x %d\n', size(A_hat,1), size(A_hat,2));
fprintf('Conditionnement de A : %.2e\n\n', cond(A_hat));

%% Comparaison predictions vs realite
x_real = [k_0, k_1, k_2, b_0, b_1, b_2, m_1, m_2, m_3]';   % transposee en vecteur colonne (comme x_hat)

erreur_abs = theta_hat - x_real;                       % erreur absolue, parametre par parametre
erreur_rel = abs(erreur_abs) ./ abs(x_real) * 100;  % erreur relative en %

norme_abs = norm(erreur_abs);                       % norme globale de l'erreur absolue
norme_rel = norm(erreur_abs) / norm(x_real) * 100;   % norme relative globale (%)

%% Affichage sous forme de tableau
noms = {'k0';'k1';'k2';'b0';'b1';'b2';'m1';'m2';'m3'};
T = table(noms, x_real, theta_hat, erreur_abs, erreur_rel, ...
    'VariableNames', {'Parametre','Valeur_reelle','Valeur_estimee','Erreur_abs','Erreur_rel_pct'})

fprintf('\nNorme de l''erreur absolue  : %.4f\n', norme_abs);
fprintf('Norme de l''erreur relative : %.2f %%\n', norme_rel);