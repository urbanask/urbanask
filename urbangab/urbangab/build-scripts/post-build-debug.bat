cd ..\scripts\
attrib -r urbanask-compiled.js
copy /b block-start.js + strings-en.js + urbanask.js + add-answer.js + block-end.js urbanask-compiled.js
cd ..\styles\
xcopy urbanask.css urbanask-compiled.css /y
cd ..
"C:\Program Files (x86)\7-Zip\7z.exe" a urbangab.zip @build-scripts\zip-files.txt


