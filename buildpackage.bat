rmdir packagetemp /s /q
mkdir packagetemp

xcopy ice packagetemp\ice /S /I /Y 
xcopy haxelib.json packagetemp /Y
xcopy README.md packagetemp /Y
xcopy LICENSE.md packagetemp /Y
xcopy CHANGELOG.md packagetemp /Y

cd packagetemp
7za a -tzip iceentity.zip 

haxelib submit iceentity.zip
