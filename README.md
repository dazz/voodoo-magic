Voodoo-Magic
============

Vodoo-Magic is a shell-script development framework written in Bash. It aims on
providing a flexible and extensible code-base for any and every kind of quirky
voodoo-magic shell-script fantasy of your needs.

Voodoo-Magic has adepted many design concepts from Rear (Relax and Recover) to
achieve a very high level of flexibility when it comes down to one of those
situations where you could rly rly use a nifty Bash script, but then realize the
overhead in taking care of all the business- and error logic surrounding your
actual few lines of script code.

The approach of the framework is easily explained. It distinguishes peripheral
logic from actual payload code and provides an abstraction layer called workflow
for you to write this actual script code in. The framework surrounding it
provides all sorts of useful tools and helpers to achieve your goal with maximum
effectiveness. Your workflow is then accessible as shell parameter within the
framework, e.g. `voodoo-magic <workflow>`. See `voodoo-magic help workflow` for
more details.

Voodoo-Magic targets junior admins and operators that either want to play around
with Bash or even improve their skills while learning more about all the
features and possibilities it has to offer. It can even be very helpful in many
common situations as described above, but should be seen in a more or less
academic context, after all. Please, feel welcome to contribute to voodoo-magic
in form of framework optimizations, creative ideas and all sorts of nifty
voodoo-magic workflows.

Happy hacking.


Installation
============

Voodoo-Magic comes with an installation workflow so it can easily be installed
to /. See `voodoo-magic help install` for more information.


Underlaying Design-Concept
==========================

Voodoo-Magic takes advantage of the GNU 'source' binary to include other script
files. The possibility to spread code across several files brings up the idea of
structuring your files in a very definit directory tree layout and then sourcing
them recursivly in a predefined order.

Suddenly it is possible to put process-logic into the directory structure
itself, meaning that changing the order or location of the script files, changes
the workflow as scripts are sourced in a different way. If-conditions can even
decide to either walk down the scripts in directory tree A or directory tree B.
Not only if-conditions, but also shell arguments could manipulate the behaviour
in which files are sourced in what order.

Basically a workflow within the framework, is nothing more than a predefined
directory structure that the framework can source because it knows the internal
layout. Now assume we call one sub-directory conf/ and another one we could call
functions/ and another one doc/ and so on, and we have various directory
structures of exectly this type laying around side by side. We can check if a
directory with the name $1 exists and if so, recursivly source all files in a
sensefully predefined order inside that directory. That's pretty much all the
magic there is to it.

Realizing the possibilities of this design-concept, the idea arose to write a
development framework, by adding plenty of useful helper functions and global
variables around the workflow before sourcing it, opening the possibility to
write small scripts by outsourcing all the repetative logic into the outlaying
framework. The framework provides an environment for the workflow with tools and
helpers for repetative tasks you would otherwise have to write over and over.

Severe parts of the design-concept have been adapted by Rear - Relax and
Recover.


Licensing
=========

Voodoo-Magic is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

Voodoo-Magic is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
Voodoo-Magic; if not, write to the Free Software Foundation, Inc., 51 Franklin
St, Fifth Floor, Boston, MA  02110-1301  USA

