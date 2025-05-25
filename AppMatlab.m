classdef AppMatlab < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure matlab.ui.Figure
        Image_check matlab.ui.control.Image
        Image_warning matlab.ui.control.Image
        Slider_B32 matlab.ui.control.Slider
        HzLabel_18 matlab.ui.control.Label
        Slider_B22 matlab.ui.control.Slider
        HzLabel_17 matlab.ui.control.Label
        Slider_B64 matlab.ui.control.Slider
        HzLabel_16 matlab.ui.control.Label
        Slider_B63 matlab.ui.control.Slider
        HzLabel_15 matlab.ui.control.Label
        Slider_B54 matlab.ui.control.Slider
        HzLabel_14 matlab.ui.control.Label
        Slider_B53 matlab.ui.control.Slider
        HzLabel_13 matlab.ui.control.Label
        Slider_B12 matlab.ui.control.Slider
        HzLabel_19 matlab.ui.control.Label
        LabelMin matlab.ui.control.Label
        LabelMax matlab.ui.control.Label
        AUDIOEQUALIZERLabel matlab.ui.control.Label
        Image_record matlab.ui.control.Image
        Slider_B916 matlab.ui.control.Slider
        HzLabel_12 matlab.ui.control.Label
        Slider_B915 matlab.ui.control.Slider
        HzLabel_11 matlab.ui.control.Label
        Slider_B914 matlab.ui.control.Slider
        HzLabel_10 matlab.ui.control.Label
        Slider_B913 matlab.ui.control.Slider
        HzLabel_9 matlab.ui.control.Label
        Slider_B86 matlab.ui.control.Slider
        HzLabel_8 matlab.ui.control.Label
        Slider_B85 matlab.ui.control.Slider
        HzLabel_7 matlab.ui.control.Label
        Slider_B98 matlab.ui.control.Slider
        HzLabel_6 matlab.ui.control.Label
        Slider_B97 matlab.ui.control.Slider
        HzLabel_5 matlab.ui.control.Label
        Slider_B96 matlab.ui.control.Slider
        HzLabel_4 matlab.ui.control.Label
        Slider_B95 matlab.ui.control.Slider
        HzLabel_3 matlab.ui.control.Label
        Slider_B94 matlab.ui.control.Slider
        HzLabel_2 matlab.ui.control.Label
        Slider_B93 matlab.ui.control.Slider
        HzLabel matlab.ui.control.Label
        BandsSwitch matlab.ui.control.Switch
        BandsSwitchLabel matlab.ui.control.Label
        EqualizeAudioButton matlab.ui.control.Button
        PlayEqualizedButton matlab.ui.control.Button
        PlayOriginalButton matlab.ui.control.Button
        RecordAudioButton matlab.ui.control.Button
        DropDownOutput matlab.ui.control.DropDown
        SeleccionaSalidadeaudioLabel matlab.ui.control.Label
        DropDownInput matlab.ui.control.DropDown
        IntradadeaudioLabel matlab.ui.control.Label
        Nc1Label matlab.ui.control.Label
        r16Label matlab.ui.control.Label
        Tc54613Label matlab.ui.control.Label
        Fs48000Label matlab.ui.control.Label
        Slider_B81 matlab.ui.control.Slider
        HzSliderLabel matlab.ui.control.Label
        UIAxes matlab.ui.control.UIAxes
    end

    properties (Access = private)
        Fs double = 48000; % Frecuencia de muestreo
        Tc double = 5.4613; % Tiempo de captura
        r double = 16; % Bits por muestra
        Nc double = 1; % Número de canales
        LoD double % Filtro de descomposición bajo
        HiD double % Filtro de descomposición alto
        LoR double % Filtro de reconstrucción bajo
        HiR double % Filtro de reconstrucción alto

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
                    nombresEntrada = cell(1, numel(entradaList) + 1);
                    nombresEntrada{1} = '-1 (default)';

                    for i = 1:numel(entradaList)
                        nombresEntrada{i + 1} = sprintf('[%d] %s', entradaList(i).ID, entradaList(i).Name);
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
                    nombresSalida = cell(1, numel(salidaList) + 1);
                    nombresSalida{1} = '-1 (default)';

                    for i = 1:numel(salidaList)
                        nombresSalida{i + 1} = sprintf('[%d] %s', salidaList(i).ID, salidaList(i).Name);
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

            app.Image_record.Visible = 'on'; % Mostrar imagen
            % Mostrar mensaje de grabación
            disp('Grabando...');

            % Iniciar grabación
            record(grabadora, app.Tc);

            % Esperar el tiempo de grabación más un segundo extra
            pause(app.Tc + 1);
            app.Image_record.Visible = 'off'; % Mostrar imagen

            % Obtener datos de audio
            x = getaudiodata(grabadora, 'double');

            disp('Grabación finalizada.');

            % Opcional: mostrar duración o info del audio capturado
            fprintf('Se grabaron %.2f segundos de audio.\n', app.Tc);

            % Aquí puedes guardar el audio o procesarlo...
            % audiowrite('grabacion.wav', x, app.Fs);
            x = getaudiodata(grabadora, 'double');

            % Guardar el audio grabado en la propiedad para uso posterior
            app.audioGrabadoOriginal = x;

            %  Usa transformada de Fourier para análisis o visualización
            [X, FREC1] = fourier(x, app.Fs);

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
                playblocking(player, app.Tc);
                disp('Reproduciendo audio...');
            catch ME
                uialert(app.UIFigure, sprintf('Error al reproducir: %s', ME.message), 'Error');
            end

        end

        % Value changed function: BandsSwitch
        function BandsSwitchValueChanged(app, event)
            val = app.BandsSwitch.Value;
            disp(['Valor actual del switch: "', val, '"']);

            if strcmp(val, '[12, -12]')
                newLimits = [-12 12];
                app.LabelMax.Text = '12';
                app.LabelMin.Text = '-12';
            else
                newLimits = [-6 6];
                app.LabelMax.Text = '6';
                app.LabelMin.Text = '-6';
            end

            disp('Nuevos límites:')
            disp(newLimits)
            % Arreglo con todos los sliders
            sliders = [app.Slider_B12, app.Slider_B22, app.Slider_B32, app.Slider_B53, app.Slider_B54, ...
                           app.Slider_B63, app.Slider_B64, app.Slider_B81, app.Slider_B85, app.Slider_B86, ...
                           app.Slider_B93, app.Slider_B94, app.Slider_B95, app.Slider_B96, app.Slider_B97, ...
                           app.Slider_B98, app.Slider_B913, app.Slider_B914, app.Slider_B915, app.Slider_B916];

            for k = 1:length(sliders)
                sliders(k).Limits = newLimits;
                % Asegurarse que el valor actual está dentro del rango
                if sliders(k).Value < newLimits(1) || sliders(k).Value > newLimits(2)
                    sliders(k).Value = mean(newLimits);
                end

            end

            app.LabelMax = '12';
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
            Fs = app.Fs; % frecuencia de muestreo
            T = 1 / Fs; % periodo de muestreo
            t = (0:length(x) - 1) / Fs;
            n = 0:length(x) - 1;

            senalActual = x';

            % Filtros cargados en startupFcn
            LoD = app.LoD;
            HiD = app.HiD;
            LoR = app.LoR;
            HiR = app.HiR;

            % Descomposición wavelet niveles 1 a 9
            [x11, x12] = dwwt(senalActual, LoD, HiD); % Nivel 1
            [x21, x22] = dwwt(x11, LoD, HiD); % Nivel 2
            [x31, x32] = dwwt(x21, LoD, HiD); % Nivel 3
            [x41, x42] = dwwt(x31, LoD, HiD); % Nivel 4
            [x51, x52] = dwwt(x41, LoD, HiD); % Nivel 5
            [x53, x54] = dwwt(x42, LoD, HiD);
            [x61, x62] = dwwt(x51, LoD, HiD); % Nivel 6
            [x63, x64] = dwwt(x52, LoD, HiD);
            [x71, x72] = dwwt(x61, LoD, HiD); % Nivel 7
            [x73, x74] = dwwt(x62, LoD, HiD);
            [x81, x82] = dwwt(x71, LoD, HiD); % Nivel 8
            [x83, x84] = dwwt(x72, LoD, HiD);
            [x85, x86] = dwwt(x73, LoD, HiD);
            [x87, x88] = dwwt(x74, LoD, HiD);
            [x93, x94] = dwwt(x82, LoD, HiD); % Nivel 9
            [x95, x96] = dwwt(x83, LoD, HiD);
            [x97, x98] = dwwt(x84, LoD, HiD);
            [x913, x914] = dwwt(x87, LoD, HiD);
            [x915, x916] = dwwt(x88, LoD, HiD);

            % Obtén las ganancias de los sliders
            ganancia_B916 = app.Slider_B916.Value;
            ganancia_B915 = app.Slider_B915.Value;
            ganancia_B914 = app.Slider_B914.Value;
            ganancia_B913 = app.Slider_B913.Value;
            ganancia_B98 = app.Slider_B98.Value;
            ganancia_B97 = app.Slider_B97.Value;
            ganancia_B96 = app.Slider_B96.Value;
            ganancia_B95 = app.Slider_B95.Value;
            ganancia_B94 = app.Slider_B94.Value;
            ganancia_B93 = app.Slider_B93.Value;
            ganancia_B86 = app.Slider_B86.Value;
            ganancia_B85 = app.Slider_B85.Value;
            ganancia_B81 = app.Slider_B81.Value;
            %---- 7 m+as
            ganancia_B64 = app.Slider_B64.Value;
            ganancia_B63 = app.Slider_B63.Value;
            ganancia_B54 = app.Slider_B54.Value;
            ganancia_B53 = app.Slider_B53.Value;
            ganancia_B32 = app.Slider_B32.Value;
            ganancia_B22 = app.Slider_B22.Value;
            ganancia_B12 = app.Slider_B12.Value;

            % Aplica las ganancias a las subbandas
            % Aplica las ganancias a las subbandas
            x916 = x916 * ganancia_B916;
            x915 = x915 * ganancia_B915;
            x914 = x914 * ganancia_B914;
            x913 = x913 * ganancia_B913;
            x86 = x86 * ganancia_B86;
            x85 = x85 * ganancia_B85;
            x98 = x98 * ganancia_B98;
            x97 = x97 * ganancia_B97;
            x96 = x96 * ganancia_B96;
            x95 = x95 * ganancia_B95;
            x94 = x94 * ganancia_B94;
            x93 = x93 * ganancia_B93;
            x81 = x81 * ganancia_B81;
            %-- 7 mas
            x64 = x64 * ganancia_B64;
            x63 = x63 * ganancia_B63;
            x54 = x54 * ganancia_B54;
            x53 = x53 * ganancia_B53;
            x32 = x32 * ganancia_B32;
            x22 = x22 * ganancia_B22;
            x12 = x12 * ganancia_B12;

            % --- Reconstrucción desde nivel 9 hacia el nivel 1 ---

            % Reconstrucción parcial Nivel 9
            x82r = rwwt(x93, x94, LoR, HiR);
            x83r = rwwt(x95, x96, LoR, HiR);
            x84r = rwwt(x97, x98, LoR, HiR);
            x87r = rwwt(x913, x914, LoR, HiR);
            x88r = rwwt(x915, x916, LoR, HiR);

            % Ajuste de tamaño (parche)
            x82r(end + 1) = x82(end);
            x83r(end + 1) = x83(end);
            x84r(end + 1) = x84(end);
            x87r(end + 1) = x87(end);
            x88r(end + 1) = x88(end);

            % Reconstrucción Nivel 8
            x71r = rwwt(x81, x82r, LoR, HiR);
            x72r = rwwt(x83r, x84r, LoR, HiR);
            x73r = rwwt(x85, x86, LoR, HiR);
            x74r = rwwt(x87r, x88r, LoR, HiR);

            x71r(end + 1) = x71(end);
            x72r(end + 1) = x72(end);
            x73r(end + 1) = x73(end);
            x74r(end + 1) = x74(end);

            % Reconstrucción Nivel 7
            x61r = rwwt(x71r, x72r, LoR, HiR);
            x62r = rwwt(x73r, x74r, LoR, HiR);

            x61r(end + 1) = x61(end);
            x62r(end + 1) = x62(end);

            % Reconstrucción Nivel 6
            x51r = rwwt(x61r, x62r, LoR, HiR);
            x52r = rwwt(x63, x64, LoR, HiR);

            x51r(end + 1) = x51(end);
            x52r(end + 1) = x52(end);

            % Reconstrucción Nivel 5
            x41r = rwwt(x51r, x52r, LoR, HiR);
            x42r = rwwt(x53, x54, LoR, HiR);

            x41r(end + 1) = x41(end);
            x42r(end + 1) = x42(end);

            % Reconstrucción Nivel 4
            x31r = rwwt(x41r, x42r, LoR, HiR);

            x31r(end + 1) = x31(end);

            % Reconstrucción Nivel 3
            x21r = rwwt(x31r, x32, LoR, HiR);

            x21r(end + 1) = x21(end);

            % Reconstrucción Nivel 2
            x11r = rwwt(x21r, x22, LoR, HiR);

            x11r(end + 1) = x11(end);

            % ------------Reconstrucción Nivel 1: señal reconstruida
            xr = rwwt(x11r, x12, LoR, HiR);

            % Ajusta tamaño para que coincida con señal original
            %------parche start
            xr = xr(1:length(x));
            % --- parche old

            %  Usa transformada de Fourier para análisis o visualización
            [X, FREC1] = fourier(x, app.Fs);
            [XR, ~] = fourier(xr, app.Fs);
            app.audioEcualizado = xr

            NX = length(x);
            nx = 0:NX - 1;

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
        end

        % Value changing function: Slider_B32
        function Slider_B32ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B22
        function Slider_B22ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B64
        function Slider_B64ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';

        end

        % Value changing function: Slider_B63
        function Slider_B63ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';

        end

        % Value changing function: Slider_B54
        function Slider_B54ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B53
        function Slider_B53ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B916
        function Slider_B916ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B915
        function Slider_B915ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B914
        function Slider_B914ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B913
        function Slider_B913ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B86
        function Slider_B86ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B85
        function Slider_B85ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B98
        function Slider_B98ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';

        end

        % Value changing function: Slider_B97
        function Slider_B97ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';

        end

        % Value changing function: Slider_B96
        function Slider_B96ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';

        end

        % Value changing function: Slider_B95
        function Slider_B95ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';

        end

        % Value changing function: Slider_B94
        function Slider_B94ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B93
        function Slider_B93ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';
        end

        % Value changing function: Slider_B81
        function Slider_B81ValueChanging(app, event)
            app.Image_warning.Visible = 'on';
            app.Image_check.Visible = 'off';

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
            app.UIFigure.Position = [100 100 1401 763];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Title')
            xlabel(app.UIAxes, 'X')
            ylabel(app.UIAxes, 'Y')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.Position = [380 38 589 307];

            % Create HzSliderLabel
            app.HzSliderLabel = uilabel(app.UIFigure);
            app.HzSliderLabel.HorizontalAlignment = 'right';
            app.HzSliderLabel.FontColor = [0.1804 0.4314 0.6588];
            app.HzSliderLabel.Position = [477 387 36 22];
            app.HzSliderLabel.Text = '81 Hz';

            % Create Slider_B81
            app.Slider_B81 = uislider(app.UIFigure);
            app.Slider_B81.Limits = [-6 6];
            app.Slider_B81.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B81.MajorTickLabels = {''};
            app.Slider_B81.Orientation = 'vertical';
            app.Slider_B81.ValueChangingFcn = createCallbackFcn(app, @Slider_B81ValueChanging, true);
            app.Slider_B81.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B81.Position = [482 412 3 150];

            % Create Fs48000Label
            app.Fs48000Label = uilabel(app.UIFigure);
            app.Fs48000Label.FontName = 'Verdana';
            app.Fs48000Label.FontSize = 15;
            app.Fs48000Label.Position = [1063 731 87 22];
            app.Fs48000Label.Text = 'Fs= 48000';

            % Create Tc54613Label
            app.Tc54613Label = uilabel(app.UIFigure);
            app.Tc54613Label.FontName = 'Verdana';
            app.Tc54613Label.FontSize = 15;
            app.Tc54613Label.Position = [1167 731 91 22];
            app.Tc54613Label.Text = 'Tc= 5.4613';

            % Create r16Label
            app.r16Label = uilabel(app.UIFigure);
            app.r16Label.FontName = 'Verdana';
            app.r16Label.FontSize = 15;
            app.r16Label.Position = [1274 731 48 22];
            app.r16Label.Text = 'r= 16';

            % Create Nc1Label
            app.Nc1Label = uilabel(app.UIFigure);
            app.Nc1Label.FontName = 'Verdana';
            app.Nc1Label.FontSize = 15;
            app.Nc1Label.Position = [1341 731 51 22];
            app.Nc1Label.Text = 'Nc= 1';

            % Create IntradadeaudioLabel
            app.IntradadeaudioLabel = uilabel(app.UIFigure);
            app.IntradadeaudioLabel.BackgroundColor = [0.9412 0.9608 0.9804];
            app.IntradadeaudioLabel.HorizontalAlignment = 'right';
            app.IntradadeaudioLabel.FontName = 'Verdana';
            app.IntradadeaudioLabel.FontSize = 16;
            app.IntradadeaudioLabel.FontColor = [0.302 0.302 0.302];
            app.IntradadeaudioLabel.Position = [130 643 140 22];
            app.IntradadeaudioLabel.Text = 'Input de audio   ';

            % Create DropDownInput
            app.DropDownInput = uidropdown(app.UIFigure);
            app.DropDownInput.FontName = 'Verdana';
            app.DropDownInput.FontSize = 16;
            app.DropDownInput.FontColor = [0.302 0.302 0.302];
            app.DropDownInput.BackgroundColor = [0.9412 0.9608 0.9804];
            app.DropDownInput.Position = [285 642 179 23];

            % Create SeleccionaSalidadeaudioLabel
            app.SeleccionaSalidadeaudioLabel = uilabel(app.UIFigure);
            app.SeleccionaSalidadeaudioLabel.BackgroundColor = [0.9412 0.9608 0.9804];
            app.SeleccionaSalidadeaudioLabel.HorizontalAlignment = 'right';
            app.SeleccionaSalidadeaudioLabel.FontName = 'Verdana';
            app.SeleccionaSalidadeaudioLabel.FontSize = 17;
            app.SeleccionaSalidadeaudioLabel.FontColor = [0.302 0.302 0.302];
            app.SeleccionaSalidadeaudioLabel.Position = [129 608 143 23];
            app.SeleccionaSalidadeaudioLabel.Text = 'Output de audio';

            % Create DropDownOutput
            app.DropDownOutput = uidropdown(app.UIFigure);
            app.DropDownOutput.FontName = 'Verdana';
            app.DropDownOutput.FontSize = 16;
            app.DropDownOutput.FontColor = [0.302 0.302 0.302];
            app.DropDownOutput.BackgroundColor = [0.9412 0.9608 0.9804];
            app.DropDownOutput.Position = [287 608 179 23];

            % Create RecordAudioButton
            app.RecordAudioButton = uibutton(app.UIFigure, 'push');
            app.RecordAudioButton.ButtonPushedFcn = createCallbackFcn(app, @RecordAudioButtonPushed, true);
            app.RecordAudioButton.BackgroundColor = [0.1608 0.4706 0.6706];
            app.RecordAudioButton.FontName = 'Verdana';
            app.RecordAudioButton.FontSize = 18;
            app.RecordAudioButton.FontColor = [1 1 1];
            app.RecordAudioButton.Position = [53 272 185 52];
            app.RecordAudioButton.Text = 'Record Audio';

            % Create PlayOriginalButton
            app.PlayOriginalButton = uibutton(app.UIFigure, 'push');
            app.PlayOriginalButton.ButtonPushedFcn = createCallbackFcn(app, @PlayOriginalButtonPushed, true);
            app.PlayOriginalButton.BackgroundColor = [0.9412 0.9608 0.9804];
            app.PlayOriginalButton.FontName = 'Verdana';
            app.PlayOriginalButton.FontSize = 18;
            app.PlayOriginalButton.Position = [1139 271 149 54];
            app.PlayOriginalButton.Text = 'Play Original';

            % Create PlayEqualizedButton
            app.PlayEqualizedButton = uibutton(app.UIFigure, 'push');
            app.PlayEqualizedButton.ButtonPushedFcn = createCallbackFcn(app, @PlayEqualizedButtonPushed, true);
            app.PlayEqualizedButton.BackgroundColor = [0.9412 0.9608 0.9804];
            app.PlayEqualizedButton.FontName = 'Verdana';
            app.PlayEqualizedButton.FontSize = 18;
            app.PlayEqualizedButton.Position = [1139 112 150 54];
            app.PlayEqualizedButton.Text = 'Play Equalized';

            % Create EqualizeAudioButton
            app.EqualizeAudioButton = uibutton(app.UIFigure, 'push');
            app.EqualizeAudioButton.ButtonPushedFcn = createCallbackFcn(app, @EqualizeAudioButtonPushed, true);
            app.EqualizeAudioButton.BackgroundColor = [0.9373 0.3882 0.4078];
            app.EqualizeAudioButton.FontName = 'Verdana';
            app.EqualizeAudioButton.FontSize = 18;
            app.EqualizeAudioButton.FontColor = [1 1 1];
            app.EqualizeAudioButton.Position = [47 113 197 52];
            app.EqualizeAudioButton.Text = 'Equalize Audio';

            % Create BandsSwitchLabel
            app.BandsSwitchLabel = uilabel(app.UIFigure);
            app.BandsSwitchLabel.BackgroundColor = [0.9412 0.9608 0.9804];
            app.BandsSwitchLabel.HorizontalAlignment = 'center';
            app.BandsSwitchLabel.FontName = 'Verdana';
            app.BandsSwitchLabel.FontSize = 17;
            app.BandsSwitchLabel.FontColor = [0.5294 0.1216 0.0471];
            app.BandsSwitchLabel.Position = [914 640 57 23];
            app.BandsSwitchLabel.Text = 'Bands';

            % Create BandsSwitch
            app.BandsSwitch = uiswitch(app.UIFigure, 'slider');
            app.BandsSwitch.Items = {'[-6, 6]', '[12, -12]'};
            app.BandsSwitch.ValueChangedFcn = createCallbackFcn(app, @BandsSwitchValueChanged, true);
            app.BandsSwitch.FontName = 'Verdana';
            app.BandsSwitch.FontSize = 17;
            app.BandsSwitch.Position = [920 608 45 20];
            app.BandsSwitch.Value = '[-6, 6]';

            % Create HzLabel
            app.HzLabel = uilabel(app.UIFigure);
            app.HzLabel.HorizontalAlignment = 'right';
            app.HzLabel.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel.Position = [675 387 33 22];
            app.HzLabel.Text = '93Hz';

            % Create Slider_B93
            app.Slider_B93 = uislider(app.UIFigure);
            app.Slider_B93.Limits = [-6 6];
            app.Slider_B93.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B93.MajorTickLabels = {''};
            app.Slider_B93.Orientation = 'vertical';
            app.Slider_B93.ValueChangingFcn = createCallbackFcn(app, @Slider_B93ValueChanging, true);
            app.Slider_B93.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B93.Position = [680 412 3 150];

            % Create HzLabel_2
            app.HzLabel_2 = uilabel(app.UIFigure);
            app.HzLabel_2.HorizontalAlignment = 'right';
            app.HzLabel_2.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_2.Position = [738 387 36 22];
            app.HzLabel_2.Text = '94 Hz';

            % Create Slider_B94
            app.Slider_B94 = uislider(app.UIFigure);
            app.Slider_B94.Limits = [-6 6];
            app.Slider_B94.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B94.MajorTickLabels = {''};
            app.Slider_B94.Orientation = 'vertical';
            app.Slider_B94.ValueChangingFcn = createCallbackFcn(app, @Slider_B94ValueChanging, true);
            app.Slider_B94.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B94.Position = [743 412 3 150];

            % Create HzLabel_3
            app.HzLabel_3 = uilabel(app.UIFigure);
            app.HzLabel_3.HorizontalAlignment = 'right';
            app.HzLabel_3.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_3.Position = [805 387 36 22];
            app.HzLabel_3.Text = '95 Hz';

            % Create Slider_B95
            app.Slider_B95 = uislider(app.UIFigure);
            app.Slider_B95.Limits = [-6 6];
            app.Slider_B95.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B95.MajorTickLabels = {''};
            app.Slider_B95.Orientation = 'vertical';
            app.Slider_B95.ValueChangingFcn = createCallbackFcn(app, @Slider_B95ValueChanging, true);
            app.Slider_B95.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B95.Position = [809 412 3 150];

            % Create HzLabel_4
            app.HzLabel_4 = uilabel(app.UIFigure);
            app.HzLabel_4.HorizontalAlignment = 'right';
            app.HzLabel_4.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_4.Position = [871 387 36 22];
            app.HzLabel_4.Text = '96 Hz';

            % Create Slider_B96
            app.Slider_B96 = uislider(app.UIFigure);
            app.Slider_B96.Limits = [-6 6];
            app.Slider_B96.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B96.MajorTickLabels = {''};
            app.Slider_B96.Orientation = 'vertical';
            app.Slider_B96.ValueChangingFcn = createCallbackFcn(app, @Slider_B96ValueChanging, true);
            app.Slider_B96.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B96.Position = [876 412 3 150];

            % Create HzLabel_5
            app.HzLabel_5 = uilabel(app.UIFigure);
            app.HzLabel_5.HorizontalAlignment = 'right';
            app.HzLabel_5.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_5.Position = [937 387 33 22];
            app.HzLabel_5.Text = '97Hz';

            % Create Slider_B97
            app.Slider_B97 = uislider(app.UIFigure);
            app.Slider_B97.Limits = [-6 6];
            app.Slider_B97.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B97.MajorTickLabels = {''};
            app.Slider_B97.Orientation = 'vertical';
            app.Slider_B97.ValueChangingFcn = createCallbackFcn(app, @Slider_B97ValueChanging, true);
            app.Slider_B97.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B97.Position = [942 413 3 150];

            % Create HzLabel_6
            app.HzLabel_6 = uilabel(app.UIFigure);
            app.HzLabel_6.HorizontalAlignment = 'right';
            app.HzLabel_6.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_6.Position = [1000 386 36 22];
            app.HzLabel_6.Text = '98 Hz';

            % Create Slider_B98
            app.Slider_B98 = uislider(app.UIFigure);
            app.Slider_B98.Limits = [-6 6];
            app.Slider_B98.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B98.MajorTickLabels = {''};
            app.Slider_B98.Orientation = 'vertical';
            app.Slider_B98.ValueChangingFcn = createCallbackFcn(app, @Slider_B98ValueChanging, true);
            app.Slider_B98.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B98.Position = [1005 414 3 150];

            % Create HzLabel_7
            app.HzLabel_7 = uilabel(app.UIFigure);
            app.HzLabel_7.HorizontalAlignment = 'right';
            app.HzLabel_7.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_7.Position = [543 388 36 22];
            app.HzLabel_7.Text = '85 Hz';

            % Create Slider_B85
            app.Slider_B85 = uislider(app.UIFigure);
            app.Slider_B85.Limits = [-6 6];
            app.Slider_B85.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B85.MajorTickLabels = {''};
            app.Slider_B85.Orientation = 'vertical';
            app.Slider_B85.ValueChangingFcn = createCallbackFcn(app, @Slider_B85ValueChanging, true);
            app.Slider_B85.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B85.Position = [548 412 3 150];

            % Create HzLabel_8
            app.HzLabel_8 = uilabel(app.UIFigure);
            app.HzLabel_8.HorizontalAlignment = 'right';
            app.HzLabel_8.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_8.Position = [609 387 36 22];
            app.HzLabel_8.Text = '86 Hz';

            % Create Slider_B86
            app.Slider_B86 = uislider(app.UIFigure);
            app.Slider_B86.Limits = [-6 6];
            app.Slider_B86.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B86.MajorTickLabels = {''};
            app.Slider_B86.Orientation = 'vertical';
            app.Slider_B86.ValueChangingFcn = createCallbackFcn(app, @Slider_B86ValueChanging, true);
            app.Slider_B86.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B86.Position = [614 413 3 150];

            % Create HzLabel_9
            app.HzLabel_9 = uilabel(app.UIFigure);
            app.HzLabel_9.HorizontalAlignment = 'right';
            app.HzLabel_9.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_9.Position = [1066 386 43 22];
            app.HzLabel_9.Text = '913 Hz';

            % Create Slider_B913
            app.Slider_B913 = uislider(app.UIFigure);
            app.Slider_B913.Limits = [-6 6];
            app.Slider_B913.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B913.MajorTickLabels = {''};
            app.Slider_B913.Orientation = 'vertical';
            app.Slider_B913.ValueChangingFcn = createCallbackFcn(app, @Slider_B913ValueChanging, true);
            app.Slider_B913.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B913.Position = [1071 414 3 150];

            % Create HzLabel_10
            app.HzLabel_10 = uilabel(app.UIFigure);
            app.HzLabel_10.HorizontalAlignment = 'right';
            app.HzLabel_10.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_10.Position = [1142 387 43 22];
            app.HzLabel_10.Text = '914 Hz';

            % Create Slider_B914
            app.Slider_B914 = uislider(app.UIFigure);
            app.Slider_B914.Limits = [-6 6];
            app.Slider_B914.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B914.MajorTickLabels = {''};
            app.Slider_B914.Orientation = 'vertical';
            app.Slider_B914.ValueChangingFcn = createCallbackFcn(app, @Slider_B914ValueChanging, true);
            app.Slider_B914.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B914.Position = [1144 413 3 150];

            % Create HzLabel_11
            app.HzLabel_11 = uilabel(app.UIFigure);
            app.HzLabel_11.HorizontalAlignment = 'right';
            app.HzLabel_11.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_11.Position = [1215 386 43 22];
            app.HzLabel_11.Text = '915 Hz';

            % Create Slider_B915
            app.Slider_B915 = uislider(app.UIFigure);
            app.Slider_B915.Limits = [-6 6];
            app.Slider_B915.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B915.MajorTickLabels = {''};
            app.Slider_B915.Orientation = 'vertical';
            app.Slider_B915.ValueChangingFcn = createCallbackFcn(app, @Slider_B915ValueChanging, true);
            app.Slider_B915.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B915.Position = [1220 414 3 150];

            % Create HzLabel_12
            app.HzLabel_12 = uilabel(app.UIFigure);
            app.HzLabel_12.HorizontalAlignment = 'right';
            app.HzLabel_12.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_12.Position = [1293 387 43 22];
            app.HzLabel_12.Text = '916 Hz';

            % Create Slider_B916
            app.Slider_B916 = uislider(app.UIFigure);
            app.Slider_B916.Limits = [-6 6];
            app.Slider_B916.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B916.MajorTickLabels = {''};
            app.Slider_B916.Orientation = 'vertical';
            app.Slider_B916.ValueChangingFcn = createCallbackFcn(app, @Slider_B916ValueChanging, true);
            app.Slider_B916.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B916.Position = [1293 413 3 150];

            % Create Image_record
            app.Image_record = uiimage(app.UIFigure);
            app.Image_record.Position = [274 277 57 43];
            app.Image_record.ImageSource = fullfile(pathToMLAPP, 'record.png');

            % Create AUDIOEQUALIZERLabel
            app.AUDIOEQUALIZERLabel = uilabel(app.UIFigure);
            app.AUDIOEQUALIZERLabel.HorizontalAlignment = 'center';
            app.AUDIOEQUALIZERLabel.FontName = 'Verdana';
            app.AUDIOEQUALIZERLabel.FontSize = 36;
            app.AUDIOEQUALIZERLabel.FontWeight = 'bold';
            app.AUDIOEQUALIZERLabel.Position = [522 685 393 48];
            app.AUDIOEQUALIZERLabel.Text = 'AUDIO EQUALIZER';

            % Create LabelMax
            app.LabelMax = uilabel(app.UIFigure);
            app.LabelMax.FontSize = 18;
            app.LabelMax.FontWeight = 'bold';
            app.LabelMax.FontColor = [1 0 0];
            app.LabelMax.Position = [1353 545 25 23];
            app.LabelMax.Text = '6';

            % Create LabelMin
            app.LabelMin = uilabel(app.UIFigure);
            app.LabelMin.FontSize = 18;
            app.LabelMin.FontWeight = 'bold';
            app.LabelMin.FontColor = [1 0 0];
            app.LabelMin.Position = [1353 394 48 23];
            app.LabelMin.Text = '-6';

            % Create HzLabel_19
            app.HzLabel_19 = uilabel(app.UIFigure);
            app.HzLabel_19.HorizontalAlignment = 'right';
            app.HzLabel_19.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_19.Position = [19 384 33 22];
            app.HzLabel_19.Text = '12Hz';

            % Create Slider_B12
            app.Slider_B12 = uislider(app.UIFigure);
            app.Slider_B12.Limits = [-6 6];
            app.Slider_B12.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B12.MajorTickLabels = {''};
            app.Slider_B12.Orientation = 'vertical';
            app.Slider_B12.ValueChangingFcn = createCallbackFcn(app, @Slider_B12ValueChanging, true);
            app.Slider_B12.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B12.Position = [19 415 3 150];

            % Create HzLabel_13
            app.HzLabel_13 = uilabel(app.UIFigure);
            app.HzLabel_13.HorizontalAlignment = 'right';
            app.HzLabel_13.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_13.Position = [216 386 33 22];
            app.HzLabel_13.Text = '53Hz';

            % Create Slider_B53
            app.Slider_B53 = uislider(app.UIFigure);
            app.Slider_B53.Limits = [-6 6];
            app.Slider_B53.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B53.MajorTickLabels = {''};
            app.Slider_B53.Orientation = 'vertical';
            app.Slider_B53.ValueChangingFcn = createCallbackFcn(app, @Slider_B53ValueChanging, true);
            app.Slider_B53.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B53.Position = [221 414 3 150];

            % Create HzLabel_14
            app.HzLabel_14 = uilabel(app.UIFigure);
            app.HzLabel_14.HorizontalAlignment = 'right';
            app.HzLabel_14.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_14.Position = [279 386 36 22];
            app.HzLabel_14.Text = '54 Hz';

            % Create Slider_B54
            app.Slider_B54 = uislider(app.UIFigure);
            app.Slider_B54.Limits = [-6 6];
            app.Slider_B54.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B54.MajorTickLabels = {''};
            app.Slider_B54.Orientation = 'vertical';
            app.Slider_B54.ValueChangingFcn = createCallbackFcn(app, @Slider_B54ValueChanging, true);
            app.Slider_B54.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B54.Position = [284 414 3 150];

            % Create HzLabel_15
            app.HzLabel_15 = uilabel(app.UIFigure);
            app.HzLabel_15.HorizontalAlignment = 'right';
            app.HzLabel_15.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_15.Position = [345 386 36 22];
            app.HzLabel_15.Text = '63 Hz';

            % Create Slider_B63
            app.Slider_B63 = uislider(app.UIFigure);
            app.Slider_B63.Limits = [-6 6];
            app.Slider_B63.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B63.MajorTickLabels = {''};
            app.Slider_B63.Orientation = 'vertical';
            app.Slider_B63.ValueChangingFcn = createCallbackFcn(app, @Slider_B63ValueChanging, true);
            app.Slider_B63.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B63.Position = [350 414 3 150];

            % Create HzLabel_16
            app.HzLabel_16 = uilabel(app.UIFigure);
            app.HzLabel_16.HorizontalAlignment = 'right';
            app.HzLabel_16.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_16.Position = [411 387 36 22];
            app.HzLabel_16.Text = '64 Hz';

            % Create Slider_B64
            app.Slider_B64 = uislider(app.UIFigure);
            app.Slider_B64.Limits = [-6 6];
            app.Slider_B64.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B64.MajorTickLabels = {''};
            app.Slider_B64.Orientation = 'vertical';
            app.Slider_B64.ValueChangingFcn = createCallbackFcn(app, @Slider_B64ValueChanging, true);
            app.Slider_B64.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B64.Position = [416 413 3 150];

            % Create HzLabel_17
            app.HzLabel_17 = uilabel(app.UIFigure);
            app.HzLabel_17.HorizontalAlignment = 'right';
            app.HzLabel_17.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_17.Position = [83 385 36 22];
            app.HzLabel_17.Text = '22 Hz';

            % Create Slider_B22
            app.Slider_B22 = uislider(app.UIFigure);
            app.Slider_B22.Limits = [-6 6];
            app.Slider_B22.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B22.MajorTickLabels = {''};
            app.Slider_B22.Orientation = 'vertical';
            app.Slider_B22.ValueChangingFcn = createCallbackFcn(app, @Slider_B22ValueChanging, true);
            app.Slider_B22.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B22.Position = [88 414 3 150];

            % Create HzLabel_18
            app.HzLabel_18 = uilabel(app.UIFigure);
            app.HzLabel_18.HorizontalAlignment = 'right';
            app.HzLabel_18.FontColor = [0.1804 0.4314 0.6588];
            app.HzLabel_18.Position = [150 384 36 22];
            app.HzLabel_18.Text = '32 Hz';

            % Create Slider_B32
            app.Slider_B32 = uislider(app.UIFigure);
            app.Slider_B32.Limits = [-6 6];
            app.Slider_B32.MajorTicks = [-6 -3 0 3 6];
            app.Slider_B32.MajorTickLabels = {''};
            app.Slider_B32.Orientation = 'vertical';
            app.Slider_B32.ValueChangingFcn = createCallbackFcn(app, @Slider_B32ValueChanging, true);
            app.Slider_B32.FontColor = [0.1804 0.4314 0.6588];
            app.Slider_B32.Position = [155 416 3 150];

            % Create Image_warning
            app.Image_warning = uiimage(app.UIFigure);
            app.Image_warning.Position = [267 110 71 58];
            app.Image_warning.ImageSource = fullfile(pathToMLAPP, 'warning.png');

            % Create Image_check
            app.Image_check = uiimage(app.UIFigure);
            app.Image_check.Position = [279 118 48 43];
            app.Image_check.ImageSource = fullfile(pathToMLAPP, 'check.png');

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
