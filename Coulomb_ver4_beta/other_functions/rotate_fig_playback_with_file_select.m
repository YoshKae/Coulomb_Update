% rotate_fig_playback_with_file_select.m
% .fig を選択 → 開く → 3D view を自動回転（録画用・出力なし）

% ====== 再生設定 ======
nFrame = 360;        % 1周あたりの回転ステップ数
fps    = 30;         % 再生FPS（録画に合わせる）
nLoop  = inf;        % 繰り返し回数（infで無限）

elMode  = "keep";    % "keep" or "sweep"
elSweep = [-10, 10]; % elMode="sweep" の場合の上下振り幅（deg）

useEscapeToStop = true;
% ======================

% ---- FIGファイル選択 ----
[file, path] = uigetfile({'*.fig','MATLAB Figure (*.fig)'}, ...
                         'Select a FIG file');
if isequal(file,0) || isequal(path,0)
    disp('Canceled.');
    return;
end

figPath = fullfile(path, file);

% ---- FIGを開く ----
hFig = openfig(figPath, "visible");
drawnow;

% ---- 3D axes を自動検出 ----
axs = findall(hFig, "Type", "axes");
if isempty(axs)
    error("No axes found in the selected FIG file.");
end

% 最も3Dっぽいaxesを選ぶ（child数＋viewで判定）
bestAx = axs(1);
bestScore = -inf;

for i = 1:numel(axs)
    ax = axs(i);
    score = numel(allchild(ax));
    v = ax.View;
    if abs(v(2) - 90) < 1e-6
        score = score - 10;  % 真上視点は2D寄り
    end
    if score > bestScore
        bestScore = score;
        bestAx = ax;
    end
end

ax = bestAx;

% ---- 描画安定化（軽量化になることあり）----
try
    % ax.SortMethod = "childorder";
    ax.SortMethod = "depth";
catch
end

% ---- 回転パラメータ ----
v0  = ax.View;
az0 = v0(1);
el0 = v0(2);

azList = linspace(az0, az0 + 360, nFrame);

if elMode == "sweep"
    t = linspace(0, 2*pi, nFrame);
    elList = el0 + (elSweep(2)-elSweep(1))/2 * sin(t);
else
    elList = el0 * ones(size(azList));
end

% ---- ESCキーで停止 ----
stopFlag = false;
if useEscapeToStop
    oldKeyFcn = hFig.KeyPressFcn;
    hFig.KeyPressFcn = @onKey;
end

% ---- 自動回転再生 ----
dt = 1 / fps;
loopCount = 0;

fprintf('Playing rotation (ESC to stop)...\n');

while loopCount < nLoop && isvalid(hFig) && isvalid(ax) && ~stopFlag
    loopCount = loopCount + 1;

    for k = 1:numel(azList)
        if ~isvalid(hFig) || ~isvalid(ax) || stopFlag
            break;
        end

        view(ax, azList(k), elList(k));
        drawnow limitrate;  % 軽量描画

        pause(dt);          % 再生速度制御（不要なら削除）
    end
end

% ---- 後始末 ----
if useEscapeToStop && isvalid(hFig)
    hFig.KeyPressFcn = oldKeyFcn;
end

fprintf('Stopped.\n');

% ---- nested function ----
function onKey(~, evt)
    if strcmp(evt.Key, "escape")
        stopFlag = true;
    end
end
