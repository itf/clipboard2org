;;; clipboard2org.el --- paste html or images to an org file

;;; Commentary:

;; This package converts HTML copied in the clipboard to ORG by using Pandoc
;; And it automatically save images in png or jpeg from the clipboard to a
;; sub-directory ./img/ by generating a random name, and then inserts it in the
;; org file.
;; 
;; Inspired by https://emacs.stackexchange.com/questions/12121/org-mode-parsing-rich-html-directly-when-pasting

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

(require 'org)

;;; Code:
(defun clipboard2org-paste()
  "Paste HTML as org by using pandoc, or insert an image from the clipboard.
It inserts the image by first saving it with a random name in a ./img/ sub-directory"
  (interactive)
  (let* ((data-html (gui-backend-get-selection 'PRIMARY 'text/html))
         (data-png (gui-backend-get-selection 'PRIMARY 'image/png))
         (data-jpg (gui-backend-get-selection 'PRIMARY 'image/jpeg))
         (text-raw (gui-get-selection)))
    (cond (data-jpg (clipboard2org--image data-jpg ".jpg"))
          (data-png (clipboard2org--image data-png ".png"))
          (data-html (clipboard2org--html data-html))
          (text-raw (yank)))))

(defun clipboard2org--html(html-data)
  "Insert html data into the buffer.
HTML-DATA: html data from the clipboard"
  (let* ((decoded-html (decode-coding-string html-data 'unix))
         (text-html (shell-command-to-string (concat "echo "  (shell-quote-argument decoded-html) "|timeout 2  pandoc -f html-native_divs-native_spans -t org"))))
    (insert text-html)))
  

(defun clipboard2org--image(image-data extension)
  "Insert image into the buffer.
IMAGE-DATA: Raw image-data from the clipboard
EXTENSION: the image extensions, for example png, jpg. Additional support for others is trivial."
  (let* ((decoded-image-data (decode-coding-string image-data 'utf-8 t nil))
         (image-directory "./img/")
         (temp-file-name
          (let ((coding-system-for-write 'raw-text)
                (buffer-file-coding-system 'raw-text))
            (make-directory image-directory t)
            (make-temp-file "img" nil extension image-data)))
         (new-name (concat image-directory  (file-name-nondirectory temp-file-name))))
    (rename-file temp-file-name  new-name)
    (insert "#+ATTR_ORG: :width 300\n")
    (insert (concat  "#+CAPTION: "  "\n"))
    (insert (concat "[[file:" new-name "][file:" new-name "]]"))
    (org-display-inline-images)))


(provide 'clipboard2org)
;;; clipboard2org.el ends here
