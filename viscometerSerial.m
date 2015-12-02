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
        %Sends Data and gets repons
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
        function setSpeed(obj,RPM)
            Command = 86; %86 = V
            t =[Command floor(RPM/255) mod(RPM,255) 13];
            %Send data and receive respons
            r = obj.sendReceive(t,3)
        end
        % Class function for setting Temperature of viscometer
        function setTemp(obj,temp)
            Command = 84; %86 = T
            t =[Command floor(temp/255) mod(temp,255) 13]; %13=CR
            %Send data and receive respons
            r = obj.sendReceive(t,3)
        end
        
        %Read from viscometer
        function [v, f, r, t, c] = readViscometer(obj)
            Command = 82; %82 = R
            tx =[Command 13];
            %Send data and receive respons
            rx = obj.sendReceive(tx,14);
            %r(1)       command id
            %r(2:4)     viscosity
            %r(5:6)     FSR
            %r(7:9)     shear rate
            %r(10:11)   temperatur
            %r(12)      cone
            %r(13)      status
            %r(14)      CR
            v = str2num(sprintf('%d%d%d',rx(2),rx(3),rx(4)));
            f = str2num(sprintf('%d%d',rx(5),rx(6)));
            r = str2num(sprintf('%d%d%d',rx(7),rx(8),rx(9)));
            t = str2num(sprintf('%d%d',rx(10),rx(11)));
            c = str2num(sprintf('%d',rx(12)));
        end
        
        %Identify viscometer
        
        
        function close(obj)
            fclose(obj.serial_obj);
            delete(obj.serial_obj)
        end
    end
end