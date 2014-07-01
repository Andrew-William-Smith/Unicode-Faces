Unicode Faces
=============

Unicode Faces is an OS X application written by Andrew Smith to aid Internet users in inserting Unicode faces commonly seen on social websites.  It was created to be very simple to use, but still offer some powerful features for those who enjoy customization.  Its basic function is automatically typing strings of text with no copy-pasting or typing.

Features
========

- Insert Unicode faces such as ಠ_ಠ with a few clicks and no typing
- Expansive default library of faces
- Quickly add, edit, and delete faces
    - GUI elements
    - Plain-text file (~/.faces) editable with any text editor that supports the UTF-8 character set
- Escape mode - Escape backslashes by typing them twice (\\ → \\\\) to avoid the "lost arm" effect on sites like Reddit
    - Typed thrice (\\\\\\) before Markdown formatting characters to properly escape them
    - ¯\_(ツ)_/¯ → ¯\\_(ツ)_/¯

Face File
=========
All faces used in this application are stored in plain text at `~/.faces`.  This means that the file is editable with any text editor that supports the UTF-8 character set.  Please note that the following rules must be followed:

- The first line must contain only either `true` or `false`.  This indicates whether or not escape mode is enabled.
- Each face must be on its own line.
- All line breaks must be newline characters (\\n).
- The last line of the file must end with a newline character.
