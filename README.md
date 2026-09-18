# TP1 : identification d'un système mécanique linéaire

NOVIKOV, VINET · Polytech Sorbonne ROB4 · Septembre 2026

## Fichiers

Comme dans le sujet, le fichier `questionN.m` correspond à la partie N+1.

| Fichier | Rôle |
|---|---|
| `definit_parametres.m` | Paramètres réels du système |
| `simule_systeme.m` | Fonctions de transfert $G_1, G_2, G_3$ et simulation de la réponse à un échelon (positions, vitesses, accélérations) |
| `identifie_parametres.m` | Construction de $A$ et identification par moindres carrés |
| `stats.m` | Tableau paramètres réels / estimés / erreurs |
| `question1.m` | Partie 2 : identification sans quantification |
| `question2.m` | Partie 3 : effet de la quantification |
| `question3.m` | Partie 4 : augmentation de $k_1$ et $b_1$ |
| `question4.m` | Partie 5 : filtrage |
| `question5.m` | Partie 6 : étude complémentaire (modèle réduit) |

Il faut Matlab avec la Control System Toolbox (`tf`, `step`, `minreal`) et la Signal Processing Toolbox (`filtfilt`, pour `question4.m`). On lance `question1` à `question5` depuis le dossier.

## 1. Préparation

Avec $\mathbf{x} = (k_0,\ k_1,\ k_2,\ b_0,\ b_1,\ b_2,\ m_1,\ m_2,\ m_3)^T$, les équations (1) donnent pour chaque instant $i$ :

```math
A_i =
\begin{pmatrix}
\alpha_i & \alpha_i-\beta_i & 0 & \dot\alpha_i & \dot\alpha_i-\dot\beta_i & 0 & \ddot\alpha_i & 0 & 0
\\ 0 & \alpha_i-\beta_i & \gamma_i-\beta_i & 0 & \dot\alpha_i-\dot\beta_i & \dot\gamma_i-\dot\beta_i & 0 & -\ddot\beta_i & 0
\\ 0 & 0 & \beta_i-\gamma_i & 0 & 0 & \dot\beta_i-\dot\gamma_i & 0 & 0 & -\ddot\gamma_i
\end{pmatrix}
\qquad
b_i = \begin{pmatrix} f_i \\ 0 \\ 0 \end{pmatrix}
```

```math
\hat{\mathbf{x}} = (A^T A)^{-1} A^T \mathbf{b}
```

(`A\b` sous Matlab). 9 inconnues et 3 équations par instant : en préparation on avait trouvé $N_{\min} = \lceil 9/3 \rceil = 3$ instants (corrigé dans la partie 2).

En Laplace (CI nulles) le système s'écrit

```math
\begin{pmatrix} F_1 & F_2 & 0\\ F_2 & F_4 & F_6 \\ 0 & F_6 & F_7\end{pmatrix}\begin{pmatrix}\alpha\\ \beta\\ \gamma\end{pmatrix} = \begin{pmatrix} f\\ 0\\ 0\end{pmatrix}
```

avec $F_1 = m_1s^2+(b_0+b_1)s+k_0+k_1$, $F_2 = -(b_1s+k_1)$, $F_4 = m_2s^2+(b_1+b_2)s+k_1+k_2$, $F_6 = -(b_2s+k_2)$, $F_7 = m_3s^2+b_2s+k_2$ (dans le code $F_3=F_2$ et $F_5=F_6$). Par substitution :

```math
G_1 = \frac{1}{F_1 - \dfrac{F_2^2}{F_4 - F_6^2/F_7}} \qquad
G_2 = \frac{-F_2}{F_4 - F_6^2/F_7}\,G_1 \qquad
G_3 = -\frac{F_6}{F_7}\,G_2
```

## 2. Identification sans quantification (`question1.m`)

Avec les 801 instants ($A$ : $2403\times9$, cond(A) ≈ 3,2·10²) on retrouve tous les paramètres (erreurs < 0,01 %).

Avec 3 instants $A$ est toujours singulière (`rank(A) = 8`) : l'équation 3 a un second membre nul et ne porte que sur $(k_2, b_2, m_3)$, le vrai vecteur est dans le noyau de ses 3 lignes qui sont donc de rang $\le 2$. En pratique $n_{\min} = 4$ (avec $t$ = 0,1 ; 0,3 ; 0,6 ; 1 s on retrouve tout).

Les points ne sont pas arbitraires : $t=0$ ne donne que $\ddot\alpha$, en régime permanent ($t>4$ s) les lignes deviennent quasi colinéaires, et des points trop proches (0,01 à 0,04 s) donnent $\mathrm{cond}(A)\approx 7\cdot10^5$. Il faut des points espacés dans le transitoire. Au-delà de $n_{\min}$, les moindres carrés moyennent les erreurs de mesure.

## 3. Effet de la quantification (`question2.m`)

Pas de 10 µm, 0,1 mm/s et 1 mm/s² (au début on avait mis 1 mm/s pour les vitesses, corrigé). Avec les 4 points de la partie 2 l'erreur sur $m_1$ atteint 13 %, avec tous les points elle est ≤ 2,2 % partout. Au-delà d'une vingtaine de points l'erreur ne baisse plus vraiment : le bruit est dans $A$ et pas seulement dans $\mathbf{b}$, donc les moindres carrés restent biaisés. Les points en régime permanent sont inutiles ($\mathrm{cond}(A)=\infty$).

## 4. Augmentation de $k_1$ et $b_1$ (`question3.m`)

Avec $k_1$ = 5000 N/m, $b_1$ = 400 Ns/m et tous les points, les erreurs vont de 10 à 49 % ($k_0$ reste à 0,3 %). Sans quantification on retrouve tout, c'est donc la résolution le problème : la liaison est plus raide, $\max\lvert\alpha-\beta\rvert$ = 37 µm (moins de 4 pas) et $\max\lvert\dot\alpha-\dot\beta\rvert$ = 1 mm/s (10 pas), les colonnes de $k_1$ et $b_1$ sont mal mesurées.

$k_2$, $b_2$ et $m_3$ ont la même erreur (≈ 49 %) : l'équation 3 est homogène et ne donne que leurs rapports, leur échelle vient de l'équation 1 en passant par $k_1$ et $b_1$ dans l'équation 2.

## 5. Filtrage (`question4.m`)

La quantification ajoute un bruit haute fréquence alors que les signaux utiles sont lents. `filtfilt` ne déphase pas et le même filtre est appliqué à toutes les mesures, donc la relation linéaire est conservée.

Pour $0<u<1$ (valeurs de l'énoncé) c'est pire (97 % d'erreur pour $u$ = 0,5) : avec `filtfilt([1 u-1], u, x)` le gain à $f_e/2$ vaut $(2-u)/u>1$. Pour $u>1$ c'est un passe-bas, le meilleur est vers $u$ = 2 à 3 (on garde $u$ = 3) : l'erreur max passe de 49 à 34 %. Le filtre lisse les marches mais ne recrée pas l'information perdue.

## 6. Étude complémentaire (`question5.m`)

Avec $k_1 = 5\cdot10^5$ N/m et $b_1 = 4\cdot10^4$ Ns/m : $\max\lvert\alpha-\beta\rvert$ = 0,37 µm (27 fois moins que le pas) et $\max\lvert\dot\alpha-\dot\beta\rvert$ = 9,8 µm/s, ces colonnes ne sont plus que du bruit. Le modèle complet donne $k_1$ = −195 N/m (négatif !) et jusqu'à 99 % d'erreur sur les autres (cond(A) ≈ 8,7·10⁴) alors que sans quantification il retrouve $k_1$. $m_1$ et $m_2$ forment un seul bloc : $k_1$, $b_1$, et $m_1$, $m_2$ séparément, ne sont pas identifiables.

On additionne les équations 1 et 2 (la force interne s'annule) avec $\ddot\alpha\approx\ddot\beta$ :

```math
f = k_0\alpha + b_0\dot\alpha + k_2(\beta-\gamma) + b_2(\dot\beta-\dot\gamma) + (m_1+m_2)\ddot\alpha
\qquad
0 = k_2(\beta-\gamma) + b_2(\dot\beta-\dot\gamma) - m_3\ddot\gamma
```

avec $\mathbf{x} = (k_0,\ k_2,\ b_0,\ b_2,\ m_1+m_2,\ m_3)^T$. On enlève $t=0$ ($\ddot\alpha=1$ et $\ddot\beta=0$ : $m_1$ accélère seule pendant ≈ 12 µs, sinon 33 % d'erreur sur $m_1+m_2$) et on ne filtre pas (le filtre étale ce pic). Résultat : $\mathrm{cond}(A)$ = 58 et toutes les erreurs < 0,3 %.

| Paramètre | Réel | Estimé | Erreur |
|---|---|---|---|
| $k_0$ | 300 | 300,00 | 0,001 % |
| $k_2$ | 50 | 50,14 | 0,28 % |
| $b_0$ | 30 | 29,97 | 0,09 % |
| $b_2$ | 8 | 7,999 | 0,01 % |
| $m_1+m_2$ | 2 | 2,001 | 0,07 % |
| $m_3$ | 4 | 4,008 | 0,21 % |

## Conclusion

Avoir assez de mesures ne suffit pas, il faut des points qui excitent le système. Les moindres carrés moyennent le bruit, mais un paramètre dont l'effet est plus petit que la résolution des capteurs n'est pas identifiable : il faut réduire le modèle.

## Utilisation de l'IA

La préparation (calculs à la main) a été faite par nous. Nous avons utilisé une IA (Claude, Anthropic) pour comprendre les questions sur lesquelles on bloquait. Pour le code, elle a surtout écrit la partie 6 (`question5.m`, relu et exécuté par nous). Le code des parties 2 à 5 (`question1.m` à `question4.m`) est principalement de nous, avec quelques aides ponctuelles, dont la correction de notre pas de quantification des vitesses. Elle nous a aussi aidés à interpréter certains résultats ($n_{\min}$ en pratique, erreur commune de $k_2$, $b_2$, $m_3$) et à rédiger ce compte-rendu. Les résultats ont été vérifiés en relançant nos scripts sous Matlab.
