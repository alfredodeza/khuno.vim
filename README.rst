``static code analysis optimized for crappy Python ™``

khuno.vim - A Python flakes Vim plugin
======================================
Analyze your code with Tarek Ziade's Flake8 in Vim - seamlessly.

**There is nothing like this**

* Non-blocking (syntax check is called asynchronously)
* ``statusline`` helper to display (or not!) when there are errors.
* Separate buffer to display errors and jump to them (a la QuickFix)
* **highly performing**, every bit of the plugin is meant to be as fast as
  possible.

I would still consider this an *alpha* version, there are some undocumented
things (on purpose, I swear) that need some work, but feedback and complaints
are welcomed and encouraged.

Bug me at @alfredodeza on Twitter or fill the issues tab for this project.

.. image:: https://pbs.twimg.com/media/A6gNXsVCQAAKYLi.png

why?
----
I started this plugin because I am (was! ha!) pissed off at the alternatives.
Most solutions require a **blocking** call to the checker program, you can't do
anything else until that call ends.

That is unacceptable. I can't work like that. This plugin will not block while
you work in Vim.

A note on Pyflakes.vim: I used this until recently but the plugin *is no longer
maintained*.

Installation
------------
If you have Tim Pope's ``Pathogen.vim`` then you are already set, just clone
this plugin into the ``bundle`` directory. If you do not use ``Pathogen.vim``
you will need to distribute the files accordingly.

After you have installed the plugin you will need 2 more things:

1. `pip install flake8` This needs to be in your path, it doesn't matter where
it is installed.

2. ``filetype plugin on`` Enable the filetype detection in Vim that matches the
file type to plugins.

.. note::
    ``khuno.vim`` will not yell at you if you do not have ``flake8`` installed.
    It will only issue a warning if you try to use it directly, like ``:Khuno
    run``

Basic Usage
-----------
Open any Python file. As soon as you enter one, an asynchronous call will be
made to flake8, saving the results.

If you *move* the cursor, it will then proceed to read the results from the
check and underline all the words or lines in the current file.

Every time you save the file you will trigger the asynchronous call, enforcing
a refresh of the check and error display.

Showing Errors and Jumping
--------------------------
Just like what you would expect from something that pushes errors to the
QuickFix Window, except ``khuno.vim`` doesn't overload that. You should map the
call to the command below for convenience, but either way, this is how you
would trigger the window::

    :Khuno show

To map it, use something like this (say, for your leader key + x)::

        nmap <silent><Leader>x <Esc>:Khuno show<CR>

When the window is triggered, it will appear at the bottom and display 10 lines
at the most (to avoid clobbering the whole space). And a list will be shown
with contents similar to this::

    Line: 79  Col: 80  ==> E501 line too long (80 > 79 characters)

There is a special mapping for that buffer: if you press enter it will go the
previous window and move to the exact line and column where **that** error was
triggered.

``statusline`` helper function
------------------------------
If you want to display some text when there are errors in the file, you can use the helper
function. I use the optional text to display all my anger when there are
errors, like::

    set statusline=%#ErrorMsg#                   " set the highlight to error
    set statusline+=%{khuno#Status('FUU')}%*     " are there any errors? FUU!
    set statusline+=%*                           " switch back to normal status color

The text is optional, it will default to ``[E]``. How boring.

About the name
--------------
Khuno is the name of an Inca God that ruled the cold weather and loved the
snow. He would get *very* angry when someone messed with his snow. Now he rules
another type of flakes, the Python ones.

License
-------
Copyright (c) Alfredo Deza Distributed under the MIT license, see plugin for
details.
