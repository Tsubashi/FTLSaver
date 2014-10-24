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


License
--------
The MIT License (MIT)

Copyright (c) 2014 Tsubashi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
