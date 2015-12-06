%{  
   *viscometerSerial.m

   *This software was written by:
   *Thor Stærk Stenvang <thor.stark.stenvang@gmail.com> 
   *As long as you retain this notice you can do whatever you want with it

   *DESCRIPTION: MATLAB class for handling communication with brookfield
    CAP-2000+

   *Created on: Dec 1, 2015
%}
classdef viscometerSerial
    properties(GetAccess=private)
        serial_obj     %Serial port object
    end
    properties(Constant)
        %Communication parameters
        baud = 9600         %Baud Rate
        parity = 'none'     %Parity bit
        dataBits = 8        %Data bits
        stopBits = 1        %Stop Bits
        terminator = 'CR'   %Carriage return terminator
    end
    methods
        % Constructor
        function obj = viscometerSerial(port)
            % Creats the serial communication object
            obj.serial_obj = serial(port,'BaudRate',obj.baud,...
                'Parity',obj.parity ,'DataBits',obj.dataBits,...
                'StopBits',obj.stopBits,'Terminator',obj.terminator);
            % Try to open and close it
            fopen(obj.serial_obj);
            fclose(obj.serial_obj);
        end
        % Send data
        function sendCommand(obj,tx_data)
            %Write to device
            fwrite(obj.serial_obj,tx_data,'uint8')
        end
        % Receive data
        function r = receiveRespons(obj,size)
            %Read
            [r, count] = fread(obj.serial_obj,size);
            if count ~= size
                error('Wrong number of data');
            end 
        end
        %Sends Data and get respons
        function rx_data = sendReceive(obj,tx_data,rx_size)
            fopen(obj.serial_obj);
            obj.sendCommand(tx_data);
            rx_data = obj.receiveRespons(rx_size);
            fclose(obj.serial_obj);
            %Check respons
            if rx_data(1) ~= tx_data(1)
                error('Received wrong msg')
            end
            %TODO: Use information to something!
        end
        % Class function for setting speed of viscometer
        function setSpeed(obj,RPMd)
            Command = 86; %86 = V
            %Convert from decimal to a 3 digit hexidecimal string
            speedX = dec2hex(RPMd,3);
            t =[Command speedX 13];
            %Send data and receive respons
            r = obj.sendReceive(t,4);
        end
        % Class function for setting Temperature of viscometer
        function setTemp(obj,tempd)
            Command = 84; %86 = T
            %Convert from decimal to a 3 digit hexidecimal string
            tempx = dec2hex(tempd,3);
            t =[Command tempx 13]; %13=CR
            %Send data and receive respons
            r = obj.sendReceive(t,4);
        end
        
        %Read from viscometer
        function [v, f, r, t, c] = readViscometer(obj)
            Command = 82; %82 = R
            tx =[Command 13];
            %Send data and receive respons
            rx = obj.sendReceive(tx,24);
            %rx(1)       command id
            %rx(2:7)     viscosity
            %rx(8:11)    FSR
            %rx(12:17)   shear rate
            %rx(18:20)   temperatur
            %rx(21:22)   cone
            %rx(23:24)   status
            %rx(25)      CR
            %v = str2num(sprintf('%d%d%d',rx(2),rx(3),rx(4)));
            v = rx
        end
        
        %Identify viscometer
        
        
        function close(obj)
            fclose(obj.serial_obj);
            delete(obj.serial_obj)
        end
    end
end