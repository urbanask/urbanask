cd ..\scripts\
attrib -r urbanask-compiled.js
copy /b block-start.js + strings-en.js + urbanask.js + add-answer.js + block-end.js urbanask-compiled.js
java -jar ..\..\..\Common\yuicompressor-2.4.7.jar urbanask-compiled.js -o urbanask-compiled.js --line-break 300
cd ..\styles\
java -jar ..\..\..\Common\yuicompressor-2.4.7.jar urbanask.css -o urbanask-compiled.css --line-break 300
cd ..
"C:\Program Files (x86)\7-Zip\7z.exe" a urbangab.zip @build-scripts\zip-files.txt

