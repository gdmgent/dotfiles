@echo off
doskey cjs=code . && js
doskey console=php app/console $1
doskey js=jekyll serve --incremental

doskey c=cd %USERPROFILE%\Code\
doskey h=cd %USERPROFILE%
doskey s=cd %USERPROFILE%\Syllabi\

doskey ll=ls -la

doskey hosts=code %Systemroot%\System32\Drivers\Etc\hosts

rem Artestead
doskey artestead-c=cd %USERPROFILE%\Code\artestead\
doskey artestead-s=cd %USERPROFILE%\Syllabi\artestead-doc\ && cjs

rem Dotfiles
doskey dotfiles-c=cd %USERPROFILE%\Code\dotfiles\
doskey dotfiles-s=cd %USERPROFILE%\Syllabi\dotfiles-doc\ && cjs

rem Crossmedia Publishing
doskey cmp=cd %USERPROFILE%\Code\cmp.local\
doskey cmp-s=cd %USERPROFILE%\Syllabi\cmp\ && cjs

rem Crossmedia Publishing I, II & III
doskey cmp1=cd %USERPROFILE%\Code\cmp1.local\
doskey cmp2=cd %USERPROFILE%\Code\cmp2.local\
doskey cmp3=cd %USERPROFILE%\Code\cmp3.local\

rem E-design
doskey ed=cd %USERPROFILE%\Code\ed.local\
doskey ed-s=cd %USERPROFILE%\Syllabi\ed\ && cjs

rem Mulimedia-applicaties
doskey mma=cd %USERPROFILE%\Code\mma.local\
doskey mma-s=cd %USERPROFILE%\Syllabi\mma\ && cjs

rem New Media Design & Development II
doskey nmdad2=cd %USERPROFILE%\Code\nmdad2.local\
doskey nmdad2-s=cd %USERPROFILE%\Syllabi\nmdad2\ && cjs

rem New Media Design & Development III
doskey nmdad3=cd %USERPROFILE%\Code\nmdad3.local\
doskey nmdad3-s=cd %USERPROFILE%\Syllabi\nmdad3\ && cjs

rem Webdesign I & II
doskey webd=cd %USERPROFILE%\Code\webd.local\
doskey webd-s=cd %USERPROFILE%\Syllabi\webd\ && cjs