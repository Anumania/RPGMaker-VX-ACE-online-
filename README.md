# RPGMaker-VX-ACE-online-
Frankenstein

funny little multiplayer mod idea, use my modloader (https://github.com/Anumania/RPGMaker_universal_modloader) to load this and you can play any rpgmaker vx ace game online with your friends. ~~Currently i am hosting the server, but if you want to host your own, compile this using a different ip, weather that be a localhost, hamachi ip, whatever.~~

lol nvm im keeping the server private until it looks less shit.

Also im planning on making this work with every version of rpgmaker, rpgmaker vx ace as can be seen, is almost done. rpgmaker 2003 is possible and about 10% done. vx and xp are just slightly older versions of vx ace and might work without modification. mz and mv are probably doable but i havent tried.

installation instructions: follow the steps on https://github.com/Anumania/RPGMaker_universal_modloader, then go to releases on this page and download the 2 files, net_test.dll, and Scripts.rvdata2. place Scripts.rvdata2 in the same directory as the exe, and place net_test.dll into the System folder next to the exe. load save 16, and press connect. currently you will probably almost definitely crash unless you are playing Lisa: the painful RPG, but im working on making that not happen.

source files: NetStuff.rb is the ruby side of networking, net_test is a vc++ dll that allows rpgmaker to send and recieve tcp communications (poorly).
