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

.. image:: https://github.com/alfredodeza/khuno.vim/raw/master/extras/khuno.gif

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

Every time you save the file or you are exiting ``insert mode``  you will
trigger the asynchronous call, enforcing a refresh of the check and error
display.

Even if you have unsaved (modified buffer) changes, they will show up.

Customization
-------------
To add builtins, in your .vimrc::

    let g:khuno_builtins="_,apply"

To ignore errors, in your .vimrc::

    let g:khuno_ignore="E501,W293"

If you want to change the max line length for PEP8::

    let g:khuno_max_line_length=99

To customize the location of your flake8 binary, set ``g:khuno_flake_cmd``::

    let g:khuno_flake_cmd="/opt/strangebin/flake8000"


Showing Errors and Jumping
--------------------------
Just like what you would expect from something that pushes errors to the
QuickFix Window, except ``khuno.vim`` doesn't overload that. You should map the
call to the command below for convenience, but either way, this is how you
would trigger the window::

    :Khuno show

To map it, use something like this (say, for your leader key + x)::

        nmap <silent><Leader>x <Esc>:Khuno show<CR>

This command is *toggable*, if the split window is already open, this command
will close it, otherwise it will open it.

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

The text is optional, it will default to ``[N]``, where ``N`` is the number of
errors for the current buffer.

Disabling/Enabling the checker
------------------------------
You can also disable the check on a specific buffer with::

    :Khuno off

To turn it on again, you can run::

    :Khuno on



FAQ
---
**Nothing seems to be happenning although I know there are errors**: A couple
of things here: make sure you followed the installation instructions (e.g.
``filetype on``) including having ``flake8`` installed and available on your
path. If all else fails, and ``Khuno`` loaded, run ``:Khuno debug`` that will
give you debugging information that might be useful.

**I opened a file (or buffer) and nothing happened**: This plugin calls the
checker asynchronously, so results are only fed back to the buffer *when the
cursor moves*. If you have not moved the cursor, the plugin will not paint the
buffer immediately with results.

**I just type some erroneous Python but the plugin didn't show it**: The plugin
will be called when you enter a buffer or when you save the file, and will feed
the errors back when the cursor moves. If you added something that is erroneous
it will not show up unless you save the file and move the cursor at least once.

**How do I get the underlined errors? I get something different**: This depends
on how your current color theme is highlighting bad spelling. Khuno uses the
same highlight for ``SpellBad``, so however this is defined in your color theme
is how it will look. If you are on a terminal and want to enforce underlining
instead of something else, you can try this: ``hi SpellBad cterm=underline``


About the name
--------------
Khuno is the name of an Inca God that ruled the cold weather and loved the
snow. He would get *very* angry when someone messed with his snow. Now he rules
another type of flakes, the Python ones.

License
-------
Copyright (c) Alfredo Deza Distributed under the MIT license, see plugin for
details.
