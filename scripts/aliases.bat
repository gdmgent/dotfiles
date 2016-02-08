@echo off
doskey cjs=code . $T jekyll serve --incremental
doskey console=php app/console $*
doskey js=jekyll serve --incremental

doskey c=cd %USERPROFILE%\Code\
doskey h=cd %USERPROFILE%
doskey s=cd %USERPROFILE%\Syllabi\

doskey ll=ls -la

doskey hosts=code %Systemroot%\System32\Drivers\Etc\hosts

rem Artestead
doskey artestead-c=cd %USERPROFILE%\Code\artestead\
doskey artestead-s=cd %USERPROFILE%\Syllabi\artestead-doc\ $T open http://localhost:4000/artestead/ $T code . $T jekyll serve --incremental

rem Dotfiles
doskey dotfiles-c=cd %USERPROFILE%\Code\dotfiles\
doskey dotfiles-s=cd %USERPROFILE%\Syllabi\dotfiles-doc\ $T open http://localhost:4000/dotfiles/ $T code . $T jekyll serve --incremental

rem Crossmedia Publishing
doskey cmp=cd %USERPROFILE%\Code\cmp.local\
doskey cmp-s=cd %USERPROFILE%\Syllabi\cmp\ $T open http://localhost:4000/cmp/ $T code . $T jekyll serve --incremental

rem Crossmedia Publishing I, II & III
doskey cmp1=cd %USERPROFILE%\Code\cmp1.local\
doskey cmp2=cd %USERPROFILE%\Code\cmp2.local\
doskey cmp3=cd %USERPROFILE%\Code\cmp3.local\

rem E-design
doskey ed=cd %USERPROFILE%\Code\ed.local\
doskey ed-s=cd %USERPROFILE%\Syllabi\ed\ $T open http://localhost:4000/ed/ $T code . $T jekyll serve --incremental

rem Mulimediatoepassingen
doskey mmtoep=cd %USERPROFILE%\Code\mmtoep.local\
doskey mmtoep-s=cd %USERPROFILE%\Syllabi\mmtoep\ $T open http://localhost:4000/mmtoep/ $T code . $T jekyll serve --incremental

rem New Media Design & Development II
doskey nmdad2=cd %USERPROFILE%\Code\nmdad2.local\
doskey nmdad2-s=cd %USERPROFILE%\Syllabi\nmdad2\ $T open http://localhost:4000/nmdad2/ $T code . $T jekyll serve --incremental

rem New Media Design & Development III
doskey nmdad3=cd %USERPROFILE%\Code\nmdad3.local\
doskey nmdad3-s=cd %USERPROFILE%\Syllabi\nmdad3\ $T open http://localhost:4000/nmdad3/ $T code . $T jekyll serve --incremental

rem Webdesign I & II
doskey webd=cd %USERPROFILE%\Code\webd.local\
doskey webd-s=cd %USERPROFILE%\Syllabi\webd\ $T open http://localhost:4000/webd/ $T code . $T jekyll serve --incremental