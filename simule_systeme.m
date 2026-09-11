% Simulation de la reponse du systeme a un echelon unitaire de force

definit_parametres;   % charge m1,m2,m3,b0,b1,b2,k0,k1,k2

%% Vecteur des instants de mesure
Te = 0.01;                % pas d'echantillonnage : 10 ms
t  = (0:Te:8)';            % de 0 a 8 s

%% Variable de Laplace
s = tf('s');

%% Termes intermediaires
% F1 = m1*s^2 + k0 + k1 + b1*s + b0*s;
% F2 = k1 + b1*s;
% F3 = F2;
% F4 = k1 + b1*s + k2 + b2*s + m2*s^2;
% F5 = -(b2*s + k2);
% F6 = -(b2*s + k2);
% F7 = m3*s^2 + b2*s + k2;
F1 = (m_1 * s^2 +k_0 + k_1 + b_1 * s + b_0 * s)
F2 = k_1 + b_1 * s
F3 = F2;
F4 = k_1 + b_1 * s + k_2 + b_2 * s + m_2 * s^2
F5 = b_2 * s + k_2
F6 = -(b_2*s + k_2)
F7 = m_3*s^2 + b_2*s + k_2

%% Fonctions de transfert G1(s), G2(s), G3(s)
G1 = 1 / (F1 - (F2*F3)/(F4 - F5*F6/F7));
G2 = (-F3/(F4 - (F5*F6/F7))) * G1;
G3 = -(F6/F7) * G2;

G1 = minreal(G1);
G2 = minreal(G2);
G3 = minreal(G3);

%% Positions : reponse indicielle directe de G1, G2, G3
[alpha, t] = step(G1, t);
beta       = step(G2, t);
gamma      = step(G3, t);

%% Vitesses : reponse indicielle de s*G1, s*G2, s*G3
vit_alpha = step(minreal(s*G1), t);
vit_beta  = step(minreal(s*G2), t);
vit_gamma = step(minreal(s*G3), t);

%% Accelerations : reponse indicielle de s^2*G1, s^2*G2, s^2*G3
acc_alpha = step(minreal(s^2*G1), t);
acc_beta  = step(minreal(s^2*G2), t);
acc_gamma = step(minreal(s^2*G3), t);

%% Force appliquee (echelon unitaire)
f = ones(size(t));

%% Affichage
figure;
subplot(3,1,1);
plot(t,alpha,'b', t,beta,'r', t,gamma,'g','LineWidth',1.2);
xlabel('temps (s)'); ylabel('position (m)');
legend('\alpha','\beta','\gamma');
title('Positions');
grid on;

subplot(3,1,2);
plot(t,vit_alpha,'b', t,vit_beta,'r', t,vit_gamma,'g','LineWidth',1.2);
xlabel('temps (s)'); ylabel('vitesse (m/s)');
legend('d\alpha/dt','d\beta/dt','d\gamma/dt');
title('Vitesses');
grid on;

subplot(3,1,3);
plot(t,acc_alpha,'b', t,acc_beta,'r', t,acc_gamma,'g','LineWidth',1.2);
xlabel('temps (s)'); ylabel('acceleration (m/s^2)');
legend('d^2\alpha/dt^2','d^2\beta/dt^2','d^2\gamma/dt^2');
title('Accelerations');
grid on;

figure;
plot(t,f,'k','LineWidth',1.2);
xlabel('temps (s)'); ylabel('force (N)');
title('Force appliquee f(t)');
grid on;