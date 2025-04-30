@echo off

set _filename=%~n1
set _extension=%~x1
REM set _filepath=%~1
REM -------------- PRE -----------------
if exist "%_filename%.srt" echo Nothing to do & goto end
REM if not exists "%_filepath%" echo File not exists & goto end
call "files/.venv/Scripts/activate.bat"

REM EXTENSION check
if (%_extension% EQU mp3) goto continue
if (%_extension% NEQ mp3) goto convert
:convert
files\ffmpeg.exe -i "%_filename%%_extension%" "%_filename%.mp3"
set _extension=.mp3
goto continue
:continue
REM ------------ PRE-END -----------------
copy %1 files\"%_filename%%_extension%"
cd files
python transcribe.py "%_filename%%_extension%" hu
copy "%_filename%%_extension%.srt" ..\
cd ..
ren "%_filename%%_extension%.srt" "%_filename%.srt"
cd files
del "%_filename%%_extension%"
del "%_filename%%_extension%.srt"
goto end

:end

pause
