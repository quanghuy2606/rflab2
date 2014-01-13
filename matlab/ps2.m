saveFig = true;

[f, s, z] = readSparamFile('ANTBRXB.s1p');

y = [min(s), max(s)];
gsm = [890, 915, 935, 960] * 1e6;

% Gain
Gtmax = max(abs(s))^2;
gg = find(abs(s).^2 == Gtmax);

% Attenuation
ss = [find(f <= gsm(3), 1, 'last'), find(f >= gsm(4), 1, 'first')];
ll = (ss(1)-1) * [1 1];
ss = abs(s(ss(1) : ss(2))) .^2;
ll = ll + [find(ss == max(ss)), find(ss == min(ss))];
L = 1 ./ ([max(ss), mean(ss), min(ss)]);

% 3 dB BW
ff = find(abs(s) == max(abs(s))) * [1 1];
ff(1) = find(abs(s(1 : ff(1))).^2 <= Gtmax / 2, 1, 'last');
ff(2) = ff(2)-1 + find(abs(s(ff(2) : end)).^2 <= Gtmax / 2, 1, 'first');

% Noise BW
Bn = 1/Gtmax * sum(diff(f) .* abs(s(1:end-1)) .^ 2);
i = floor(Bn / mean(diff(f(ff(1) : ff(2)))));
ss = abs(s(ff(1) : ff(1) + i)).^2;
k = [1 i];
for j = 1 : ff(2) - (ff(1)+i)
	sss = abs(s(ff(1) + j : ff(1) + j + i)).^2;
	if (sum(sss) > sum(ss))
		k(1) = j;
	end
end

figure(1);
clf;
hold on;
% GSM bands
for i = 1 : 4
    plot(gsm(i) * [1 1] / 1e6, 20*log10(abs(y)) + 8 * [-1 1], 'r', 'linewidth', 1);
end

arrow(  [gsm(1) / 1e6, 20*log10(abs(y(1))) - 4], ... 
        [gsm(2) / 1e6, 20*log10(abs(y(1))) - 4], ...
        'Ends', 'Both', 'Length', 10, 'BaseAngle', 75, 'TipAngle', 15, ...
		'FaceColor', 'r', 'EdgeColor', 'r');
arrow(  [gsm(3) / 1e6, 20*log10(abs(y(1))) - 4], ... 
        [gsm(4) / 1e6, 20*log10(abs(y(1))) - 4], ...
        'Ends', 'Both', 'Length', 10, 'BaseAngle', 75, 'TipAngle', 15, ...
		'FaceColor', 'r', 'EdgeColor', 'r');
	
text(	mean(gsm(1:2)/1e6), ...
		20*log10(abs(y(1))) - 12, ...
		'BS RX: $$890 - 915$$ MHz',...
		'HorizontalAlignment',  'center', ... 
		'Interpreter',          'latex', ...
		'BackgroundColor',      'w', ...
		'color',				'r');
text(	mean(gsm(3:4)/1e6), ...
		20*log10(abs(y(1))) - 12, ...
		'BS TX: $$935 - 960$$ MHz' ,...
		'HorizontalAlignment',  'center', ... 
		'Interpreter',          'latex', ...
		'BackgroundColor',      'w', ...
		'color',				'r');

% 3 dB BW
for i = 1 : 2
	plot(f(ff(i)) * [1 1] / 1e6, 20*log10(abs(y)) + 8 * [-1 1], 'b', 'linewidth', 1);
end

arrow(  [f(ff(1)) / 1e6, 20*log10(abs(y(1))) + 16], ... 
        [f(ff(2)) / 1e6, 20*log10(abs(y(1))) + 16], ...
        'Ends', 'Both', 'Length', 10, 'BaseAngle', 75, 'TipAngle', 15, ...
		'FaceColor', 'b', 'EdgeColor', 'b');
	
text(	mean(f(ff(1:2))/1e6), ...
		20*log10(abs(y(1))) + 16 - 8, ...
		sprintf('3 dB BW: %.1f MHz', diff(f(ff)) / 1e6), ...
		'HorizontalAlignment',  'center', ... 
		'Interpreter',          'latex', ...
		'BackgroundColor',      'w', ...
		'color',				'b');

% Noise BW
for i = 1 : 2
	plot(f(ff(1)+sum(k(1:i))) * [1 1] / 1e6, 20*log10(abs(y)) + 8 * [-1 1], 'g', 'linewidth', 1);
end

h = plot(f / 1e6, 20*log10(abs(s)), 'k', 'linewidth', 2);

arrow(  [f(ff(1) + sum(k(1:1))) / 1e6, 20*log10(abs(y(1))) + 36], ... 
        [f(ff(1) + sum(k(1:2))) / 1e6, 20*log10(abs(y(1))) + 36], ...
        'Ends', 'Both', 'Length', 10, 'BaseAngle', 75, 'TipAngle', 15, ...
		'FaceColor', 'g', 'EdgeColor', 'g');
	
text(	mean([f(ff(1) + sum(k(1:1))), f(ff(1) + sum(k(1:2)))]) / 1e6, ...
		20*log10(abs(y(1))) + 36 - 8, ...
		sprintf('``Noise BW'''': %.1f MHz', Bn / 1e6), ...
		'HorizontalAlignment',  'center', ... 
		'Interpreter',          'latex', ...
		'BackgroundColor',      'w', ...
		'color',				'g');

% Gains / Attenuations
text(	mean(gsm(3:4)/1e6), ...
		20*log10(abs(y(2))) - 10, ...
		sprintf('$$|S_{12}|_\\mathrm{max} = %.1f$$ dB ($$f = %.1f$$ MHz)', ...
			10*log10(Gtmax), f(gg) / 1e6), ...
		'HorizontalAlignment',  'center', ... 
		'Interpreter',          'latex', ...
		'BackgroundColor',      'w', ...
		'color',				'k');
	
text(	mean(gsm(3:4)/1e6), ...
		20*log10(abs(y(2))) - 25, ...
		sprintf('$$L_\\mathrm{TX,\\;avg} = %.1f$$ dB', 10*log10(L(2))), ...
		'HorizontalAlignment',  'center', ... 
		'Interpreter',          'latex', ...
		'BackgroundColor',      'w', ...
		'color',				'k');
	
text(	mean(gsm(3:4)/1e6), ...
		20*log10(abs(y(2))) - 40, ...
		sprintf('$$L_\\mathrm{TX,\\;min} = %.1f$$ dB ($$f = %.1f$$ MHz)', ...
			10*log10(L(1)), f(ll(1)) / 1e6), ...
		'HorizontalAlignment',  'center', ... 
		'Interpreter',          'latex', ...
		'BackgroundColor',      'w', ...
		'color',				'k');
	
text(	mean(gsm(3:4)/1e6), ...
		20*log10(abs(y(2))) - 55, ...
		sprintf('$$L_\\mathrm{TX,\\;max} = %.1f$$ dB ($$f = %.1f$$ MHz)', ...
			10*log10(L(3)), f(ll(2)) / 1e6), ...
		'HorizontalAlignment',  'center', ... 
		'Interpreter',          'latex', ...
		'BackgroundColor',      'w', ...
		'color',				'k');

hold off;
grid on;

x = 850:10:970;
xlim([min(x), max(x)]);
set(gca, 'XTickMode', 'Manual');
set(gca, 'XTick', x);
set(gca, 'XTickLabel', ...
    cellfun(@num2str, {x'}, 'UniformOutput', false));

title('GSM Base Station Pre-Amplifier Block', 'interpreter', 'latex');
ylabel('$$|S_{12}|$$ [dB]', 'interpreter', 'latex');
xlabel('$$f$$ [MHz]', 'interpreter', 'latex');

legend(h, {'$$\mathrm{ANT_B \rightarrow RX_{B1}}$$'}, ...
	'interpreter', 'latex');

if saveFig
exportfig(gcf, 'dpx.eps', ...
	'width',		18, ...
	'height',		10, ...
	'color',		'rgb', ...
	'resolution',	300, ...
	'LockAxes',		1, ...
	'FontMode',		'fixed', ...
	'FontSize',		9, ...
	'LineMode',		'scaled'	);
end
