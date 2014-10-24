FTLSaver
========

An FTL Game Saver Application for iPad.

Description
------------
This is a spare-time project designed for me to dip my feet into the pool of Obj-C coding while fufilling a purpose useful to at least myself. The code itself is likely wretched, and design priciples flawed, but the point is to have fun. Anything useful that results is just a bonus

Caveats and Oddities
--------------------
As of right now, there are a few weird things you have to do to get the project to work. The first is to have theos installed in /var/theos. I build primarily on my device, and so this works well for me. The second is that FTL saves the game anytime it is closed. This means that when running FTLSaver, you must ensure that FTL is at the main menu if it is running. If it is not, it will overwrite any restored games with the game it was running. The rest of the issues were resolved. ^.^ 

Lastly, you must have FTL installed from the App store for this to work. I hope you already figured that one out.
