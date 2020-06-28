setlocal
set PATH=%PATH%;"c:\Program Files\ImageMagick-7.0.10-Q16"
REM magick convert "%1" -remap palette_line.png -dither None -resize 50%% "converted_%~n1.png"

REM magick convert POSSA1.png POSSA2A8.png POSSA3A7.png POSSA4A6.png POSSA5.png -remap palette_line.png -dither None -resize 50%% +append converted_POSS.png

REM magick convert MISLA1.png MISLA5.png MISLA6A4.png MISLA7A3.png MISLA8A2.png -remap palette_line.png -dither None -resize 50%% +append converted_MISL.png

REM magick convert PLSEA0.png PLSEB0.png PLSEC0.png PLSED0.png PLSEE0.png  -remap palette_line.png -dither None -resize 50%% +append converted_%~n1.png

REM magick convert MISLB0.png MISLC0.png MISLD0.png -resize 50%% -remap palette_line.png -dither None -background none +append converted_%~n1.png

REM python ..\..\PicoImageProc\convert.py --use-palette palette.txt converted_%~n1.png ..\carts\%~n1.p8


for /f %%f in ('dir /b cybr') do magick cybr\%%f -resize 50%% -dither None -remap palette_line.png -background none -extent "%%[fx:16*(int(w/16)+1)]x%%[fx:16*(int(h/16)+1)]!" resized\%%f