%{  
   *example.m

   *This software was written by:
   *Thor Stærk Stenvang <thor.stark.stenvang@gmail.com> 
   *As long as you retain this notice you can do whatever you want with it

   *DESCRIPTION: Example of how to use the viscometerSerial class

   *Created on: Dec 2, 2015
%}

%Define Port
comPort = 'COM7';

%Crate viscometerSerial object
vs = viscometerSerial(comPort);

%Set speed for viscometer
vs.setSpeed(1000); %Please use values between 0-1000

%Set temperature
vs.setTemp(200);

%Read viscometer
[viscosity, fsr, shearRate, temp, cone] = vs.readViscometer;