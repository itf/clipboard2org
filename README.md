# clipboard2org
Paste html or images to an org file.

This package converts HTML copied in the clipboard to ORG by using Pandoc
And it automatically save images in png or jpeg from the clipboard to a
sub-directory ./img/ by generating a random name, and then inserts it in the
org file.


## Usage
Add it to path, run (require 'clipboard2org).
Bind clipboard2org-paste to some key, suggested:
(define-key org-mode-map (kbd "C-S-y ") 'clipboard2org-paste)
