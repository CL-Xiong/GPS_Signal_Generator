% ----------------------------------------------------------------------- %
%                       GPS Message Signal Creator                        %
%                                                                         %
%   Description: This file creates the message signal and populates the   %
%       appropriate registers in the ROACH.                               %
%                                                                         %
%   Created by Kurt Pedross                                               %
%       Jan 12th 2017   - ERAU Spring 2017                                %
% ----------------------------------------------------------------------- %
%addpath('/home/user/Desktop/KurtPedrosa/Pedrosa_kurt_Files/katcp_lib/@katcp/')
addpath('/home/user/Desktop/KurtPedrosa/Pedrosa_kurt_Files/katcp_lib/')

clc
clear

TESTING_IN_PROGRESS = 0;
% Connect to roach times katcp doesn't connect the
%   first time. Therefor this will retry until it does.
roach_connected = 0;
while ~roach_connected
    try
        % Define which firmware to upload
        fw = 'gps_full_signal_2017_Jun_07_2247.bof'; % .bof file

        rhost = '192.168.4.117'; % IP Address for roach being used

        fprintf('Attempting to connect to %s and load %s\n', rhost, fw );
        roach = katcp(rhost);

        % As per Dr. Barott:
        %   'Don't forget to use the modified KATCP that allows ?poco?
        %   return message. The basic KATCP included in our install
        %   libraries doesn't do this - have forgotten the small mod
        %   required

        progdev( roach, fw );   % Program Roach with defined fw

        roach_connected = 1;

        % As per Dr. Barott
        global_pause = 0.25; % Pause to enforce between writes

    catch
    end
end

% print a empty line for spacing
fprintf('\n');

% Select the SV
sv_1 = 9;
sv_2 = 15;
sv_3 = 23;
sv_4 = 30;

selected_bit_sv1 = SelectSatellite( sv_1 );
selected_bit_sv2 = SelectSatellite( sv_2 );
selected_bit_sv3 = SelectSatellite( sv_3 );
selected_bit_sv4 = SelectSatellite( sv_4 );

if( TESTING_IN_PROGRESS == 0)
    % Create Message Data
    message_signal = CreateMessageData( [ sv_1 sv_2 sv_3 sv_4 ] );
    message_signal_sv1 = message_signal( 1:1250 , : );
    message_signal_sv2 = message_signal( 1251:2500 , : );
    message_signal_sv3 = message_signal( 2501:3750 , : );
    message_signal_sv4 = message_signal( 3751:5000 , : );

    message_signal_bytes_1 = ConvertToBytesAndPad( message_signal_sv1 );
    repeated_message_signal_bytes_sv1 = message_signal_bytes_1(:);

    message_signal_bytes_2 = ConvertToBytesAndPad( message_signal_sv2 );
    repeated_message_signal_bytes_sv2 = message_signal_bytes_2(:);

    message_signal_bytes_3 = ConvertToBytesAndPad( message_signal_sv3 );
    repeated_message_signal_bytes_sv3 = message_signal_bytes_3(:);

    message_signal_bytes_4 = ConvertToBytesAndPad( message_signal_sv4 );
    repeated_message_signal_bytes_sv4 = message_signal_bytes_4(:);

    % Largest number of bytes that the bram can hold is 262144
    for count_i = 1:1:51
        repeated_message_signal_bytes_sv1 = [ repeated_message_signal_bytes_sv1 ; message_signal_bytes_1(:) ];
        repeated_message_signal_bytes_sv2 = [ repeated_message_signal_bytes_sv2 ; message_signal_bytes_2(:) ];
        repeated_message_signal_bytes_sv3 = [ repeated_message_signal_bytes_sv3 ; message_signal_bytes_3(:) ];
        repeated_message_signal_bytes_sv4 = [ repeated_message_signal_bytes_sv4 ; message_signal_bytes_4(:) ];
    end
    
elseif( TESTING_IN_PROGRESS == 1)
    
    test_message_sv1 = zeros(20,30);
    test_message_sv2 = zeros(20, 30);
    test_message_sv3 = zeros(2,30);
    test_message_sv4 = zeros(30,30);
    
    for count_first_10_rows = 1:10
        test_message_sv1( count_first_10_rows, : ) = str2bin_array( dec2bin( 1*(2^30) -1 , 30));
        
        if ( mod( count_first_10_rows, 2) == 0 )
            test_message_sv2( count_first_10_rows, :) = str2bin_array( dec2bin( 1*(2^30) -1 , 30));
        else
            test_message_sv2( count_first_10_rows, : ) = str2bin_array( dec2bin( 0 , 30));
        end
    end
    
    for count_last_10_rows = 10:20
        test_message_sv1( count_last_10_rows, : ) = str2bin_array( dec2bin( 0 , 30));
        if ( mod( count_last_10_rows, 2) == 1 )
            test_message_sv2( count_last_10_rows, : ) = str2bin_array( dec2bin( 1*(2^30) -1 , 30));
        else
            test_message_sv2( count_last_10_rows, : ) = str2bin_array( dec2bin( 0 , 30));
        end
    end
    
    test_message_sv1_bytes = ConvertToBytesAndPad( test_message_sv1 );
    repeated_message_signal_bytes_sv1 = test_message_sv1_bytes(:);
    
    test_message_sv2_bytes = ConvertToBytesAndPad( test_message_sv2 );
    repeated_message_signal_bytes_sv2 = test_message_sv2(:);
    
    for count_j = 1:floor(4128/ ( size(test_message_sv1_bytes, 1) * size( test_message_sv1_bytes, 2)))
        repeated_message_signal_bytes_sv1 = [ repeated_message_signal_bytes_sv1 ; test_message_sv1_bytes(:) ];
        repeated_message_signal_bytes_sv2 = [ repeated_message_signal_bytes_sv2 ; test_message_sv2_bytes(:) ];
    end
    
    test_message_sv3 ( 1, : ) = str2bin_array( dec2bin( 125812736, 30));
    test_message_sv3 ( 2, : ) = str2bin_array( dec2bin( 16383 , 30));
    
    test_message_sv3_bytes = ConvertToBytesAndPad(test_message_sv3);
    repeated_message_signal_bytes_sv3 = test_message_sv3_bytes(:);
    
    for count_j = 1:floor(4128/ ( size(test_message_sv3_bytes, 1) * size( test_message_sv3_bytes, 2)))
        repeated_message_signal_bytes_sv3 = [ repeated_message_signal_bytes_sv3 ; test_message_sv3_bytes(:) ];
    end
   
    
    for count_h = 1:30
        test_message_sv4 ( count_h , : ) = str2bin_array( dec2bin( 2^( count_h -1), 30) );
    end
    
    test_message_sv4_bytes = ConvertToBytesAndPad( test_message_sv4 );
    repeated_message_signal_bytes_sv4 = test_message_sv4_bytes(:);
    
    for count_j = 1:floor(4128/ ( size(test_message_sv4_bytes, 1) * size( test_message_sv4_bytes, 2)))
        repeated_message_signal_bytes_sv4 = [ repeated_message_signal_bytes_sv4 ; test_message_sv4_bytes(:) ];
    end
    
else
    error('Testing in progress bit is incorrect.');
end

% Clean up created file
delete *.alm;

% % Write to Selector Bit registers
% pause( global_pause );wordwrite( roach, 'G2_1_SV_SEL_REG1', (selected_bit_sv1(1,1) - 1)*(2^28) );
% pause( global_pause );wordwrite( roach, 'G2_1_SV_SEL_REG2', (selected_bit_sv1(1,2) - 1)*(2^28) );
% 
% pause( global_pause );wordwrite( roach, 'G2_2_SV_SEL_REG1', (selected_bit_sv2(1,1) - 1)*(2^28) );
% pause( global_pause );wordwrite( roach, 'G2_2_SV_SEL_REG2', (selected_bit_sv2(1,2) - 1)*(2^28) );
% 
% pause( global_pause );wordwrite( roach, 'G2_3_SV_SEL_REG1', (selected_bit_sv3(1,1) - 1)*(2^28) );
% pause( global_pause );wordwrite( roach, 'G2_3_SV_SEL_REG2', (selected_bit_sv3(1,2) - 1)*(2^28) );
% 
% pause( global_pause );wordwrite( roach, 'G2_4_SV_SEL_REG1', (selected_bit_sv4(1,1) - 1)*(2^28) );
% pause( global_pause );wordwrite( roach, 'G2_4_SV_SEL_REG2', (selected_bit_sv4(1,2) - 1)*(2^28) );
% Write to Selector Bit registers
pause( global_pause );wordwrite( roach, 'G2_1_SV_SEL_REG1', (selected_bit_sv1(1,1)-1));
pause( global_pause );wordwrite( roach, 'G2_1_SV_SEL_REG2', (selected_bit_sv1(1,2)-1));

pause( global_pause );wordwrite( roach, 'G2_2_SV_SEL_REG1', (selected_bit_sv2(1,1)-1));
pause( global_pause );wordwrite( roach, 'G2_2_SV_SEL_REG2', (selected_bit_sv2(1,2)-1));

pause( global_pause );wordwrite( roach, 'G2_3_SV_SEL_REG1', (selected_bit_sv3(1,1)-1));
pause( global_pause );wordwrite( roach, 'G2_3_SV_SEL_REG2', (selected_bit_sv3(1,2)-1));
%pause( global_pause );
pause( global_pause );wordwrite( roach, 'G2_4_SV_SEL_REG1', (selected_bit_sv4(1,1)-1));
pause( global_pause );wordwrite( roach, 'G2_4_SV_SEL_REG2', (selected_bit_sv4(1,2)-1));



% Ensure PRN Signal is turned ON ( Set:  PRN_SHUTDOWN_SWITCH to 0)
%   PRN_SHUTDOWN_SWITCH controls a MUX that selected between a constant
%   zero ( 0 ) or the PRN signal ouput.
% PRN_SHUTDOWN_SWITCH = 0 = PRN is ON
% PRN_SHUTDOWN_SWITCH = 1 = PRN is OFF
pause( global_pause );wordwrite( roach, 'PRN_SHUTDOWN_SWITCH' , 0);

% MESSAGE_SHUTDOWN_SWITCH = 0 = MESSAGE DATA ON
% MESSAGE_SHUTDOWN_SWITCH = 1 = MESSAGE DATA OFF
pause( global_pause );wordwrite( roach, 'MESSAGE_SHUTDOWN_SWITCH2', 0);

% MESSAGE_CLK_SELECT = 0 = CLK PRN CLOCK (1.023 MHZ)
% MESSAGE_CLK_SELECT = 1 = MESSAGE CLK (50 bps)
pause( global_pause );wordwrite( roach, 'MESSAGE_CLK_SELECT', 1);

% Set BRAM_DELAY_REG value.
pause( global_pause );wordwrite( roach, 'Message_Signal1_BRAM_DELAY_REG', 0 );
pause( global_pause );wordwrite( roach, 'Message_Signal2_BRAM_DELAY_REG', 0 );
pause( global_pause );wordwrite( roach, 'Message_Signal3_BRAM_DELAY_REG', 0 );
pause( global_pause );wordwrite( roach, 'Message_Signal4_BRAM_DELAY_REG', 0 );

% Controlable addition block logic.
%   Each of the 4 SVs can be controlled by setting the register
%   ADDITION_MUX_SELECT 1 or 2
%   Setting ADDITION_MUX_SELECT_:
%       0 = SV1, ON -- SV2, ON
%       1 = SV1, OFF -- SV2, ON
%       2 = SV1, ON -- SV2, OFF
%       3 = SV1, OFF -- SV2, OFF
pause( global_pause );wordwrite( roach, 'ADDITION_MUX_SELECT_1', 0 );
pause( global_pause );wordwrite( roach, 'ADDITION_MUX_SELECT_2', 0 );


% Reset GLOBAL_RESET to start transmission
%pause( global_pause ); wordwrite( roach, 'GLOBAL_RESET',0)
pause( global_pause );wordwrite( roach, 'DAC_dac_reset', 1 );
pause( global_pause );wordwrite( roach, 'DAC_dac_reset', 0 );

% Write the message signal bits to BRAM
%   Make sure that the message signal are in BYTES before being written
%   to the BRAM.
pause( global_pause );
write(roach, 'Message_Signal1_bram1', repeated_message_signal_bytes_sv1' );

pause( global_pause );
write(roach, 'Message_Signal2_bram1', repeated_message_signal_bytes_sv2' );

pause( global_pause );
write(roach, 'Message_Signal3_bram1', repeated_message_signal_bytes_sv3' );

pause( global_pause );
write(roach, 'Message_Signal4_bram1', repeated_message_signal_bytes_sv4' );
