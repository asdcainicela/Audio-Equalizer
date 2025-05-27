classdef AppMatlab < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        SaveRecordButton              matlab.ui.control.Button
        SaveEqualizedButton           matlab.ui.control.Button
        FindAudioButton               matlab.ui.control.Button
        Label_B916                    matlab.ui.control.Label
        Label_B915                    matlab.ui.control.Label
        Label_B914                    matlab.ui.control.Label
        Label_B913                    matlab.ui.control.Label
        Label_B98                     matlab.ui.control.Label
        Label_B97                     matlab.ui.control.Label
        Label_B96                     matlab.ui.control.Label
        Label_B95                     matlab.ui.control.Label
        Label_B94                     matlab.ui.control.Label
        Label_B93                     matlab.ui.control.Label
        Label_B86                     matlab.ui.control.Label
        Label_B85                     matlab.ui.control.Label
        Label_B81                     matlab.ui.control.Label
        Label_B64                     matlab.ui.control.Label
        Label_B63                     matlab.ui.control.Label
        Label_B54                     matlab.ui.control.Label
        Label_B53                     matlab.ui.control.Label
        Label_B32                     matlab.ui.control.Label
        Label_B22                     matlab.ui.control.Label
        Label_B12                     matlab.ui.control.Label
        Image_check                   matlab.ui.control.Image
        Image_warning                 matlab.ui.control.Image
        Slider_B32                    matlab.ui.control.Slider
        Slider_B22                    matlab.ui.control.Slider
        Slider_B64                    matlab.ui.control.Slider
        Slider_B63                    matlab.ui.control.Slider
        Slider_B54                    matlab.ui.control.Slider
        Slider_B53                    matlab.ui.control.Slider
        Slider_B12                    matlab.ui.control.Slider
        LabelMin                      matlab.ui.control.Label
        LabelMax                      matlab.ui.control.Label
        AUDIOEQUALIZERLabel           matlab.ui.control.Label
        Image_record                  matlab.ui.control.Image
        Slider_B916                   matlab.ui.control.Slider
        Slider_B915                   matlab.ui.control.Slider
        Slider_B914                   matlab.ui.control.Slider
        Slider_B913                   matlab.ui.control.Slider
        Slider_B86                    matlab.ui.control.Slider
        Slider_B85                    matlab.ui.control.Slider
        Slider_B98                    matlab.ui.control.Slider
        Slider_B97                    matlab.ui.control.Slider
        Slider_B96                    matlab.ui.control.Slider
        Slider_B95                    matlab.ui.control.Slider
        Slider_B94                    matlab.ui.control.Slider
        Slider_B93                    matlab.ui.control.Slider
        BandsSwitch                   matlab.ui.control.Switch
        BandsSwitchLabel              matlab.ui.control.Label
        EqualizeAudioButton           matlab.ui.control.Button
        PlayEqualizedButton           matlab.ui.control.Button
        PlayOriginalButton            matlab.ui.control.Button
        RecordAudioButton             matlab.ui.control.Button
        DropDownOutput                matlab.ui.control.DropDown
        SeleccionaSalidadeaudioLabel  matlab.ui.control.Label
        DropDownInput                 matlab.ui.control.DropDown
        IntradadeaudioLabel           matlab.ui.control.Label
        Txt3                          matlab.ui.control.Label
        Txt2                          matlab.ui.control.Label
        Txt1                          matlab.ui.control.Label
        Txt4                          matlab.ui.control.Label
        Slider_B81                    matlab.ui.control.Slider
        UIAxes                        matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        Fs double = 48000;      % Frecuencia de muestreo
        Tc double = 5.4613;     % Tiempo de captura
        r double = 16;          % Bits por muestra
        Nc double = 1;          % Número de canales
        LoD double              % Filtro de descomposición bajo
        HiD double              % Filtro de descomposición alto
        LoR double              % Filtro de reconstrucción bajo
        HiR double              % Filtro de reconstrucción alto

        audioGrabadoOriginal double = []; % Para almacenar la grabación
        audioEcualizado double = []; % Audio luego de ecualización
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.Image_record.Visible = 'off';
            app.Image_check.Visible = 'off';  
            app.Image_warning.Visible = 'off';  
            app.UIAxes.Visible = 'off'; % Opcional: oculta todo el eje
            % Inicializar filtros (solo 1 vez)
            [app.LoD, app.HiD, app.LoR, app.HiR] = wfilters('db25');
            %------ seleccion de micro y salida
            info = audiodevinfo;
            
            entradaList = info.input;
            salidaList = info.output;
            
            % Manejar si es struct simple o array
            if isempty(entradaList)
                nombresEntrada = {'-1 (default)'};
            elseif isstruct(entradaList)
                if numel(entradaList) == 1
                    nombresEntrada = {sprintf('[%d] %s', entradaList.ID, entradaList.Name)};
                    nombresEntrada = [{' -1 (default)'} nombresEntrada];
                else
                    nombresEntrada = cell(1,numel(entradaList)+1);
                    nombresEntrada{1} = '-1 (default)';
                    for i=1:numel(entradaList)
                        nombresEntrada{i+1} = sprintf('[%d] %s', entradaList(i).ID, entradaList(i).Name);
                    end
                end
            else
                nombresEntrada = {'-1 (default)'};
            end
            
            if isempty(salidaList)
                nombresSalida = {'-1 (default)'};
            elseif isstruct(salidaList)
                if numel(salidaList) == 1
                    nombresSalida = {sprintf('[%d] %s', salidaList.ID, salidaList.Name)};
                    nombresSalida = [{' -1 (default)'} nombresSalida];
                else
                    nombresSalida = cell(1,numel(salidaList)+1);
                    nombresSalida{1} = '-1 (default)';
                    for i=1:numel(salidaList)
                        nombresSalida{i+1} = sprintf('[%d] %s', salidaList(i).ID, salidaList(i).Name);
                    end
                end
            else
                nombresSalida = {'-1 (default)'};
            end
            
            % Asignar a dropdowns
            app.DropDownInput.Items = nombresEntrada;
            app.DropDownInput.Value = nombresEntrada{1};
            
            app.DropDownOutput.Items = nombresSalida;
            app.DropDownOutput.Value = nombresSalida{1}; 
        end

        % Button pushed function: RecordAudioButton
        function RecordAudioButtonPushed(app, event)
             % Obtener el ID de dispositivo de entrada del dropdown Input
            strEntrada = app.DropDownInput.Value; % ej: '[1] Mic XYZ' o '-1 (default)'
            if startsWith(strEntrada, '[')
                % Extraer número dentro de corchetes
                idEntrada = sscanf(strEntrada, '[%d]');
            else
                idEntrada = -1; % default
            end
            
            % Similar para salida si la necesitas
            % strSalida = app.DropDownOutput.Value;
            % idSalida = ... (lo mismo si fuera necesario)
            
            % Crear el audiorecorder con propiedades de la app
            grabadora = audiorecorder(app.Fs, app.r, app.Nc, idEntrada);
               
            app.Image_record.Visible = 'on';                % Mostrar imagen
            % Mostrar mensaje de grabación
            disp('Grabando...');
            
            % Iniciar grabación
            record(grabadora, app.Tc);
            
            % Esperar el tiempo de grabación más un segundo extra
            pause(app.Tc + 1);
            app.Image_record.Visible = 'off';                % Mostrar imagen
            
            % Obtener datos de audio
            x = getaudiodata(grabadora, 'double');
            
            disp('Grabación finalizada.');
            
            % Opcional: mostrar duración o info del audio capturado
            fprintf('Se grabaron %.2f segundos de audio.\n', app.Tc);
             
            % Guardar el audio grabado en la propiedad para uso posterior
            app.audioGrabadoOriginal = x;
            
            %  Usa transformada de Fourier para análisis o visualización
             [X,FREC1] = fourier(x, app.Fs);
        
            %------------------
             app.UIAxes.Visible = 'on';
            % Limpia el UIAxes
            cla(app.UIAxes);
            
            % Grafica el espectro original
            plot(app.UIAxes, FREC1, abs(X), 'b-', 'LineWidth', 1.5);
            hold(app.UIAxes, 'on'); 
            hold(app.UIAxes, 'off');
            
            % Etiquetas y leyenda
            xlabel(app.UIAxes, 'Frecuencia (Hz)');
            ylabel(app.UIAxes, 'Magnitud');
            title(app.UIAxes, 'Espectro de la señal original y ecualizada');
            legend(app.UIAxes, {'Original', 'Ecualizada'}, 'Location', 'northeast');
            grid(app.UIAxes, 'on');
     
        end

        % Button pushed function: PlayOriginalButton
        function PlayOriginalButtonPushed(app, event)
            % Verificar si hay audio grabado
            if isempty(app.audioGrabadoOriginal)
                uialert(app.UIFigure, 'No hay audio grabado.', 'Error');
                return;
            end
            
            % Obtener el ID del dispositivo de salida desde el dropdown
            strSalida = app.DropDownOutput.Value; % ejemplo: "[4] Altavoces Realtek"
            
            if startsWith(strSalida, '[')
                idSalida = sscanf(strSalida, '[%d]');
            else
                idSalida = -1; % valor por defecto
            end
            
            % Crear el objeto audioplayer
            try
                player = audioplayer(app.audioGrabadoOriginal, app.Fs, app.r, idSalida);
                playblocking(player);
                disp('Reproduciendo audio...');
            catch ME
                uialert(app.UIFigure, sprintf('Error al reproducir: %s', ME.message), 'Error');
            end 
            
        end

        % Value changed function: BandsSwitch
        function BandsSwitchValueChanged(app, event)
            val = app.BandsSwitch.Value;
            disp(['Valor actual del switch: "', val, '"']);
            
            % Arreglos de sliders y labels
            sliders = [app.Slider_B12, app.Slider_B22, app.Slider_B32, app.Slider_B53, app.Slider_B54, ...
                       app.Slider_B63, app.Slider_B64, app.Slider_B81, app.Slider_B85, app.Slider_B86, ...
                       app.Slider_B93, app.Slider_B94, app.Slider_B95, app.Slider_B96, app.Slider_B97, ...
                       app.Slider_B98, app.Slider_B913, app.Slider_B914, app.Slider_B915, app.Slider_B916];
            
            Labels = [app.Label_B12, app.Label_B22, app.Label_B32, app.Label_B53, app.Label_B54, ...
                      app.Label_B63, app.Label_B64, app.Label_B81, app.Label_B85, app.Label_B86, ...
                      app.Label_B93, app.Label_B94, app.Label_B95, app.Label_B96, app.Label_B97, ...
                      app.Label_B98, app.Label_B913, app.Label_B914, app.Label_B915, app.Label_B916];
            
            % Definir límites según switch
            if strcmp(val, '[12, -12]')
                newLimits = [-12 12];
                app.LabelMax.Text = '12';
                app.LabelMin.Text = '-12';
            else
                newLimits = [-6 6];
                app.LabelMax.Text = '6';
                app.LabelMin.Text = '-6';
            end
            
            % Bandera para detectar si hubo algún ajuste
            huboCambio = false;
            
            % Aplicar nuevos límites y ajustar valores
            for k = 1:length(sliders)
                sliders(k).Limits = newLimits;
                
                % Guardamos valor anterior para detectar cambios
                valorAnterior = sliders(k).Value;
                
                % Forzar valor dentro del rango
                if valorAnterior < newLimits(1)
                    sliders(k).Value = newLimits(1);
                    huboCambio = true;
                elseif valorAnterior > newLimits(2)
                    sliders(k).Value = newLimits(2);
                    huboCambio = true;
                end
                
                % Actualizar label con el valor del slider
                Labels(k).Text = sprintf('%.1f dB', sliders(k).Value);
            end
            
            % Mostrar/ocultar imágenes según si hubo cambio
            if huboCambio
                app.Image_warning.Visible = 'on';
                app.Image_check.Visible = 'off';
            %else
             %   app.Image_warning.Visible = 'off';
              %  app.Image_check.Visible = 'on';
            end
            
            disp('Nuevos límites:')
            disp(newLimits)
        end

        % Button pushed function: EqualizeAudioButton
        function EqualizeAudioButtonPushed(app, event)
            app.Image_warning.Visible = 'off'; 
            app.Image_check.Visible = 'on'; 
            if isempty(app.audioGrabadoOriginal)
                uialert(app.UIFigure, 'No hay audio grabado para ecualizar.', 'Error');
            return;
            end
            
            x = app.audioGrabadoOriginal;
            %Fs = app.Fs; % frecuencia de muestreo
            T= 1/app.Fs; % periodo de muestreo
            t = (0:length(x)-1)/app.Fs;
            n = 0:length(x)-1;
            
            senalActual = x';
            
            % Filtros cargados en startupFcn
            %LoD = app.LoD;
            %HiD = app.HiD;
            %LoR = app.LoR;
            %HiR = app.HiR;
            
            % Descomposición wavelet niveles 1 a 9
            [x11, x12] = dwwt(senalActual, app.LoD, app.HiD); % Nivel 1
            [x21, x22] = dwwt(x11, app.LoD, app.HiD);         % Nivel 2
            [x31, x32] = dwwt(x21, app.LoD, app.HiD);         % Nivel 3
            [x41, x42] = dwwt(x31, app.LoD, app.HiD);         % Nivel 4
            [x51, x52] = dwwt(x41, app.LoD, app.HiD);         % Nivel 5
            [x53, x54] = dwwt(x42, app.LoD, app.HiD);
            [x61, x62] = dwwt(x51, app.LoD, app.HiD);         % Nivel 6
            [x63, x64] = dwwt(x52, app.LoD, app.HiD);
            [x71, x72] = dwwt(x61, app.LoD, app.HiD);         % Nivel 7
            [x73, x74] = dwwt(x62, app.LoD, app.HiD);
            [x81, x82] = dwwt(x71, app.LoD, app.HiD);         % Nivel 8
            [x83, x84] = dwwt(x72, app.LoD, app.HiD);
            [x85, x86] = dwwt(x73, app.LoD, app.HiD);
            [x87, x88] = dwwt(x74, app.LoD, app.HiD);
            [x93, x94] = dwwt(x82, app.LoD, app.HiD);         % Nivel 9
            [x95, x96] = dwwt(x83, app.LoD, app.HiD);
            [x97, x98] = dwwt(x84, app.LoD, app.HiD);
            [x913, x914] = dwwt(x87, app.LoD, app.HiD);
            [x915, x916] = dwwt(x88, app.LoD, app.HiD);
             
            % Obtén las ganancias de los sliders en dB
            ganancia_B916_dB = app.Slider_B916.Value;
            ganancia_B915_dB = app.Slider_B915.Value;
            ganancia_B914_dB = app.Slider_B914.Value;
            ganancia_B913_dB = app.Slider_B913.Value;
            ganancia_B98_dB  = app.Slider_B98.Value;
            ganancia_B97_dB  = app.Slider_B97.Value;
            ganancia_B96_dB  = app.Slider_B96.Value;
            ganancia_B95_dB  = app.Slider_B95.Value;
            ganancia_B94_dB  = app.Slider_B94.Value;
            ganancia_B93_dB  = app.Slider_B93.Value; 
            ganancia_B86_dB  = app.Slider_B86.Value;
            ganancia_B85_dB  = app.Slider_B85.Value; 
            ganancia_B81_dB  = app.Slider_B81.Value;
            ganancia_B64_dB  = app.Slider_B64.Value;
            ganancia_B63_dB  = app.Slider_B63.Value;
            ganancia_B54_dB  = app.Slider_B54.Value;
            ganancia_B53_dB  = app.Slider_B53.Value;
            ganancia_B32_dB  = app.Slider_B32.Value;
            ganancia_B22_dB  = app.Slider_B22.Value;
            ganancia_B12_dB  = app.Slider_B12.Value;
            
            % Convierto dB a ganancia lineal
            gan_linealB916 = 10^(ganancia_B916_dB / 20);
            gan_linealB915 = 10^(ganancia_B915_dB / 20);
            gan_linealB914 = 10^(ganancia_B914_dB / 20);
            gan_linealB913 = 10^(ganancia_B913_dB / 20);
            gan_linealB98  = 10^(ganancia_B98_dB / 20);
            gan_linealB97  = 10^(ganancia_B97_dB / 20);
            gan_linealB96  = 10^(ganancia_B96_dB / 20);
            gan_linealB95  = 10^(ganancia_B95_dB / 20);
            gan_linealB94  = 10^(ganancia_B94_dB / 20);
            gan_linealB93  = 10^(ganancia_B93_dB / 20);
            gan_linealB86  = 10^(ganancia_B86_dB / 20);
            gan_linealB85  = 10^(ganancia_B85_dB / 20);
            gan_linealB81  = 10^(ganancia_B81_dB / 20);
            gan_linealB64  = 10^(ganancia_B64_dB / 20);
            gan_linealB63  = 10^(ganancia_B63_dB / 20);
            gan_linealB54  = 10^(ganancia_B54_dB / 20);
            gan_linealB53  = 10^(ganancia_B53_dB / 20);
            gan_linealB32  = 10^(ganancia_B32_dB / 20);
            gan_linealB22  = 10^(ganancia_B22_dB / 20);
            gan_linealB12  = 10^(ganancia_B12_dB / 20);
            
            % Actualizo variables ganancia_Bxx con valor lineal
            ganancia_B916 = gan_linealB916;
            ganancia_B915 = gan_linealB915;
            ganancia_B914 = gan_linealB914;
            ganancia_B913 = gan_linealB913;
            ganancia_B98  = gan_linealB98;
            ganancia_B97  = gan_linealB97;
            ganancia_B96  = gan_linealB96;
            ganancia_B95  = gan_linealB95;
            ganancia_B94  = gan_linealB94;
            ganancia_B93  = gan_linealB93;
            ganancia_B86  = gan_linealB86;
            ganancia_B85  = gan_linealB85;
            ganancia_B81  = gan_linealB81;
            ganancia_B64  = gan_linealB64;
            ganancia_B63  = gan_linealB63;
            ganancia_B54  = gan_linealB54;
            ganancia_B53  = gan_linealB53;
            ganancia_B32  = gan_linealB32;
            ganancia_B22  = gan_linealB22;
            ganancia_B12  = gan_linealB12; 

            % Aplica las ganancias a las subbandas
            x916 = x916 * ganancia_B916;
            x915 = x915 * ganancia_B915;
            x914 = x914 * ganancia_B914;
            x913 = x913 * ganancia_B913;
            x86  = x86  * ganancia_B86;
            x85  = x85  * ganancia_B85;
            x98  = x98  * ganancia_B98;
            x97  = x97  * ganancia_B97;
            x96  = x96  * ganancia_B96;
            x95  = x95  * ganancia_B95;
            x94  = x94  * ganancia_B94;
            x93  = x93  * ganancia_B93;
            x81  = x81  * ganancia_B81; 
            x64  = x64  * ganancia_B64;
            x63  = x63  * ganancia_B63;
            x54  = x54  * ganancia_B54;
            x53  = x53  * ganancia_B53;
            x32  = x32  * ganancia_B32;
            x22  = x22  * ganancia_B22;
            x12  = x12  * ganancia_B12;
             
            % --- Reconstrucción desde nivel 9 hacia el nivel 1 ---
            
            % Reconstrucción parcial Nivel 9
            x82r = rwwt(x93, x94, app.LoR, app.HiR);
            x83r = rwwt(x95, x96, app.LoR, app.HiR);
            x84r = rwwt(x97, x98, app.LoR, app.HiR);
            x87r = rwwt(x913, x914, app.LoR, app.HiR);
            x88r = rwwt(x915, x916, app.LoR, app.HiR);
            
            % Ajuste de tamaño (parche)
            x82r(end+1) = x82(end);
            x83r(end+1) = x83(end);
            x84r(end+1) = x84(end);
            x87r(end+1) = x87(end);
            x88r(end+1) = x88(end);
            
            % Reconstrucción Nivel 8
            x71r = rwwt(x81, x82r, app.LoR, app.HiR);
            x72r = rwwt(x83r, x84r, app.LoR, app.HiR);
            x73r = rwwt(x85, x86, app.LoR, app.HiR);
            x74r = rwwt(x87r, x88r, app.LoR, app.HiR);
            
            x71r(end+1) = x71(end);
            x72r(end+1) = x72(end);
            x73r(end+1) = x73(end);
            x74r(end+1) = x74(end);
            
            % Reconstrucción Nivel 7
            x61r = rwwt(x71r, x72r, app.LoR, app.HiR);
            x62r = rwwt(x73r, x74r, app.LoR, app.HiR);
            
            x61r(end+1) = x61(end);
            x62r(end+1) = x62(end);
            
            % Reconstrucción Nivel 6
            x51r = rwwt(x61r, x62r, app.LoR, app.HiR);
            x52r = rwwt(x63, x64, app.LoR, app.HiR);
            
            x51r(end+1) = x51(end);
            x52r(end+1) = x52(end);
            
            % Reconstrucción Nivel 5
            x41r = rwwt(x51r, x52r, app.LoR, app.HiR);
            x42r = rwwt(x53, x54, app.LoR, app.HiR);
            
            x41r(end+1) = x41(end);
            x42r(end+1) = x42(end);
            
            % Reconstrucción Nivel 4
            x31r = rwwt(x41r, x42r, app.LoR, app.HiR);
            
            x31r(end+1) = x31(end);
            
            % Reconstrucción Nivel 3
            x21r = rwwt(x31r, x32, app.LoR, app.HiR);
            
            x21r(end+1) = x21(end);
            
            % Reconstrucción Nivel 2
            x11r = rwwt(x21r, x22, app.LoR, app.HiR);
            
            x11r(end+1) = x11(end);
            
            % ------------Reconstrucción Nivel 1: señal reconstruida
            xr = rwwt(x11r, x12, app.LoR, app.HiR);
            
            % Ajusta tamaño para que coincida con señal original
            %------parche start
            xr = xr(1:length(x)); 
            % --- parche old
            
            %  Usa transformada de Fourier para análisis o visualización
            [X,FREC1] = fourier(x, app.Fs);
            [XR,~] = fourier(xr, app.Fs);   
            app.audioEcualizado = xr;
            
            NX=length(x);
            nx=0:NX-1;
            
            %------------------
            % Limpia el UIAxes
            cla(app.UIAxes);
            
            % Grafica el espectro original
            plot(app.UIAxes, FREC1, abs(X), 'b-', 'LineWidth', 1.5);
            hold(app.UIAxes, 'on');
            
            % Grafica el espectro ecualizado
            plot(app.UIAxes, FREC1, abs(XR), 'r-', 'LineWidth', 1.5);
            
            hold(app.UIAxes, 'off');
            
            % Etiquetas y leyenda
            xlabel(app.UIAxes, 'Frecuencia (Hz)');
            ylabel(app.UIAxes, 'Magnitud');
            title(app.UIAxes, 'Espectro de la señal original y ecualizada');
            legend(app.UIAxes, {'Original', 'Ecualizada'}, 'Location', 'northeast');
            grid(app.UIAxes, 'on');
        end

        % Button pushed function: PlayEqualizedButton
        function PlayEqualizedButtonPushed(app, event)
            if isempty(app.audioEcualizado)
                uialert(app.UIFigure, 'Primero debes ecualizar el audio.', 'Error');
                return;
            end
            
            strSalida = app.DropDownOutput.Value;
            if startsWith(strSalida, '[')
                idSalida = sscanf(strSalida, '[%d]');
            else
                idSalida = -1;
            end
            
            try
                player = audioplayer(app.audioEcualizado, app.Fs, app.r, idSalida);
                playblocking(player);
                disp('Reproduciendo audio ecualizado...');
            catch ME
                uialert(app.UIFigure, sprintf('Error al reproducir: %s', ME.message), 'Error');
            end
        end

        % Value changing function: Slider_B12
        function Slider_B12ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B12.Text = num2str(event.Value, '%.1fdB');
            fprintf('El valor del slider B12 es: %.2f dB\n', event.Value);
        end

        % Value changing function: Slider_B32
        function Slider_B32ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B32.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B22
        function Slider_B22ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B22.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B64
        function Slider_B64ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B64.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B63
        function Slider_B63ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B63.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B54
        function Slider_B54ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B54.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B53
        function Slider_B53ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B53.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B916
        function Slider_B916ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B916.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B915
        function Slider_B915ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B915.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B914
        function Slider_B914ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B914.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B913
        function Slider_B913ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B913.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B86
        function Slider_B86ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B86.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B85
        function Slider_B85ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B85.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B98
        function Slider_B98ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B98.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B97
        function Slider_B97ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B97.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B96
        function Slider_B96ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B96.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B95
        function Slider_B95ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B95.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B94
        function Slider_B94ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B94.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B93
        function Slider_B93ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B93.Text = num2str(event.Value, '%.1fdB');
        end

        % Value changing function: Slider_B81
        function Slider_B81ValueChanging(app, event)
            app.Image_warning.Visible = 'on'; 
            app.Image_check.Visible = 'off'; 
            app.Label_B81.Text = num2str(event.Value, '%.1fdB');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.9412 0.9608 0.9804];
            app.UIFigure.Position = [100 100 1401 753];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [574 31 589 307];

            % Create Slider_B81
            app.Slider_B81 = uislider(app.UIFigure);
            app.Slider_B81.Limits = [-6 6];
            app.Slider_B81.MajorTicks = [];
            app.Slider_B81.MajorTickLabels = {''};
            app.Slider_B81.Orientation = 'vertical';
            app.Slider_B81.ValueChangingFcn = createCallbackFcn(app, @Slider_B81ValueChanging, true);
            app.Slider_B81.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B81.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B81.Position = [516 402 3 150];

            % Create Txt4
            app.Txt4 = uilabel(app.UIFigure);
            app.Txt4.FontName = 'Verdana';
            app.Txt4.FontSize = 15;
            app.Txt4.Position = [1063 721 87 22];
            app.Txt4.Text = 'Fs= 48000';

            % Create Txt1
            app.Txt1 = uilabel(app.UIFigure);
            app.Txt1.FontName = 'Verdana';
            app.Txt1.FontSize = 15;
            app.Txt1.Position = [1167 721 91 22];
            app.Txt1.Text = 'Tc= 5.4613';

            % Create Txt2
            app.Txt2 = uilabel(app.UIFigure);
            app.Txt2.FontName = 'Verdana';
            app.Txt2.FontSize = 15;
            app.Txt2.Position = [1274 721 48 22];
            app.Txt2.Text = 'r= 16';

            % Create Txt3
            app.Txt3 = uilabel(app.UIFigure);
            app.Txt3.FontName = 'Verdana';
            app.Txt3.FontSize = 15;
            app.Txt3.Position = [1341 721 51 22];
            app.Txt3.Text = 'Nc= 1';

            % Create IntradadeaudioLabel
            app.IntradadeaudioLabel = uilabel(app.UIFigure);
            app.IntradadeaudioLabel.BackgroundColor = [0.9412 0.9608 0.9804];
            app.IntradadeaudioLabel.HorizontalAlignment = 'right';
            app.IntradadeaudioLabel.FontName = 'Verdana';
            app.IntradadeaudioLabel.FontSize = 16;
            app.IntradadeaudioLabel.FontColor = [0.302 0.302 0.302];
            app.IntradadeaudioLabel.Position = [130 633 140 22];
            app.IntradadeaudioLabel.Text = 'Input de audio   ';

            % Create DropDownInput
            app.DropDownInput = uidropdown(app.UIFigure);
            app.DropDownInput.FontName = 'Verdana';
            app.DropDownInput.FontSize = 16;
            app.DropDownInput.FontColor = [0.302 0.302 0.302];
            app.DropDownInput.BackgroundColor = [0.9412 0.9608 0.9804];
            app.DropDownInput.Position = [285 632 179 23];

            % Create SeleccionaSalidadeaudioLabel
            app.SeleccionaSalidadeaudioLabel = uilabel(app.UIFigure);
            app.SeleccionaSalidadeaudioLabel.BackgroundColor = [0.9412 0.9608 0.9804];
            app.SeleccionaSalidadeaudioLabel.HorizontalAlignment = 'right';
            app.SeleccionaSalidadeaudioLabel.FontName = 'Verdana';
            app.SeleccionaSalidadeaudioLabel.FontSize = 17;
            app.SeleccionaSalidadeaudioLabel.FontColor = [0.302 0.302 0.302];
            app.SeleccionaSalidadeaudioLabel.Position = [129 598 143 23];
            app.SeleccionaSalidadeaudioLabel.Text = 'Output de audio';

            % Create DropDownOutput
            app.DropDownOutput = uidropdown(app.UIFigure);
            app.DropDownOutput.FontName = 'Verdana';
            app.DropDownOutput.FontSize = 16;
            app.DropDownOutput.FontColor = [0.302 0.302 0.302];
            app.DropDownOutput.BackgroundColor = [0.9412 0.9608 0.9804];
            app.DropDownOutput.Position = [287 598 179 23];

            % Create RecordAudioButton
            app.RecordAudioButton = uibutton(app.UIFigure, 'push');
            app.RecordAudioButton.ButtonPushedFcn = createCallbackFcn(app, @RecordAudioButtonPushed, true);
            app.RecordAudioButton.BackgroundColor = [0.1608 0.4706 0.6706];
            app.RecordAudioButton.FontName = 'Verdana';
            app.RecordAudioButton.FontSize = 18;
            app.RecordAudioButton.FontColor = [1 1 1];
            app.RecordAudioButton.Position = [53 262 185 52];
            app.RecordAudioButton.Text = 'Record Audio';

            % Create PlayOriginalButton
            app.PlayOriginalButton = uibutton(app.UIFigure, 'push');
            app.PlayOriginalButton.ButtonPushedFcn = createCallbackFcn(app, @PlayOriginalButtonPushed, true);
            app.PlayOriginalButton.BackgroundColor = [0.9412 0.9608 0.9804];
            app.PlayOriginalButton.FontName = 'Verdana';
            app.PlayOriginalButton.FontSize = 18;
            app.PlayOriginalButton.Position = [1203 261 149 54];
            app.PlayOriginalButton.Text = 'Play Original';

            % Create PlayEqualizedButton
            app.PlayEqualizedButton = uibutton(app.UIFigure, 'push');
            app.PlayEqualizedButton.ButtonPushedFcn = createCallbackFcn(app, @PlayEqualizedButtonPushed, true);
            app.PlayEqualizedButton.BackgroundColor = [0.9412 0.9608 0.9804];
            app.PlayEqualizedButton.FontName = 'Verdana';
            app.PlayEqualizedButton.FontSize = 18;
            app.PlayEqualizedButton.Position = [1203 102 150 54];
            app.PlayEqualizedButton.Text = 'Play Equalized';

            % Create EqualizeAudioButton
            app.EqualizeAudioButton = uibutton(app.UIFigure, 'push');
            app.EqualizeAudioButton.ButtonPushedFcn = createCallbackFcn(app, @EqualizeAudioButtonPushed, true);
            app.EqualizeAudioButton.BackgroundColor = [0.9373 0.3882 0.4078];
            app.EqualizeAudioButton.FontName = 'Verdana';
            app.EqualizeAudioButton.FontSize = 18;
            app.EqualizeAudioButton.FontColor = [1 1 1];
            app.EqualizeAudioButton.Position = [48 53 197 52];
            app.EqualizeAudioButton.Text = 'Equalize Audio';

            % Create BandsSwitchLabel
            app.BandsSwitchLabel = uilabel(app.UIFigure);
            app.BandsSwitchLabel.BackgroundColor = [0.9412 0.9608 0.9804];
            app.BandsSwitchLabel.HorizontalAlignment = 'center';
            app.BandsSwitchLabel.FontName = 'Verdana';
            app.BandsSwitchLabel.FontSize = 17;
            app.BandsSwitchLabel.FontColor = [0.5294 0.1216 0.0471];
            app.BandsSwitchLabel.Position = [914 630 57 23];
            app.BandsSwitchLabel.Text = 'Bands';

            % Create BandsSwitch
            app.BandsSwitch = uiswitch(app.UIFigure, 'slider');
            app.BandsSwitch.Items = {'[-6, 6]', '[12, -12]'};
            app.BandsSwitch.ValueChangedFcn = createCallbackFcn(app, @BandsSwitchValueChanged, true);
            app.BandsSwitch.FontName = 'Verdana';
            app.BandsSwitch.FontSize = 17;
            app.BandsSwitch.Position = [920 598 45 20];
            app.BandsSwitch.Value = '[-6, 6]';

            % Create Slider_B93
            app.Slider_B93 = uislider(app.UIFigure);
            app.Slider_B93.Limits = [-6 6];
            app.Slider_B93.MajorTicks = [];
            app.Slider_B93.MajorTickLabels = {''};
            app.Slider_B93.Orientation = 'vertical';
            app.Slider_B93.ValueChangingFcn = createCallbackFcn(app, @Slider_B93ValueChanging, true);
            app.Slider_B93.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B93.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B93.Position = [723 402 3 150];

            % Create Slider_B94
            app.Slider_B94 = uislider(app.UIFigure);
            app.Slider_B94.Limits = [-6 6];
            app.Slider_B94.MajorTicks = [];
            app.Slider_B94.MajorTickLabels = {''};
            app.Slider_B94.Orientation = 'vertical';
            app.Slider_B94.ValueChangingFcn = createCallbackFcn(app, @Slider_B94ValueChanging, true);
            app.Slider_B94.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B94.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B94.Position = [792 401 3 150];

            % Create Slider_B95
            app.Slider_B95 = uislider(app.UIFigure);
            app.Slider_B95.Limits = [-6 6];
            app.Slider_B95.MajorTicks = [];
            app.Slider_B95.MajorTickLabels = {''};
            app.Slider_B95.Orientation = 'vertical';
            app.Slider_B95.ValueChangingFcn = createCallbackFcn(app, @Slider_B95ValueChanging, true);
            app.Slider_B95.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B95.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B95.Position = [861 399 3 150];

            % Create Slider_B96
            app.Slider_B96 = uislider(app.UIFigure);
            app.Slider_B96.Limits = [-6 6];
            app.Slider_B96.MajorTicks = [];
            app.Slider_B96.MajorTickLabels = {''};
            app.Slider_B96.Orientation = 'vertical';
            app.Slider_B96.ValueChangingFcn = createCallbackFcn(app, @Slider_B96ValueChanging, true);
            app.Slider_B96.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B96.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B96.Position = [929 398 3 150];

            % Create Slider_B97
            app.Slider_B97 = uislider(app.UIFigure);
            app.Slider_B97.Limits = [-6 6];
            app.Slider_B97.MajorTicks = [];
            app.Slider_B97.MajorTickLabels = {''};
            app.Slider_B97.Orientation = 'vertical';
            app.Slider_B97.ValueChangingFcn = createCallbackFcn(app, @Slider_B97ValueChanging, true);
            app.Slider_B97.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B97.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B97.Position = [997 402 3 150];

            % Create Slider_B98
            app.Slider_B98 = uislider(app.UIFigure);
            app.Slider_B98.Limits = [-6 6];
            app.Slider_B98.MajorTicks = [];
            app.Slider_B98.MajorTickLabels = {''};
            app.Slider_B98.Orientation = 'vertical';
            app.Slider_B98.ValueChangingFcn = createCallbackFcn(app, @Slider_B98ValueChanging, true);
            app.Slider_B98.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B98.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B98.Position = [1065 402 3 150];

            % Create Slider_B85
            app.Slider_B85 = uislider(app.UIFigure);
            app.Slider_B85.Limits = [-6 6];
            app.Slider_B85.MajorTicks = [];
            app.Slider_B85.MajorTickLabels = {''};
            app.Slider_B85.Orientation = 'vertical';
            app.Slider_B85.ValueChangingFcn = createCallbackFcn(app, @Slider_B85ValueChanging, true);
            app.Slider_B85.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B85.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B85.Position = [585 402 3 150];

            % Create Slider_B86
            app.Slider_B86 = uislider(app.UIFigure);
            app.Slider_B86.Limits = [-6 6];
            app.Slider_B86.MajorTicks = [];
            app.Slider_B86.MajorTickLabels = {''};
            app.Slider_B86.Orientation = 'vertical';
            app.Slider_B86.ValueChangingFcn = createCallbackFcn(app, @Slider_B86ValueChanging, true);
            app.Slider_B86.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B86.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B86.Position = [654 402 3 150];

            % Create Slider_B913
            app.Slider_B913 = uislider(app.UIFigure);
            app.Slider_B913.Limits = [-6 6];
            app.Slider_B913.MajorTicks = [];
            app.Slider_B913.MajorTickLabels = {''};
            app.Slider_B913.Orientation = 'vertical';
            app.Slider_B913.ValueChangingFcn = createCallbackFcn(app, @Slider_B913ValueChanging, true);
            app.Slider_B913.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B913.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B913.Position = [1133 402 3 150];

            % Create Slider_B914
            app.Slider_B914 = uislider(app.UIFigure);
            app.Slider_B914.Limits = [-6 6];
            app.Slider_B914.MajorTicks = [];
            app.Slider_B914.MajorTickLabels = {''};
            app.Slider_B914.Orientation = 'vertical';
            app.Slider_B914.ValueChangingFcn = createCallbackFcn(app, @Slider_B914ValueChanging, true);
            app.Slider_B914.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B914.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B914.Position = [1201 402 3 150];

            % Create Slider_B915
            app.Slider_B915 = uislider(app.UIFigure);
            app.Slider_B915.Limits = [-6 6];
            app.Slider_B915.MajorTicks = [];
            app.Slider_B915.MajorTickLabels = {''};
            app.Slider_B915.Orientation = 'vertical';
            app.Slider_B915.ValueChangingFcn = createCallbackFcn(app, @Slider_B915ValueChanging, true);
            app.Slider_B915.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B915.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B915.Position = [1269 402 3 150];

            % Create Slider_B916
            app.Slider_B916 = uislider(app.UIFigure);
            app.Slider_B916.Limits = [-6 6];
            app.Slider_B916.MajorTicks = [];
            app.Slider_B916.MajorTickLabels = {''};
            app.Slider_B916.Orientation = 'vertical';
            app.Slider_B916.ValueChangingFcn = createCallbackFcn(app, @Slider_B916ValueChanging, true);
            app.Slider_B916.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B916.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B916.Position = [1337 400 3 150];

            % Create Image_record
            app.Image_record = uiimage(app.UIFigure);
            app.Image_record.Position = [274 267 57 43];
            app.Image_record.ImageSource = fullfile(pathToMLAPP, 'img', 'record.png');

            % Create AUDIOEQUALIZERLabel
            app.AUDIOEQUALIZERLabel = uilabel(app.UIFigure);
            app.AUDIOEQUALIZERLabel.HorizontalAlignment = 'center';
            app.AUDIOEQUALIZERLabel.FontName = 'Verdana';
            app.AUDIOEQUALIZERLabel.FontSize = 36;
            app.AUDIOEQUALIZERLabel.FontWeight = 'bold';
            app.AUDIOEQUALIZERLabel.Position = [522 675 393 48];
            app.AUDIOEQUALIZERLabel.Text = 'AUDIO EQUALIZER';

            % Create LabelMax
            app.LabelMax = uilabel(app.UIFigure);
            app.LabelMax.FontSize = 18;
            app.LabelMax.FontWeight = 'bold';
            app.LabelMax.FontColor = [1 0 0];
            app.LabelMax.Position = [1366 529 25 23];
            app.LabelMax.Text = '6';

            % Create LabelMin
            app.LabelMin = uilabel(app.UIFigure);
            app.LabelMin.FontSize = 18;
            app.LabelMin.FontWeight = 'bold';
            app.LabelMin.FontColor = [1 0 0];
            app.LabelMin.Position = [1366 378 48 23];
            app.LabelMin.Text = '-6';

            % Create Slider_B12
            app.Slider_B12 = uislider(app.UIFigure);
            app.Slider_B12.Limits = [-6 6];
            app.Slider_B12.MajorTicks = [];
            app.Slider_B12.MajorTickLabels = {''};
            app.Slider_B12.Orientation = 'vertical';
            app.Slider_B12.ValueChangingFcn = createCallbackFcn(app, @Slider_B12ValueChanging, true);
            app.Slider_B12.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B12.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B12.Position = [33 402 3 150];

            % Create Slider_B53
            app.Slider_B53 = uislider(app.UIFigure);
            app.Slider_B53.Limits = [-6 6];
            app.Slider_B53.MajorTicks = [];
            app.Slider_B53.MajorTickLabels = {''};
            app.Slider_B53.Orientation = 'vertical';
            app.Slider_B53.ValueChangingFcn = createCallbackFcn(app, @Slider_B53ValueChanging, true);
            app.Slider_B53.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B53.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B53.Position = [240 402 3 150];

            % Create Slider_B54
            app.Slider_B54 = uislider(app.UIFigure);
            app.Slider_B54.Limits = [-6 6];
            app.Slider_B54.MajorTicks = [];
            app.Slider_B54.MajorTickLabels = {''};
            app.Slider_B54.Orientation = 'vertical';
            app.Slider_B54.ValueChangingFcn = createCallbackFcn(app, @Slider_B54ValueChanging, true);
            app.Slider_B54.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B54.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B54.Position = [309 402 3 150];

            % Create Slider_B63
            app.Slider_B63 = uislider(app.UIFigure);
            app.Slider_B63.Limits = [-6 6];
            app.Slider_B63.MajorTicks = [];
            app.Slider_B63.MajorTickLabels = {''};
            app.Slider_B63.Orientation = 'vertical';
            app.Slider_B63.ValueChangingFcn = createCallbackFcn(app, @Slider_B63ValueChanging, true);
            app.Slider_B63.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B63.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B63.Position = [378 402 3 150];

            % Create Slider_B64
            app.Slider_B64 = uislider(app.UIFigure);
            app.Slider_B64.Limits = [-6 6];
            app.Slider_B64.MajorTicks = [];
            app.Slider_B64.MajorTickLabels = {''};
            app.Slider_B64.Orientation = 'vertical';
            app.Slider_B64.ValueChangingFcn = createCallbackFcn(app, @Slider_B64ValueChanging, true);
            app.Slider_B64.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B64.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B64.Position = [447 402 3 150];

            % Create Slider_B22
            app.Slider_B22 = uislider(app.UIFigure);
            app.Slider_B22.Limits = [-6 6];
            app.Slider_B22.MajorTicks = [];
            app.Slider_B22.MajorTickLabels = {''};
            app.Slider_B22.Orientation = 'vertical';
            app.Slider_B22.ValueChangingFcn = createCallbackFcn(app, @Slider_B22ValueChanging, true);
            app.Slider_B22.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B22.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B22.Position = [102 402 3 150];

            % Create Slider_B32
            app.Slider_B32 = uislider(app.UIFigure);
            app.Slider_B32.Limits = [-6 6];
            app.Slider_B32.MajorTicks = [];
            app.Slider_B32.MajorTickLabels = {''};
            app.Slider_B32.Orientation = 'vertical';
            app.Slider_B32.ValueChangingFcn = createCallbackFcn(app, @Slider_B32ValueChanging, true);
            app.Slider_B32.MinorTicks = [-6 -5.5 -5 -4.5 -4 -3.5 -3 -2.5 -2 -1.5 -1 -0.5 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6];
            app.Slider_B32.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B32.Position = [171 402 3 150];

            % Create Image_warning
            app.Image_warning = uiimage(app.UIFigure);
            app.Image_warning.Position = [268 50 71 58];
            app.Image_warning.ImageSource = fullfile(pathToMLAPP, 'img', 'warning.png');

            % Create Image_check
            app.Image_check = uiimage(app.UIFigure);
            app.Image_check.Position = [280 58 48 43];
            app.Image_check.ImageSource = fullfile(pathToMLAPP, 'img', 'check.png');

            % Create Label_B12
            app.Label_B12 = uilabel(app.UIFigure);
            app.Label_B12.HorizontalAlignment = 'center';
            app.Label_B12.FontName = 'Verdana';
            app.Label_B12.FontSize = 10;
            app.Label_B12.Position = [9 372 55 31];
            app.Label_B12.Text = ' 0';

            % Create Label_B22
            app.Label_B22 = uilabel(app.UIFigure);
            app.Label_B22.HorizontalAlignment = 'center';
            app.Label_B22.FontName = 'Verdana';
            app.Label_B22.FontSize = 10;
            app.Label_B22.Position = [74 373 54 30];
            app.Label_B22.Text = ' 0';

            % Create Label_B32
            app.Label_B32 = uilabel(app.UIFigure);
            app.Label_B32.HorizontalAlignment = 'center';
            app.Label_B32.FontName = 'Verdana';
            app.Label_B32.FontSize = 10;
            app.Label_B32.Position = [138 373 59 30];
            app.Label_B32.Text = ' 0';

            % Create Label_B53
            app.Label_B53 = uilabel(app.UIFigure);
            app.Label_B53.HorizontalAlignment = 'center';
            app.Label_B53.FontName = 'Verdana';
            app.Label_B53.FontSize = 10;
            app.Label_B53.Position = [207 373 59 30];
            app.Label_B53.Text = ' 0';

            % Create Label_B54
            app.Label_B54 = uilabel(app.UIFigure);
            app.Label_B54.HorizontalAlignment = 'center';
            app.Label_B54.FontName = 'Verdana';
            app.Label_B54.FontSize = 10;
            app.Label_B54.Position = [276 373 59 30];
            app.Label_B54.Text = ' 0';

            % Create Label_B63
            app.Label_B63 = uilabel(app.UIFigure);
            app.Label_B63.HorizontalAlignment = 'center';
            app.Label_B63.FontName = 'Verdana';
            app.Label_B63.FontSize = 10;
            app.Label_B63.Position = [345 373 59 30];
            app.Label_B63.Text = ' 0';

            % Create Label_B64
            app.Label_B64 = uilabel(app.UIFigure);
            app.Label_B64.HorizontalAlignment = 'center';
            app.Label_B64.FontName = 'Verdana';
            app.Label_B64.FontSize = 10;
            app.Label_B64.Position = [414 373 59 30];
            app.Label_B64.Text = ' 0';

            % Create Label_B81
            app.Label_B81 = uilabel(app.UIFigure);
            app.Label_B81.HorizontalAlignment = 'center';
            app.Label_B81.FontName = 'Verdana';
            app.Label_B81.FontSize = 10;
            app.Label_B81.Position = [483 373 59 30];
            app.Label_B81.Text = ' 0';

            % Create Label_B85
            app.Label_B85 = uilabel(app.UIFigure);
            app.Label_B85.HorizontalAlignment = 'center';
            app.Label_B85.FontName = 'Verdana';
            app.Label_B85.FontSize = 10;
            app.Label_B85.Position = [552 373 59 30];
            app.Label_B85.Text = ' 0';

            % Create Label_B86
            app.Label_B86 = uilabel(app.UIFigure);
            app.Label_B86.HorizontalAlignment = 'center';
            app.Label_B86.FontName = 'Verdana';
            app.Label_B86.FontSize = 10;
            app.Label_B86.Position = [621 373 59 30];
            app.Label_B86.Text = ' 0';

            % Create Label_B93
            app.Label_B93 = uilabel(app.UIFigure);
            app.Label_B93.HorizontalAlignment = 'center';
            app.Label_B93.FontName = 'Verdana';
            app.Label_B93.FontSize = 10;
            app.Label_B93.Position = [690 373 59 30];
            app.Label_B93.Text = ' 0';

            % Create Label_B94
            app.Label_B94 = uilabel(app.UIFigure);
            app.Label_B94.HorizontalAlignment = 'center';
            app.Label_B94.FontName = 'Verdana';
            app.Label_B94.FontSize = 10;
            app.Label_B94.Position = [759 373 59 30];
            app.Label_B94.Text = ' 0';

            % Create Label_B95
            app.Label_B95 = uilabel(app.UIFigure);
            app.Label_B95.HorizontalAlignment = 'center';
            app.Label_B95.FontName = 'Verdana';
            app.Label_B95.FontSize = 10;
            app.Label_B95.Position = [828 373 59 30];
            app.Label_B95.Text = ' 0';

            % Create Label_B96
            app.Label_B96 = uilabel(app.UIFigure);
            app.Label_B96.HorizontalAlignment = 'center';
            app.Label_B96.FontName = 'Verdana';
            app.Label_B96.FontSize = 10;
            app.Label_B96.Position = [897 373 59 30];
            app.Label_B96.Text = ' 0';

            % Create Label_B97
            app.Label_B97 = uilabel(app.UIFigure);
            app.Label_B97.HorizontalAlignment = 'center';
            app.Label_B97.FontName = 'Verdana';
            app.Label_B97.FontSize = 10;
            app.Label_B97.Position = [966 373 59 30];
            app.Label_B97.Text = ' 0';

            % Create Label_B98
            app.Label_B98 = uilabel(app.UIFigure);
            app.Label_B98.HorizontalAlignment = 'center';
            app.Label_B98.FontName = 'Verdana';
            app.Label_B98.FontSize = 10;
            app.Label_B98.Position = [1035 373 59 30];
            app.Label_B98.Text = ' 0';

            % Create Label_B913
            app.Label_B913 = uilabel(app.UIFigure);
            app.Label_B913.HorizontalAlignment = 'center';
            app.Label_B913.FontName = 'Verdana';
            app.Label_B913.FontSize = 10;
            app.Label_B913.Position = [1104 373 59 30];
            app.Label_B913.Text = ' 0';

            % Create Label_B914
            app.Label_B914 = uilabel(app.UIFigure);
            app.Label_B914.HorizontalAlignment = 'center';
            app.Label_B914.FontName = 'Verdana';
            app.Label_B914.FontSize = 10;
            app.Label_B914.Position = [1173 373 59 30];
            app.Label_B914.Text = ' 0';

            % Create Label_B915
            app.Label_B915 = uilabel(app.UIFigure);
            app.Label_B915.HorizontalAlignment = 'center';
            app.Label_B915.FontName = 'Verdana';
            app.Label_B915.FontSize = 10;
            app.Label_B915.Position = [1241 373 59 30];
            app.Label_B915.Text = ' 0';

            % Create Label_B916
            app.Label_B916 = uilabel(app.UIFigure);
            app.Label_B916.HorizontalAlignment = 'center';
            app.Label_B916.FontName = 'Verdana';
            app.Label_B916.FontSize = 10;
            app.Label_B916.Position = [1309 373 59 30];
            app.Label_B916.Text = ' 0';

            % Create FindAudioButton
            app.FindAudioButton = uibutton(app.UIFigure, 'push');
            app.FindAudioButton.BackgroundColor = [0.1608 0.4706 0.6706];
            app.FindAudioButton.FontName = 'Verdana';
            app.FindAudioButton.FontSize = 18;
            app.FindAudioButton.FontColor = [1 1 1];
            app.FindAudioButton.Position = [53 193 185 52];
            app.FindAudioButton.Text = 'Find Audio';

            % Create SaveEqualizedButton
            app.SaveEqualizedButton = uibutton(app.UIFigure, 'push');
            app.SaveEqualizedButton.BackgroundColor = [0.9412 0.9608 0.9804];
            app.SaveEqualizedButton.FontName = 'Verdana';
            app.SaveEqualizedButton.FontSize = 18;
            app.SaveEqualizedButton.Position = [368 48 151 54];
            app.SaveEqualizedButton.Text = 'Save Equalized';

            % Create SaveRecordButton
            app.SaveRecordButton = uibutton(app.UIFigure, 'push');
            app.SaveRecordButton.BackgroundColor = [0.9412 0.9608 0.9804];
            app.SaveRecordButton.FontName = 'Verdana';
            app.SaveRecordButton.FontSize = 18;
            app.SaveRecordButton.Position = [366 256 151 54];
            app.SaveRecordButton.Text = 'Save Record';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = AppMatlab

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end