Overview
========

Buffer-manipulation utility functions for Emacs.

Quickstart
----------

    (require 'buffer-utils)

    (buffer-utils-save-order
	  (bury-buffer "*scratch*"))

	;; buffer order is restored

buffer-utils.el
---------------

Buffer-utils.el is a collection of functions for buffer manipulation.

This library exposes very little user-level interface; it is
generally useful only for programming in Emacs Lisp.

To use buffer-utils, place the buffer-utils.el library somewhere
Emacs can find it, and add the following to your ~/.emacs file:

    (require 'buffer-utils)

The following functions and macros are provided:

    buffer-utils-all-in-mode
    buffer-utils-all-matching
    buffer-utils-bury-and-forget   ; can be called interactively
    buffer-utils-first-matching
    buffer-utils-huge-p
    buffer-utils-in-mode
    buffer-utils-most-recent-file-associated
    buffer-utils-narrowed-p
    buffer-utils-save-order
    buffer-utils-set-order

of which `buffer-utils-save-order` is the most notable.

`buffer-utils-save-order` is a macro, similar to `save-current-buffer`,
which saves and restores the order of the buffer list.

Compatibility and Requirements
------------------------------

Tested on GNU Emacs versions 23.3 and 24.1

No external dependencies
