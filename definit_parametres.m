% TODO

k_0 = 300;
k_1 = 100;
k_2 = 50;
b_0 = 30;
b_1 = 40;
b_2 = 8;
m_1 = 1;
m_2 = 1;
m_3 = 4;

s = tf('s');

F1 = (m_1 * s^2 +k_0 + k_1 + b_1 * s + b_0 * s)
F2 = k_1 + b_1 * s
F3 = F2;
F4 = k_1 + b_1 * s + k_2 + b_2 * s + m_2 * s^2
F5 = b_2 * s + k_2
F6 = -(b_2*s + k_2)
F7 = m_3*s^2 + b_2*s + k_2

G1 = 1 / (F1 - (F2 * F3)/(F4 - F5*F6 / F7))
G2 = -F3 * G1 / (F4 - F5 * F6 / F7)
G3 = -F6 / F7 * G2

step(G1)
step(G2)
step(G3)

step(G1*s)
step(G2*s)
step(G3*s)