function ISC_txt_to_mat_app(app)
%ISC_txt_to_mat_app  Convert ISC saved text (EVENT_CATALOGUE or ISF2 blocks) to MAT.
%
%   ISC_txt_to_mat_app(app)
%     1) Prompts user to select a saved ISC text file.
%     2) Parses it into tables compatible with the ISC Earthquake Toolbox style:
%           Primes, Hypocentres, Magnitudes, Phases
%     3) Prompts user to save a MAT file.
%
%   Supports:
%     - "DATA_TYPE EVENT_CATALOGUE" (CSV-like rows; typical when you copy/save web results)
%     - legacy "Event ####" block format (routes through readISCData.m if present)
%
%   This function does NOT perform any web access.

    if nargin ~= 1
        error('Usage: ISC_txt_to_mat_app(app)');
    end

    % ---- Select input text file ----
    [inFile, inDir] = uigetfile({ ...
        '*.txt;*.csv', 'ISC saved text (*.txt,*.csv)'; ...
        '*.*',         'All files (*.*)'} , ...
        'Select ISC saved text file');

    if isequal(inFile, 0)
        return; % user cancelled
    end

    inPath = fullfile(inDir, inFile);
    textData = fileread(inPath);

    % ---- Parse ----
    [Primes, Hypocentres, Magnitudes, Phases, meta] = parse_ISC_saved_text(textData);

    % ---- Optional: fix primes if compatible tables exist ----
    % If parse produced all the legacy fields, fix_primes can fill NaT primes.
    if exist('fix_primes', 'file') == 2
        try
            requiredVars = { ...
                'Date','Err','RMS','Latitude','Longitude','Smaj','Smin','Az','Depth', ...
                'EpicentreFixed','Err1','Ndef','Nsta','Gap','mdist','Qual','Author','OrigID','EventID'};
            if istable(Primes) && istable(Hypocentres) && all(ismember(requiredVars, Primes.Properties.VariableNames)) ...
                    && all(ismember(requiredVars, Hypocentres.Properties.VariableNames))
                Primes = fix_primes(Primes, Hypocentres);
            end
        catch
            % silently skip
        end
    end

    % ---- Save ----
    [~, baseName] = fileparts(inFile);
    defaultOut = baseName + ".mat";

    [outFile, outDir] = uiputfile({'*.mat','MAT-file (*.mat)'}, 'Save parsed ISC data as', defaultOut);
    if isequal(outFile, 0)
        return;
    end

    outPath = fullfile(outDir, outFile);
    save(outPath, 'Primes', 'Hypocentres', 'Magnitudes', 'Phases', 'meta');

    % ---- Light feedback (works both in scripts and App Designer) ----
    try
        uialert(app.UIFigure, sprintf('Saved: %s', outPath), 'ISC txt → MAT');
    catch
        disp(['Saved: ', outPath]);
    end
end

function [Primes, Hypocentres, Magnitudes, Phases, meta] = parse_ISC_saved_text(textData)
%PARSE_ISC_SAVED_TEXT  Detect format and parse.

    meta = struct();
    meta.source = 'ISC saved text';

    % ---- Capture search summary if present ----
    meta.events_found = NaN;
    tok = regexp(textData, 'Events found:\s*(\d+)', 'tokens', 'once');
    if ~isempty(tok)
        meta.events_found = str2double(tok{1});
    end

    % Identify format
    isEventCatalogue = contains(textData, 'DATA_TYPE EVENT_CATALOGUE');
    isLegacyBlocks   = ~isEventCatalogue && ~isempty(regexp(textData, 'Event\s+\d+', 'once'));

    if isEventCatalogue
        [Primes, Hypocentres, Magnitudes, Phases, meta2] = parse_EVENT_CATALOGUE(textData);
        meta = mergeStruct(meta, meta2);
        return;
    end

    if isLegacyBlocks
        % Legacy toolbox pathway
        Primes = table; Hypocentres = table; Magnitudes = table; Phases = table;

        include_phases = 'off';
        include_magnitudes = 'on';

        if exist('readISCData', 'file') == 2
            try
                [Primes, Hypocentres, Magnitudes, Phases] = readISCData(textData, ...
                    Primes, Hypocentres, Magnitudes, Phases, include_phases, include_magnitudes);
                meta.format = 'ISF2 legacy blocks (Event ####)';
                return;
            catch ME
                meta.format = 'ISF2 legacy blocks (Event ####)';
                meta.parse_error = ME.message;
            end
        else
            meta.format = 'ISF2 legacy blocks (Event ####)';
            meta.parse_error = 'readISCData.m not found on path.';
        end
    end

    % If unknown, return empty tables (but keep meta)
    Primes = table; Hypocentres = table; Magnitudes = table; Phases = table;
    meta.format = 'Unknown';
end

function [Primes, Hypocentres, Magnitudes, Phases, meta] = parse_EVENT_CATALOGUE(textData)
%PARSE_EVENT_CATALOGUE  Parse "DATA_TYPE EVENT_CATALOGUE" CSV-like rows.
%
% Expected header (example):
%   EVENTID,TYPE,AUTHOR,DATE,TIME,LAT,LON,DEPTH,DEPFIX,AUTHOR,TYPE,MAG,...
%
% Returns:
%   Primes/Hypocentres: single-row-per-event with legacy ISC toolbox fields.
%   Magnitudes: one-row-per-magnitude triplet.
%   Phases: empty.

    meta = struct();
    meta.format = 'DATA_TYPE EVENT_CATALOGUE';

    % Keep only the EVENT_CATALOGUE section (best-effort)
    % Start from the first occurrence of header line beginning with EVENTID
    lines = splitlines(string(textData));
    idxHeader = find(startsWith(strtrim(lines), "EVENTID"), 1, 'first');
    if isempty(idxHeader)
        % Sometimes the header is truncated in display, fall back to first data line
        idxHeader = find(~cellfun(@isempty, regexp(lines, '^\s*\d+\s*,', 'once')), 1, 'first') - 1;
        if isempty(idxHeader)
            Primes = table; Hypocentres = table; Magnitudes = table; Phases = table;
            meta.parse_error = 'Could not find EVENT_CATALOGUE header/data lines.';
            return;
        end
    end

    dataStart = idxHeader + 1;
    dataLines = lines(dataStart:end);

    % Stop if we hit an obvious footer
    stopIdx = find(contains(dataLines, "Agencies whose data contributed") | startsWith(strtrim(dataLines), "STOP"), 1, 'first');
    if ~isempty(stopIdx)
        dataLines = dataLines(1:stopIdx-1);
    end

    % Keep only lines that look like data rows
    isRow = ~cellfun(@isempty, regexp(dataLines, '^\s*\d+\s*,', 'once'));
    dataLines = dataLines(isRow);

    n = numel(dataLines);
    if n == 0
        Primes = table; Hypocentres = table; Magnitudes = table; Phases = table;
        meta.parse_error = 'No EVENT_CATALOGUE data rows found.';
        return;
    end

    % Preallocate lists
    EventID   = nan(n,1);
    EventType = strings(n,1);
    Author    = strings(n,1);
    Date      = NaT(n,1);
    Latitude  = nan(n,1);
    Longitude = nan(n,1);
    Depth     = nan(n,1);
    DepFixRaw = strings(n,1);

    % Magnitudes (variable count)
    magEventID = [];
    magAuthor  = strings(0,1);
    magType    = strings(0,1);
    magValue   = [];

    for i = 1:n
        row = strtrim(dataLines(i));
        parts = strsplit(row, ',', 'CollapseDelimiters', false);

        % Minimum fields expected: 9
        if numel(parts) < 9
            continue;
        end

        EventID(i)   = str2double(parts{1});
        EventType(i) = string(parts{2});
        Author(i)    = string(parts{3});
        dateStr      = string(parts{4});
        timeStr      = string(parts{5});

        dt = parse_ISC_datetime(dateStr, timeStr);
        Date(i) = dt;

        Latitude(i)  = str2double(parts{6});
        Longitude(i) = str2double(parts{7});
        Depth(i)     = str2double(parts{8});
        DepFixRaw(i) = string(parts{9});

        % Remaining are magnitude triplets: AUTHOR, TYPE, MAG
        if numel(parts) >= 12
            rest = parts(10:end);
            % Trim trailing empties
            while ~isempty(rest) && (isempty(rest{end}) || all(isspace(rest{end})))
                rest(end) = [];
            end

            nTrip = floor(numel(rest)/3);
            for k = 1:nTrip
                a = string(rest{3*k-2});
                t = string(rest{3*k-1});
                m = str2double(rest{3*k});

                if strlength(strtrim(a)) == 0 && strlength(strtrim(t)) == 0 && isnan(m)
                    continue;
                end

                magEventID(end+1,1) = EventID(i); %#ok<AGROW>
                magAuthor(end+1,1)  = a; %#ok<AGROW>
                magType(end+1,1)    = t; %#ok<AGROW>
                magValue(end+1,1)   = m; %#ok<AGROW>
            end
        end
    end

    % Build legacy-shaped Primes/Hypocentres
    Primes = table;
    Primes.Date = Date;
    Primes.Err = nan(n,1);
    Primes.RMS = nan(n,1);
    Primes.Latitude = Latitude;
    Primes.Longitude = Longitude;
    Primes.Smaj = nan(n,1);
    Primes.Smin = nan(n,1);
    Primes.Az = nan(n,1);
    Primes.Depth = Depth;

    % Map DEPFIX to categorical used in toolbox (best-effort)
    % Original toolbox uses EpicentreFixed categorical {"True","False"}.
    ep = repmat("True", n, 1);
    % If DEPFIX is explicitly TRUE, interpret as fixed => True (leave).
    % If blank, keep as True (unknown in this format).
    ep = categorical(ep);
    Primes.EpicentreFixed = ep;

    Primes.Err1 = nan(n,1);
    Primes.Ndef = nan(n,1);
    Primes.Nsta = nan(n,1);
    Primes.Gap  = nan(n,1);
    Primes.mdist = nan(n,1);
    Primes.Qual = categorical(repmat("", n, 1));
    Primes.Author = categorical(Author);
    Primes.OrigID = nan(n,1);
    Primes.EventID = EventID;

    % Keep extra useful fields at the end (won't break existing code that uses known names)
    Primes.EventType = categorical(EventType);
    Primes.DepFixRaw = categorical(DepFixRaw);

    % Hypocentres: in EVENT_CATALOGUE we only have the prime origin; duplicate it
    Hypocentres = Primes(:, Primes.Properties.VariableNames);

    % Magnitudes
    Magnitudes = table;
    if ~isempty(magEventID)
        Magnitudes.EventID = magEventID;
        Magnitudes.Author  = categorical(magAuthor);
        Magnitudes.Type    = categorical(magType);
        Magnitudes.Mag     = magValue;
    else
        Magnitudes.EventID = [];
        Magnitudes.Author  = categorical(string.empty(0,1));
        Magnitudes.Type    = categorical(string.empty(0,1));
        Magnitudes.Mag     = [];
    end

    % Phases: not present in EVENT_CATALOGUE
    Phases = table;

    meta.n_events_parsed = height(Primes);
    meta.n_magnitudes_parsed = height(Magnitudes);
end

function dt = parse_ISC_datetime(dateStr, timeStr)
%PARSE_ISC_DATETIME  Robust datetime for ISC EVENT_CATALOGUE.

    dt = NaT;
    dateStr = strtrim(string(dateStr));
    timeStr = strtrim(string(timeStr));

    if strlength(dateStr) == 0
        return;
    end

    if strlength(timeStr) == 0
        timeStr = "00:00:00";
    end

    % Try with fractional seconds
    try
        dt = datetime(dateStr + " " + timeStr, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SS');
        return;
    catch
    end

    % Try more digits
    try
        dt = datetime(dateStr + " " + timeStr, 'InputFormat', 'yyyy-MM-dd HH:mm:ss.SSS');
        return;
    catch
    end

    % Try no fractional
    try
        dt = datetime(dateStr + " " + timeStr, 'InputFormat', 'yyyy-MM-dd HH:mm:ss');
        return;
    catch
    end

    % Last resort: let MATLAB guess
    try
        dt = datetime(dateStr + " " + timeStr);
    catch
        dt = NaT;
    end
end

function out = mergeStruct(a, b)
%MERGESTRUCT shallow merge (b overwrites a)
    out = a;
    if isempty(b)
        return;
    end
    fn = fieldnames(b);
    for i = 1:numel(fn)
        out.(fn{i}) = b.(fn{i});
    end
end
