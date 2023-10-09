function voltage_ab = Join_Voltage_Recordings(voltage_a,voltage_b)
% Join two voltage recording structures
%
%   voltage_ab = Join_Voltage_Recordings(voltage_a,voltage_b)
%
% See also Read_Voltage_Recording
%
% By Jesus Perez-Ortega, Oct 2022
% Modified Sep 2023 (licking added)


if isfield(voltage_a,'Stimuli')&&isfield(voltage_b,'Stimuli')
    voltage_ab.Stimuli = [voltage_a.Stimuli voltage_b.Stimuli];
    disp('   Stimuli joined')
end

if isfield(voltage_a,'Locomotion')&&isfield(voltage_b,'Locomotion')
    voltage_ab.Locomotion = [voltage_a.Locomotion voltage_b.Locomotion];
    disp('   Locomotion joined')
end

if isfield(voltage_a,'Laser')&&isfield(voltage_b,'Laser')
    voltage_ab.Laser = [voltage_a.Laser voltage_b.Laser];
    disp('   Laser joined')
end

if isfield(voltage_a,'Licking')&&isfield(voltage_b,'Licking')
    voltage_ab.Licking = [voltage_a.Licking voltage_b.Licking];
    disp('   Licking joined')
end

if isfield(voltage_a,'File')&&isfield(voltage_b,'File')
    voltage_ab.File = [voltage_a.File voltage_a.File];
end

if isfield(voltage_a,'RecordingSampleRate')&&isfield(voltage_b,'RecordingSampleRate')
    voltage_ab.RecordingSampleRate = voltage_a.RecordingSampleRate;
    if voltage_a.RecordingSampleRate~=voltage_b.RecordingSampleRate
        warning('Sampling rate is different between recordings!')
    end
end

if isfield(voltage_a,'DownsampledTo')&&isfield(voltage_b,'DownsampledTo')
    voltage_ab.DownsampledTo = voltage_a.DownsampledTo;
    if voltage_a.DownsampledTo~=voltage_b.DownsampledTo
        warning('Downsampling is different between recordings!')
    end
end

if isfield(voltage_a,'Method')&&isfield(voltage_b,'Method')
    voltage_ab.Method = voltage_a.Method;
    if voltage_a.Method~=voltage_b.Method
        warning('Downsampling method is different between recordings!')
    end
end