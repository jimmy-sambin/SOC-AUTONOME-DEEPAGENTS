% ============================================================
% generer_graphiques.m - PROJET SOC AUTONOME (DeepAgents)
% Genere les graphiques du depot GitHub a partir des resultats
% de tests reels (11/11 familles reussies + 2 scenarios SOC).
% Execution (Windows, batch) :
%   matlab -softwareopengl -nosplash -batch "run('...generer_graphiques.m')"
% Sorties : graphiques/*.png (resolution 150 dpi)
% ============================================================
try
    close all; clc;
    outDir = fullfile(pwd, 'graphiques');
    if ~exist(outDir, 'dir'); mkdir(outDir); end

    %% ------------------------------------------------------------------
    %  GRAPHIQUE 1 : Durees des 15 tests du projet (tous REUSSIS)
    %  ------------------------------------------------------------------
    tests = { ...
        'Installation uv + 243 paquets',        20.0; ...
        'Imports + reseau',                      2.0; ...
        'Hugging Face DistilBERT',               2.5; ...
        'Clustering 1000 CVE',                   4.7; ...
        'Agent ReAct + HIBP',                    2.2; ...
        'SOC autonome - phishing/C2',            5.1; ...
        'Agent nmap',                            2.0; ...
        'RAG agentique',                         1.3; ...
        'MCP cyber (nmap + CISA)',               6.5; ...
        'Shodan MCP + agent',                    5.0; ...
        'CrewAI vulnerabilites',                 1.5; ...
        'Agent CISA KEV (LangGraph)',            3.9; ...
        'Hacking ethique (LangGraph)',           1.1; ...
        'ASM (LangGraph)',                       1.7; ...
        'SOC autonome - ransomware',             4.7};
    noms  = tests(:,1);
    durees = cell2mat(tests(:,2));
    [dureesTri, idx] = sort(durees, 'ascend');
    nomsTri = noms(idx);

    fig = figure('Visible','off','Color','w','Position',[50 50 1000 620]);
    barh(dureesTri, 'FaceColor', [0.20 0.47 0.66], 'EdgeColor','none');
    set(gca, 'YTick', 1:numel(nomsTri), 'YTickLabel', nomsTri, 'FontSize', 9);
    xlabel('Duree (minutes)'); grid on; box off;
    title({'15 tests du projet - tous REUSSIS', 'Environnement Windows 10 / Python 3.13 / OpenAI gpt-4o-mini & gpt-5.4-mini'});
    for k = 1:numel(dureesTri)
        text(dureesTri(k)+0.25, k, sprintf('%.1f', dureesTri(k)), 'FontSize', 8.5);
    end
    xlim([0 max(dureesTri)*1.12]);
    print(fig, fullfile(outDir,'durees_tests_projet.png'), '-dpng', '-r150');
    close(fig);

    %% ------------------------------------------------------------------
    %  GRAPHIQUE 2 : Comparaison des deux scenarios SOC
    %  ------------------------------------------------------------------
    cats = {'Alertes reelles', 'Alertes bruit', 'Actions stagees', 'Indicateurs bloques'};
    s1 = [3 2 5 0];   % phishing/C2
    s2 = [4 2 6 3];   % ransomware+exfiltration
    fig = figure('Visible','off','Color','w','Position',[50 50 950 470]);
    b = bar([s1; s2]', 1.6);
    b(1).FaceColor = [0.85 0.55 0.20]; b(1).EdgeColor='none';
    b(2).FaceColor = [0.75 0.15 0.15]; b(2).EdgeColor='none';
    set(gca, 'XTickLabel', cats, 'FontSize', 9.5); grid on; box off;
    legend({'Scenario 1 : phishing/C2 (High, confiance Moyenne-Faible)', ...
            'Scenario 2 : ransomware+exfiltration (Critical/P1, confiance Elevee)'}, ...
           'Location','northwest','FontSize',8.5);
    ylabel('Nombre'); title('Adaptation de l''agent SOC a deux incidents differents (meme architecture)');
    for g = 1:2
        for k = 1:4
            text(k + (g-1)*0.28 - 0.14, b(g).YData(k)+0.12, num2str(b(g).YData(k)), ...
                 'HorizontalAlignment','center','FontSize',9,'FontWeight','bold');
        end
    end
    ylim([0 max([s1 s2])*1.25]);
    print(fig, fullfile(outDir,'comparaison_scenarios_soc.png'), '-dpng', '-r150');
    close(fig);

    %% ------------------------------------------------------------------
    %  GRAPHIQUE 3 : Architecture du systeme (superviseur + 5 sous-agents)
    %  ------------------------------------------------------------------
    fig = figure('Visible','off','Color','w','Position',[50 50 1050 620]);
    ax = axes('Position',[0 0 1 1]); axis off; hold on;
    xlim([0 10]); ylim([0 7]);

    % Analyste humain (haut)
    drawBox(4.0, 6.1, 2.0, 0.75, [0.95 0.95 0.55], 'Analyste SOC (humain)', 10);
    % Superviseur
    drawBox(3.6, 4.9, 2.8, 0.85, [0.20 0.47 0.66], {'SOC Superviseur (DeepAgents)', 'planifie - delegue - synthetise'}, 9);
    arrow(5.0, 6.1, 5.0, 5.75);

    % 5 sous-agents (phases)
    phases = {'1. Triage', '2. Enrichissement', '3. Investigation', '4. Correlation', '5. Reponse'};
    outils = {'file alertes', 'CMDB + annuaire + threat intel', 'logs SIEM + arbre process', 'alertes liees + IOCs', 'isolate / disable / block'};
    for k = 1:5
        x = 0.35 + (k-1)*1.92;
        drawBox(x, 2.9, 1.72, 1.05, [0.85 0.91 0.96], {phases{k}}, 8.5);
        text(x+0.86, 2.62, outils{k}, 'FontSize', 6.8, 'HorizontalAlignment','center', 'Color',[0.3 0.3 0.3]);
        arrow(5.0, 4.9, x+0.86, 3.98);
    end

    % Environnement simule (bas)
    drawBox(0.35, 0.9, 5.6, 0.9, [0.92 0.92 0.92], {'Environnement SIMULE (en memoire)', 'alertes - CMDB - annuaire - threat intel - logs SIEM'}, 8.5);
    % Actions stagees -> approbation
    drawBox(6.6, 0.9, 3.0, 0.9, [0.98 0.80 0.80], {'Actions STAGEES', 'PENDING HUMAN APPROVAL'}, 9);
    arrow(7.4, 2.9, 7.4, 1.85);
    arrow(3.9, 1.35, 6.6, 1.35);

    % Boite a outils communs
    text(5.0, 0.35, 'Outils = fonctions Python documentees (moindre privilege par sous-agent) - modele : gpt-5.4-mini', ...
         'FontSize', 8, 'HorizontalAlignment','center', 'Color',[0.35 0.35 0.35]);
    title('Architecture : superviseur + 5 sous-agents phases (DeepAgents)', 'FontSize', 12);
    print(fig, fullfile(outDir,'architecture_soc.png'), '-dpng', '-r150');
    close(fig);

    %% ------------------------------------------------------------------
    %  GRAPHIQUE 4 : Timeline de la chaine d'attaque ransomware
    %  ------------------------------------------------------------------
    ev = { ...
        '02:14', 'Compromission VPN rwilliams',      'Acces initial'; ...
        '02:20', 'Creation compte pirate svc_backup2', 'Persistance'; ...
        '02:22', 'Ajout au groupe Domain Admins',     'Elevation privileges'; ...
        '02:31', 'RDP sur SRV-FIN01',                 'Mouvement lateral'; ...
        '02:38', 'vssadmin delete shadows /all',      'Anti-restauration'; ...
        '02:41', 'ransom.exe : 14 283 fichiers .locked', 'Impact'; ...
        '02:45', 'Note de rancon deposée',            'Impact'; ...
        '02:52', 'Exfiltration 2,3 Go -> megafile-upload.top', 'Exfiltration'; ...
        '02:58', 'Beacon C2 -> 45.133.1.208:443',     'Command & Control'};
    t0 = 120; % minutes depuis minuit -> base 02:00
    minutes = zeros(size(ev,1),1);
    for k = 1:size(ev,1)
        parts = sscanf(ev{k,1}, '%d:%d');
        minutes(k) = parts(1)*60 + parts(2) - t0;
    end
    tactique = ev(:,3);
    tactiqueKeys = {'Acces initial','Persistance','Elevation privileges','Mouvement lateral', ...
        'Anti-restauration','Impact','Exfiltration','Command & Control'};
    tactiqueVals = {[0.55 0.30 0.10], [0.60 0.40 0.70], [0.80 0.45 0.10], [0.10 0.55 0.45], ...
        [0.45 0.45 0.45], [0.80 0.10 0.10], [0.85 0.55 0.10], [0.50 0.10 0.55]};
    cols = containers.Map(tactiqueKeys, tactiqueVals);

    fig = figure('Visible','off','Color','w','Position',[50 50 1180 640]);
    hold on;
    % Etiquettes alternees (2 etages) pour eviter les chevauchements
    descs = {'Compromission VPN rwilliams', 'Compte pirate svc_backup2 cree', ...
             'Ajout aux Domain Admins', 'RDP sur SRV-FIN01', ...
             'vssadmin delete shadows', '14 283 fichiers chiffres .locked', ...
             'Note de rancon', 'Exfiltration 2,3 Go', 'Beacon C2'};
    for k = 1:size(ev,1)
        c = cols(tactique{k});
        scatter(minutes(k), 1, 300, c, 'filled', 'MarkerEdgeColor','k');
        et = mod(k-1, 2);  % 0 = etage haut, 1 = etage bas
        if et == 0
            text(minutes(k), 1.16, ev{k,1}, 'FontSize', 8.5, 'HorizontalAlignment','center', 'FontWeight','bold');
            text(minutes(k), 0.86, descs{k}, 'FontSize', 7.4, 'HorizontalAlignment','center');
            text(minutes(k), 0.70, tactique{k}, 'FontSize', 7.0, 'HorizontalAlignment','center', 'Color', c, 'FontWeight','bold');
            plot([minutes(k) minutes(k)], [1.03 1.12], '-', 'Color', c, 'LineWidth', 0.8);
            plot([minutes(k) minutes(k)], [0.93 0.84], '-', 'Color', c, 'LineWidth', 0.8);
        else
            text(minutes(k), 1.44, ev{k,1}, 'FontSize', 8.5, 'HorizontalAlignment','center', 'FontWeight','bold');
            text(minutes(k), 0.30, descs{k}, 'FontSize', 7.4, 'HorizontalAlignment','center');
            text(minutes(k), 0.14, tactique{k}, 'FontSize', 7.0, 'HorizontalAlignment','center', 'Color', c, 'FontWeight','bold');
            plot([minutes(k) minutes(k)], [1.03 1.40], '-', 'Color', c, 'LineWidth', 0.8);
            plot([minutes(k) minutes(k)], [0.93 0.36], '-', 'Color', c, 'LineWidth', 0.8);
        end
    end
    plot([minutes(1)-3 minutes(end)+3], [1 1], '-', 'Color', [0.7 0.7 0.7], 'LineWidth', 1.4);
    set(gca, 'XTick', minutes, 'XTickLabel', ev(:,1), 'FontSize', 8.5);
    xlim([min(minutes)-6 max(minutes)+6]); ylim([-0.05 1.60]); axis off;
    title({'Chaine d''attaque ransomware + exfiltration reconstruite par l''agent', 'Scenario 2 - SRV-FIN01 (Finance, donnees restreintes) - duree d''attaque : 44 minutes'}, 'FontSize', 11);
    print(fig, fullfile(outDir,'chaine_attaque_ransomware.png'), '-dpng', '-r150');
    close(fig);

    disp('GRAPHIQUES GENERES : durees_tests_projet, comparaison_scenarios_soc, architecture_soc, chaine_attaque_ransomware');
catch e
    disp(getReport(e, 'extended'));
    exit(1);
end

% ---------- fonction locale : boite + fleche ----------
function drawBox(x, y, w, h, color, lines, fs)
    rectangle('Position',[x y w h], 'FaceColor', color, 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 1, 'Curvature', 0.08);
    if ischar(lines); lines = {lines}; end
    n = numel(lines);
    for i = 1:n
        text(x+w/2, y+h/2 + (n+1-i)*0.14 - 0.14*h, lines{i}, ...
             'FontSize', fs, 'HorizontalAlignment','center', 'VerticalAlignment','middle', 'FontWeight','bold');
    end
end

function arrow(x1, y1, x2, y2)
    annotation('arrow', 'HeadStyle','vback2', 'HeadWidth', 8, 'HeadLength', 8, ...
        'X', [x1 x2]/10, 'Y', [y1 y2]/7, 'Color', [0.25 0.25 0.25], 'LineWidth', 1.2);
end
