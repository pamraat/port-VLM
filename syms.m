function S = syms(varargin)
%SYMS   Short-cut for constructing symbolic variables.
%   SYMS arg1 arg2 ...
%   is short-hand notation for creating symbolic variables
%      arg1 = sym('arg1');
%      arg2 = sym('arg2'); ...
%   or, if the argument has the form f(x1,x2,...), for
%   creating symbolic variables
%      x1 = sym('x1');
%      x2 = sym('x2');
%      ...
%      f = symfun(sym('f(x1,x2,...)'), [x1, x2, ...]);
%   The outputs are created in the current workspace.
%
%   SYMS  ... ASSUMPTION
%   additionally puts an assumption on the variables created.
%   The ASSUMPTION can be 'real', 'rational', 'integer', or 'positive'.
%   SYMS  ... clear
%   clears any assumptions on the variables created, including those
%   made with the ASSUME command.
%
%   SYMS({symvar1, symfun1,  ...})
%   is equal to the call SYMS 'symvar1' 'symfun1'  ...
%
%   SYMS({symvar1, symfun1, ...}, ASSUMPTION)
%   is equal to the call SYMS 'symvar1' 'symfun1'  ... ASSUMPTION
%
%   SYMS([symvar1, symvar2,  ...])
%   is equal to the call SYMS 'symvar1' 'symvar2'  ...
%
%   SYMS([symvar1, symvar2, ...], ASSUMPTION)
%   is equal to the call SYMS 'symvar1' 'symvar2'  ... ASSUMPTION
%
%   Each input argument must begin with a letter and must contain only
%   alphanumeric characters.
%
%   S = SYMS returns a cell array containing the names of the symbolic 
%   variables in the workspace. Without an output argument, SYMS lists
%   the symbolic variables in the workspace.
%
%   Example 1:
%      syms x beta real
%   is equivalent to:
%      x = sym('x','real');
%      beta = sym('beta','real');
%
%   To clear the symbolic objects x and beta of 'real' or 'positive'  
%   status, type
%      syms x beta clear
%
%   Example 2:
%      syms x(t) a
%   is equivalent to:
%      a = sym('a');
%      t = sym('t');
%      x = symfun(sym('x(t)'), [t]);
%
%   Example 3:
%      syms({sym('u'), sym('v'), sym('w')})
%   is equivalent to:
%      syms u v w
%
%   Example 4:
%      syms({symfun('u(t)',sym('t')), symfun('v(t)',sym('t')), symfun('w(t)',sym('t'))})
%   is equivalent to:
%      syms u(t) v(t) w(t)
%
%   Example 5:
%      syms({sym('u'), sym('v'), sym('w')}, 'real')
%   is equivalent to:
%      syms u v w real
%
%   Example 6:
%      syms([sym('u'), sym('v'), sym('w')])
%   is equivalent to:
%      syms u v w
%
%   Example 7:
%      Clear all symbolic variables in the workspace:
%      syms u v w
%      S = syms;
%      cellfun(@clear, S);
%      
%   See also SYM, SYMFUN.
%   Deprecated API:
%   The 'unreal' keyword can be used instead of 'clear'.

%   Copyright 1993-2016 The MathWorks, Inc.

if nargin == 0
    w = evalin('caller','whos');
    clsnames = {w.class};
    allsyms = {w(strcmp('sym',clsnames) | strcmp('symfun',clsnames)).name}; 
    if nargout == 1
        S = allsyms';
        return
    end
    if numel(allsyms) == 0
        return;
    end
    % determine number of columns to display depending on width of window
    columWidth = max(cellfun(@length, allsyms))+2;
    windowsize = matlab.desktop.commandwindow.size;
    cols = max(1, fix(0.98*windowsize(1)/columWidth));
    rows = ceil(numel(allsyms)/cols);
    % Reorder sorted list of names column-wise in a string array
    out = string(zeros(rows,cols));
    idx = 1;
    for col = 1:cols
        for row = 1:rows
            if idx <= numel(allsyms)
                out(row,col) = allsyms{idx};
            else
                out(row,col) = "";
            end
            idx = idx + 1;
        end
    end
    % display string array
    fprintf('\n%s\n\n', getString(message('symbolic:sym:sym:YourSymbolicVariablesAre')));
    formatstring = ['%-' num2str(columWidth) 's'];
    for row = 1:rows
        for col = 1:cols
            fprintf(formatstring, out(row,col));
        end
        fprintf('\n');
    end
    fprintf('\n');
    return;
end

if nargout > 0 
    error(message('symbolic:sym:sym:EitherInputOrOutput'));
end

numberOfArgs = nargin;

% the following flags can be used as last argument:
flags = {'real','clear','positive','rational','integer'};

% Convert sym objects and cell arrays to a cell array of chars
% and proceed as usual.
if numberOfArgs > 0
    firstArg = varargin{1};
    if isa(firstArg, 'sym') || iscell(firstArg) || isstring(firstArg)
        if nargin > 2 
            error(message('symbolic:misc:IncorrectNumberOfArguments')); 
        end
        if nargin == 2 && ~any(strcmp(varargin{2}, flags))
            error(message('symbolic:sym:InvalidAssumption2')); 
        end
        % strip first argument
        if isempty(firstArg) 
            if numberOfArgs == 2 
                % varargin must be a cell
                varargin = varargin(2);
            end
            numberOfArgs = numberOfArgs-1;
        else
            if isstring(firstArg)
                if any(ismissing(firstArg))
                    error(message('symbolic:sym:errmsg1'));
                end
                help = firstArg;
            elseif isa(firstArg, 'sym')
                help = arrayfun(@char, firstArg(:), 'UniformOutput', false); 
            else
                help = cellfun(@toChar, firstArg(:), 'UniformOutput', false); 
            end
            if numberOfArgs > 1
                varargin = [help; varargin{2}];
            else
                varargin = help;
            end
        end
   end
end
if numberOfArgs == 0 
    return;
end

if any(strcmp(varargin{end}, flags))
    control = varargin{end};
    args = varargin(1:end-1);
elseif strcmp(varargin{end}, 'unreal')
    control = 'clear';
    warning(message('symbolic:sym:DeprecateUnreal'));
    args = varargin(1:end-1);
else
    control = '';
    args = varargin;
end

% check whether caller workspace equals base workspace
calledFromBase = mupadmex('', 8);

toDefine = sym(zeros(1, 0));
defined = sym(zeros(1, length(args)));
for k=1:length(args)
    x = args{k};
    if ismissing(x)
        error(message('symbolic:sym:errmsg1'));
    end
    if isvarname(x) && ~any(strcmp(x, flags))
        xsym = sym(x);
        % check whether syms is called from another function and 
        % x already exists and is not overshadowed by the caller
        varexists = evalin('caller', "exist('" + x + "')");
        if ~calledFromBase && varexists >= 2 && varexists ~= 7
            error(message('symbolic:sym:SymsCannotOvershadow', x));
        end
        assignin('caller', x, xsym);
        if ~isempty(control)
            assume(xsym, control);
        end
        defined(k) = xsym;
    elseif isempty(find(x == '(', 1))
        error(message('symbolic:sym:errmsg1'));
    else
        % If a bracket occurs, handle this as a symfun declaration
        [name, vars] = symfun.parseString(x);
        if any(strcmp(name, flags)) 
            error(message('symbolic:sym:errmsg1'));
        end    
        xsym = symfun(x, [vars{:}]);
        % as a side-effect, define all variables that occur as arguments
        toDefine = [toDefine vars{:}]; %#ok<AGROW>.
        defined(k) = sym(name);
        varexists = evalin('caller', "exist('" + name + "')");
        if ~calledFromBase && varexists >= 2 && varexists ~= 7
            error(message('symbolic:sym:SymsCannotOvershadow', name));
        end
        % define the symfun
        assignin('caller', name, xsym);
        % warn that assumptions cannot pertain to symfuns
        % unless the flag is clear 
        if ~isempty(control) && ~strcmp(control, 'clear')
            warning(message('symbolic:sym:VariableExpected', x));
        end 
    end
end

% in the end, define all variables that have occurred only as arguments
for ysym = setdiff(toDefine, defined)
    y = char(ysym);
    if any(strcmp(y, flags))
        error(message('symbolic:sym:errmsg1'));
    end
    varexists = evalin('caller', "exist('" + y + "')");
    if ~calledFromBase && varexists >= 2 && varexists ~= 7
        error(message('symbolic:sym:SymsCannotOvershadow', y));
    end 
    assignin('caller', y, ysym);
end

end

function C = toChar(O)
if any(ismissing(O))
    error(message('symbolic:sym:errmsg1'));
end
C = char(O);
end
