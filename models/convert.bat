setlocal
set PATH=%PATH%;"c:\Program Files\ImageMagick-7.0.10-Q16"
REM magick convert "%1" -remap palette_line.png -dither None -resize 50%% "%~n1_converted.png"

magick convert POSSA1.png POSSA2A8.png POSSA3A7.png POSSA4A6.png POSSA5.png -remap palette_line.png -dither None -resize 50%% +append converted_POSS.png"

REM python ..\..\PicoImageProc\convert.py --use-palette palette.txt converted_poss.png ..\carts\output4.p8
