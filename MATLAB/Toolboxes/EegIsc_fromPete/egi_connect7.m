buffer_size_cmd = 1000000;
buffer_size_stream = 10000000;

% setup the amp
tcmd = tcpip('10.0.0.42', 9877);
set(tcmd, 'InputBufferSize', buffer_size_cmd);
fopen(tcmd);
fprintf(tcmd, '(sendCommand cmd_SetPower 0 0 1)\n');
pause(1);
fprintf(tcmd, '(sendCommand cmd_DefaultAcquisitionState 0 0 1)\n'); % 30 hz
pause(3);
%fprintf(tcmd, '(sendCommand cm_DefaultSignalGeneration 0 0 1)\n');
%pause(1);

% setup the input stream
tstream = tcpip('10.0.0.42', 9879);
set(tstream , 'InputBufferSize', buffer_size_stream);
fopen(tstream );
fprintf(tstream, '(sendCommand cmd_ListenToAmp 0 0 1)\n');
set(tstream, 'Terminator', ''); % for increasing data throughput

streams_opened = true; % for closing down correctly

% start streaming
pause(1);
fprintf(tcmd, '(sendCommand cmd_Start 0 0 1)\n');

% begin processing stream information
num_iterations = 0;
num_no_data = 0;
in_header = true;
header_size_bytes = 16;
in_packet = false;
packet_size_bytes = 1152;
packets_per_iteration = 10;
packets_to_read = 0;

packet_record_length = 1024/4;
num_channels_in_packet = 128;
num_packet_record_buffers = 5;
packet_record = zeros(num_channels_in_packet,packet_record_length,num_packet_record_buffers);
%channels_of_interest = [5,6,11,12];
channels_of_interest = [75,70,83];
current_packet_record_idx = 1;
current_packet_record_buffer = 1;
last_completed_packet_record_buffer = 0;
last_displayed_packet_record_buffer = 0;
num_buffers_read = 0;
num_bytes_read = 0;

num_displays = 0;

% display priming
figure(1);
s_window = 64;
s_overlap = 32;
%s_fft = 128;
s_fft = 5:.25:15;
s_hz = 1000;
spectrogram(packet_record(1,:,1),s_window,s_overlap,s_fft,s_hz);
bytes_available_last = 0;

try
    tic;
    while 1,
        action_completed = false;
        
        num_iterations = num_iterations+1;
        %bytes_available = get(tstream, 'BytesAvailable');
        bytes_available = tstream.BytesAvailable;
        if bytes_available == buffer_size_stream, % if the buffer fills up, we're lost!
            error('.. data overflow');
        end
        
        if mod(num_iterations,100)+1==1,
            time=toc;
            fprintf(1,'[%d : %d] %.2gs (%.1f b/s)\n', bytes_available, num_bytes_read, time, num_bytes_read/time);
        end
        
        % read the header if we're done with all packets
        if in_header && bytes_available>=header_size_bytes,
            %x = double(swapbytes(fread(tstream,2,'uint64=>uint64')));
%             x = double(swapbytes(fread(tstream,2,'float64')));
%             x = typecast(x,'uint64')
            x0 = fread(tstream,2,'float64');
            x1 = typecast(x0,'uint64');
            x = double(x1);
            num_bytes_read = num_bytes_read+16;
            packet_bytes_to_read = x(2);
            num_packets_to_read = floor(packet_bytes_to_read/packet_size_bytes);

            if num_packets_to_read>50, % error checking
                error(sprintf('.. requested too many packets (%d), %d bytes available',num_packets_to_read,bytes_available));
            end
            
            in_header = false;
            in_packet = true;
            action_completed = true;
        end
        
        % read packets after headers have been read
        if in_packet && bytes_available>=packet_bytes_to_read,
            xx = fread(tstream,packet_bytes_to_read);
            for pi=1:num_packets_to_read,
                pi0 = 33+(pi-1)*1152;
                pi1 = pi0+1120-1;
                packet_data = swapbytes(typecast(uint8(xx(pi0:pi1)),'single'));
                
                % store the read in packets in a rotating buffer
                packet_record(1:num_channels_in_packet,current_packet_record_idx,current_packet_record_buffer) = ...
                    double(packet_data(1:num_channels_in_packet));
                current_packet_record_idx = current_packet_record_idx+1;
                if current_packet_record_idx>packet_record_length, % buffer is filled
                    current_packet_record_idx = 1;
                    last_completed_packet_record_buffer = current_packet_record_buffer;
                    num_buffers_read = num_buffers_read+1;
                    current_packet_record_buffer = current_packet_record_buffer+1;
                    if current_packet_record_buffer>num_packet_record_buffers,
                        current_packet_record_buffer = 1;
                    end
                end
            end
            num_bytes_read = num_bytes_read+packet_bytes_to_read;
            
            packet_bytes_to_read = 0;
            num_packets_to_read = 0;
            in_packet = false;
            in_header = true;
            action_completed = true;
        end
        
        % display code goes here
        if last_completed_packet_record_buffer~=0 && last_displayed_packet_record_buffer~=last_completed_packet_record_buffer,
            datax = packet_record(channels_of_interest,:,last_completed_packet_record_buffer);
            data0 = sum(datax,1);
            data1 = detrend(data0);
            data = data1;
            [s,f,t,p]=spectrogram(data,s_window,s_overlap,s_fft,s_hz);
            num_displays = num_displays+1;
            power_record(num_displays) = sum(p(:));
            if mod(num_displays,4)==0,
                figure(1);
                spectrogram(data,s_window,s_overlap,s_fft,s_hz);
                figure(2);
                pi0 = max(10,num_displays-200);
                pi1 = min(num_displays,pi0+200);
                plot(power_record(pi0:pi1));
                title(sprintf('buffer %d',num_buffers_read));
                hold on;
                pavg = mean(power_record(pi0:pi1));
                plot([1 pi1-pi0+1],[pavg,pavg],'r-');
                hold off;
                pause(.0001);
            end
            last_displayed_packet_record_buffer = last_completed_packet_record_buffer
        end

        % don't timeout if data is still coming in
        if bytes_available_last < bytes_available,
            action_completed = true;
        end
        
        if ~action_completed,
            num_no_data = num_no_data+1;
            if num_no_data==inf,
                error('...timeout');
            end
        else
            num_no_data = 0;
        end
    end
catch e
    disp('cleaning up...');
    tstream
    e
    cleanup_streams;
end
cleanup_streams;
