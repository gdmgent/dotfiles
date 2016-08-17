@echo off
doskey dotfiles=cat %USERPROFILE%\Code\dotfiles\VERSION

doskey artisan=if exist artisan ( php artisan $* ) else ( echo Laravel Artisan is not available from this directory! )
doskey behat=if exist bin\behat ( php bin\behat $* ) else ( if exist vendor\bin\behat ( php vendor\bin\behat $* ) else ( behat $* ) )
doskey console=if exist bin\console ( php bin\console $* ) else ( if exist app\console ( php app\console $* ) else ( echo Symfony Console is not available from this directory! ) )
doskey phpunit=if exist bin\phpunit ( php bin\phpunit $* ) else ( if exist vendor\bin\phpunit ( php vendor\bin\phpunit $* ) else ( phpunit $* ) )

doskey ..=cd ..
doskey ...=cd ..\..
doskey c=cd %USERPROFILE%\Code\
doskey h=cd %USERPROFILE%
doskey s=cd %USERPROFILE%\Syllabi\

doskey ll=ls -la

doskey hosts=code %Systemroot%\System32\Drivers\Etc\hosts

rem Git
doskey add=git add .
doskey pull=git pull
doskey push=git push
doskey sts=git status
doskey wip=git commit -a -m [WIP] $T git push

rem Jekyll
doskey cjs=code . $T jekyll serve --watch
doskey cjsd=code . $T jekyll serve --watch --drafts
doskey cjsf=code . $T jekyll serve --watch --future
doskey cjsi=code . $T jekyll serve --watch --incremental
doskey cjsu=code . $T jekyll serve --watch --unpublished
doskey js=if not exist _config.yml ( echo There is no _config.yml in this directory! ) else ( jekyll serve --watch $* )
doskey jsd=if not exist _config.yml ( echo There is no _config.yml in this directory! ) else ( jekyll serve --watch --drafts $* )
doskey jsf=if not exist _config.yml ( echo There is no _config.yml in this directory! ) else ( jekyll serve --watch --future $* )
doskey jsi=if not exist _config.yml ( echo There is no _config.yml in this directory! ) else ( jekyll serve --watch --incremental $* )
doskey jsu=if not exist _config.yml ( echo There is no _config.yml in this directory! ) else ( jekyll serve --watch --unpublished $* )

rem Vagrant
doskey vbl=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant box list $* )
doskey vbr=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant box remove laravel/homestead --box-version $* )
doskey vbu=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant box update $* )
doskey vd=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant destroy $* )
doskey vg=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant global-status $* )
doskey vgp=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant global-status --prune $* )
doskey vh=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant halt $* )
doskey vp=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant provision $* )
doskey vr=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant reload $* )
doskey vrp=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant reload --provision $* )
doskey vs=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant status $* )
doskey vss=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant ssh $* )
doskey vsu=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant suspend $* )
doskey vu=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant up $* )
doskey vup=if not exist Vagrantfile ( echo There is no Vagrantfile in this directory! ) else ( vagrant up --provision $* )

rem OLODs
rem -----

rem Crossmedia Publishing
doskey cmp=cd %USERPROFILE%\Code\cmp.local\
doskey cmp-s=cd %USERPROFILE%\Syllabi\cmp\ $T start http://localhost:4000/cmp/ $T code . $T jekyll serve --unpublished

rem Crossmedia Publishing I, II & III
doskey cmp1=cd %USERPROFILE%\Code\cmp1.local\
doskey cmp2=cd %USERPROFILE%\Code\cmp2.local\
doskey cmp3=cd %USERPROFILE%\Code\cmp3.local\

rem E-design
doskey ed=cd %USERPROFILE%\Code\ed.local\
doskey ed-s=cd %USERPROFILE%\Syllabi\ed\ $T start http://localhost:4000/ed/ $T code . $T jekyll serve --unpublished

rem Mulimedia-applicaties
doskey mapps=cd %USERPROFILE%\Code\mapps.local\
doskey mapps-s=cd %USERPROFILE%\Syllabi\mapps\ $T start http://localhost:4000/mapps/ $T code . $T jekyll serve --unpublished

doskey mma=cd %USERPROFILE%\Code\mma.local\
doskey mma-s=cd %USERPROFILE%\Syllabi\mma\ $T start http://localhost:4000/mma/ $T code . $T jekyll serve --unpublished

rem New Media Design & Development II
doskey nmdad2=cd %USERPROFILE%\Code\nmdad2.local\
doskey nmdad2-s=cd %USERPROFILE%\Syllabi\nmdad2\ $T start http://localhost:4000/nmdad2/ $T code . $T jekyll serve --unpublished

rem New Media Design & Development III
doskey nmdad3=cd %USERPROFILE%\Code\nmdad3.local\
doskey nmdad3-s=cd %USERPROFILE%\Syllabi\nmdad3\ $T start http://localhost:4000/nmdad3/ $T code . $T jekyll serve --unpublished

rem Webdesign I, II, III & IV
doskey webd1-s=cd %USERPROFILE%\Syllabi\webd1\ $T start http://localhost:4000/webd1/ $T code . $T jekyll serve --unpublished
doskey webd2-s=cd %USERPROFILE%\Syllabi\webd2\ $T start http://localhost:4000/webd2/ $T code . $T jekyll serve --unpublished
doskey webd3-s=cd %USERPROFILE%\Syllabi\webd3\ $T start http://localhost:4000/webd3/ $T code . $T jekyll serve --unpublished
doskey webd4-s=cd %USERPROFILE%\Syllabi\webd4\ $T start http://localhost:4000/webd4/ $T code . $T jekyll serve --unpublished

rem Syllabi
rem -------

rem Artestead
doskey artestead-c=cd %USERPROFILE%\Code\artestead\
doskey artestead-s=cd %USERPROFILE%\Syllabi\artestead-doc\ $T start http://localhost:4000/artestead/ $T code . $T jekyll serve --unpublished

rem Dotfiles
doskey dotfiles-c=cd %USERPROFILE%\Code\dotfiles\
doskey dotfiles-s=cd %USERPROFILE%\Syllabi\dotfiles-doc\ $T start http://localhost:4000/dotfiles/ $T code . $T jekyll serve --unpublished

rem Syllabus
doskey syllabus-s=cd %USERPROFILE%\Syllabi\syllabus\ $T start http://localhost:4000/syllabus/ $T code . $T jekyll serve --unpublished

rem Web & New Media
doskey wanm-s=cd %USERPROFILE%\Syllabi\wanm\ $T start http://localhost:4000/wanm/ $T code . $T jekyll serve --unpublished