@echo off
doskey artisan=php artisan $*
doskey cjs=code . $T jekyll serve --watch
doskey cjsd=code . $T jekyll serve --watch --drafts
doskey cjsf=code . $T jekyll serve --watch --future
doskey cjsi=code . $T jekyll serve --watch --incremental
doskey cjsu=code . $T jekyll serve --watch --unpublished
doskey console=php app/console $*
doskey js=jekyll serve --watch
doskey jsd=jekyll serve --watch --drafts
doskey jsf=jekyll serve --watch --future
doskey jsi=jekyll serve --watch --incremental
doskey jsu=jekyll serve --watch --unpublished
doskey wip=git commit -a -m [WIP] $T git push

doskey ..=cd ..
doskey ...=cd ..\..

doskey c=cd %USERPROFILE%\Code\
doskey h=cd %USERPROFILE%
doskey s=cd %USERPROFILE%\Syllabi\

doskey ll=ls -la

doskey hosts=code %Systemroot%\System32\Drivers\Etc\hosts

rem Vagrant
doskey vd=vagrant destroy
doskey vg=vagrant global-status
doskey vgp=vagrant global-status --prune
doskey vh=vagrant halt
doskey vp=vagrant provision
doskey vr=vagrant reload
doskey vs=vagrant status
doskey vss=vagrant ssh
doskey vsu=vagrant suspend
doskey vu=vagrant up
doskey vup=vagrant up --provision

rem Artestead
doskey artestead-c=cd %USERPROFILE%\Code\artestead\
doskey artestead-s=cd %USERPROFILE%\Syllabi\artestead-doc\ $T start http://localhost:4000/artestead/ $T code . $T jekyll serve --incremental

rem Dotfiles
doskey dotfiles-c=cd %USERPROFILE%\Code\dotfiles\
doskey dotfiles-s=cd %USERPROFILE%\Syllabi\dotfiles-doc\ $T start http://localhost:4000/dotfiles/ $T code . $T jekyll serve --incremental

rem Crossmedia Publishing
doskey cmp=cd %USERPROFILE%\Code\cmp.local\
doskey cmp-s=cd %USERPROFILE%\Syllabi\cmp\ $T start http://localhost:4000/cmp/ $T code . $T jekyll serve --incremental

rem Crossmedia Publishing I, II & III
doskey cmp1=cd %USERPROFILE%\Code\cmp1.local\
doskey cmp2=cd %USERPROFILE%\Code\cmp2.local\
doskey cmp3=cd %USERPROFILE%\Code\cmp3.local\

rem E-design
doskey ed=cd %USERPROFILE%\Code\ed.local\
doskey ed-s=cd %USERPROFILE%\Syllabi\ed\ $T start http://localhost:4000/ed/ $T code . $T jekyll serve --incremental

rem Mulimedia-applicaties
doskey mma=cd %USERPROFILE%\Code\mma.local\
doskey mma-s=cd %USERPROFILE%\Syllabi\mma\ $T start http://localhost:4000/mma/ $T code . $T jekyll serve --incremental

rem New Media Design & Development II
doskey nmdad2=cd %USERPROFILE%\Code\nmdad2.local\
doskey nmdad2-s=cd %USERPROFILE%\Syllabi\nmdad2\ $T start http://localhost:4000/nmdad2/ $T code . $T jekyll serve --incremental

rem New Media Design & Development III
doskey nmdad3=cd %USERPROFILE%\Code\nmdad3.local\
doskey nmdad3-s=cd %USERPROFILE%\Syllabi\nmdad3\ $T start http://localhost:4000/nmdad3/ $T code . $T jekyll serve --incremental

rem Webdesign I & II
doskey webd=cd %USERPROFILE%\Code\webd.local\
doskey webd-s=cd %USERPROFILE%\Syllabi\webd\ $T start http://localhost:4000/webd/ $T code . $T jekyll serve --incremental