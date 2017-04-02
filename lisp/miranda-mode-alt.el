;; Major mode for editing Miranda, and for running Miranda under Emacs
;; Miranda is a registered trademark of Research Software Limited
;; Copyright (C) 1992 Free Software Foundation, Inc.

;; Authors:
;; 
;;  - For editing Miranda:               Guy Lapalme and Eric Le Saux
;;                                       (lapalme@iro.umontreal.ca
;;                                        le_saux@iro.umontreal.ca)
;;                                       Universite de Montreal,
;;                                       June 1992
;;  - For running Miranda under emacs
;;    and browsing the Miranda manual:   Tim Lambert
;;                                       (lambert@spectrum.cs.unsw.oz.au)
;;                                       Copyright (C) 1991 Tim Lambert
;;  Modifications:(Guy Lapalme)
;;     nov 1993: use comint instead of shell
;;     apr 1994: fix mouse movements treatments Emacs18 vs Emacs19
;;     sep 1994: fix bugs in run-mira and mira-find-tabs (Emacs19)
;;               and drop Emacs18 compatibility
;;     
;; To use, put the following in your .emacs
;(setq auto-mode-alist (cons '("\\.m\$" . miranda-mode) auto-mode-alist))
;(setq completion-ignored-extensions (cons ".x" completion-ignored-extensions))

;(autoload 'miranda-mode "miranda-mode"
;                        "Major mode for editing Miranda scripts" t nil)
;(setq miranda-mode-hook
;      '(lambda ()
;         (mira-auto-fill-mode 1)))
;(autoload 'run-mira "miranda-mode" "Run an inferior Miranda session" t nil)
;(autoload 'mira-man "miranda-mode" "Access on-line Miranda manual" t nil)

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY.  No author or distributor
;; accepts responsibility to anyone for the consequences of using it
;; or for whether it serves any particular purpose or works at all,
;; unless he says so in writing.  Refer to the GNU Emacs General Public
;; License for full details.

;; Everyone is granted permission to copy, modify and redistribute
;; GNU Emacs, but only under the conditions described in the
;; GNU Emacs General Public License.   A copy of this license is
;; supposed to have been given to you along with GNU Emacs so you
;; can know your rights and responsibilities.  It should be in a
;; file named COPYING.  Among other things, the copyright notice
;; and this notice must be preserved on all copies.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Keymap 

(defvar miranda-mode-map nil)

(defun miranda-mode-commands (map)
  (define-key map "\177"       'backward-delete-char-untabify)
  (define-key map "\t"         'mira-indent-cycle)
  (define-key map "\C-Cw"      'mira-insert-where)
  (define-key map "\C-Cp"      'mira-align-patterns)
  (define-key map "\C-C."      'mira-align-guards)
  (define-key map "\C-C="      'mira-insert-equal)
  (define-key map "\C-C,"      'mira-insert-guard)
  (define-key map "\C-Co"      'mira-insert-otherwise)
  (define-key map "\C-C|"      'mira-comment-region)
  (define-key map "\C-C>"      'mira-put-region-in-lit-code)
  (define-key map "\M-\C-a"    'mira-beginning-of-function)
  (define-key map "\M-\C-e"    'mira-end-of-function)
  (define-key map "\M-\C-h"    'mira-mark-function)
  ;; inferior miranda process
  (define-key map "\e\C-x"     'mira-compile)
  (define-key map "\C-x`"      'mira-next-error)
  (define-key map "\C-c\C-f"   'mira-set-current-script)
  (define-key map "\C-c\C-e"   'mira-find-file)
  (define-key map "\M-."       'mira-find-tag)
  (define-key map "\M-\t"      'mira-complete-symbol)
  ;; miranda manual
  (define-key map "\C-c\C-m"   'mira-man)
)

(if miranda-mode-map
    nil
    (setq miranda-mode-map (make-sparse-keymap))
    (miranda-mode-commands miranda-mode-map))

;;; Syntax table 

(defvar miranda-mode-syntax-table nil)

(if miranda-mode-syntax-table
    ()
  (setq miranda-mode-syntax-table (make-syntax-table))
  (set-syntax-table miranda-mode-syntax-table)
  (modify-syntax-entry ?\t " ")
  (modify-syntax-entry ?| ". 12")
  (modify-syntax-entry ?\n ">")
  (modify-syntax-entry ?\f ">")
  (modify-syntax-entry ?\' "_")
  (modify-syntax-entry ?$ "_")
  (modify-syntax-entry ?_ "_")
  (modify-syntax-entry ?\\ "\\")
  (modify-syntax-entry ?% ".")
  (modify-syntax-entry ?& ".")
  (modify-syntax-entry ?* ".")
  (modify-syntax-entry ?+ ".")
  (modify-syntax-entry ?- ".")
  (modify-syntax-entry ?/ ".")
  (modify-syntax-entry ?< ".")
  (modify-syntax-entry ?= ".")
  (modify-syntax-entry ?> "."))

;;; Local variables 

(defun miranda-mode-variables ()
  "General purpose variables for the Miranda mode."
  (make-local-variable 'page-delimiter)
  (setq page-delimiter "^||||\f")
  (make-local-variable 'paragraph-start)
  (setq paragraph-start (concat "^|||\\|^$\\|" page-delimiter))
  (make-local-variable 'paragraph-separate)
  (setq paragraph-separate paragraph-start)
  (make-local-variable 'paragraph-ignore-fill-prefix)
  (setq paragraph-ignore-fill-prefix t)
  (make-local-variable 'indent-line-function)
  (setq indent-line-function 'mira-indent-cycle)
  (make-local-variable 'comment-start)
  (setq comment-start "||")
  (make-local-variable 'comment-start-skip)
  (setq comment-start-skip "||+ *")
  (make-local-variable 'comment-column)
  (setq comment-column 40)
  (make-local-variable 'comment-indent-function)
  (setq comment-indent-function 'mira-comment-indent)
  (make-local-variable 'mira-identifiers)
  (setq mira-identifiers nil)
  (make-local-variable 'write-file-hooks)
  (setq write-file-hooks (cons 'mira-write-file-hook write-file-hooks))
  (make-local-variable 'mira-literate)
  (setq mira-literate
	  (or (and (> (buffer-size) 0)
                   (string= ">" (buffer-substring 1 2)))
	      (and buffer-file-name
                   (string= ".lit.m" (substring buffer-file-name -6)))))
  (make-local-variable 'mira-strict-if)
  (setq mira-strict-if t)
  (mira-idiosyncratic-variables))

(defun mira-idiosyncratic-variables ()
  "Buffer-local variables used exclusively in miranda-mode."
  (make-local-variable 'mira-contour-stack)
  (setq mira-contour-stack (make-vector 40 0))
  (make-local-variable 'mira-contour-stack-top)
  (setq mira-contour-stack-top -1)
  (make-local-variable 'mira-indentation-stack)
  (setq mira-indentation-stack (make-2D-vector 40 4 0))
  (make-local-variable 'mira-indentation-stack-top)
  (setq mira-indentation-stack-top -1)
  (make-local-variable 'mira-indentation-stack-cur)
  (setq mira-indentation-stack-cur -1)
  (make-local-variable 'mira-indent0)
  (setq mira-indent0 3)
  (make-local-variable 'mira-indent1)
  (setq mira-indent1 3)
  (make-local-variable 'mira-indent2)
  (setq mira-indent2 3)
  (make-local-variable 'mira-indent3)
  (setq mira-indent3 3)
  (make-local-variable 'mira-indent4)
  (setq mira-indent4 3)
  (make-local-variable 'mira-indent5)
  (setq mira-indent5 3)
  (make-local-variable 'mira-indent6)
  (setq mira-indent6 0)
  (make-local-variable 'mira-indent7)
  (setq mira-indent7 1))

;;; Entry point to the miranda-mode 

(defun miranda-mode ()
  "Major mode for editing Miranda scripts (literate scripts are also supported).
Its main advantages are:
-its understanding of the layout rule implemented by \\[mira-indent-cycle].
-\\[mira-compile] sends the current script to a Miranda subprocess.
-\\[mira-next-error] parses the error messages.
-\\[mira-man] gives access to the manual
-\\[mira-complete-symbol] can complete symbols in the current script
-\\[mira-find-tag] pops the buffer to the definition of function

Blank lines and `|||...' separate paragraphs. `|||' indented like ;; in Lisp
`||...' starts comments.                      `||'  indented like ; in Lisp
`||||^L' starts pages.                        `||||' at start of line

Commands:\\{miranda-mode-map}
Entry to this mode calls the value of miranda-mode-hook,
where you can, as a user, insert your customisations (e.g. change
the value of mira-strict-if)

Known bugs:
- Miranda permits you to write a single string on multiple lines.
  This is possible because you can escape the carriage-return with a backslash.
  This mode cannot handle this feature nicely, please avoid with ++.
- Character constants that use a single open or close paren on a line
  (e.g. ')' or '[' ) may trouble the indentation.  This is because in Miranda,
  the single quote can also be used within an identifier, but `hd \"(\"' is OK.
"
  (interactive)
  (kill-all-local-variables)
  (use-local-map miranda-mode-map)
  (set-syntax-table miranda-mode-syntax-table)
  (setq major-mode 'miranda-mode)
  (miranda-mode-variables)
  (setq mode-name (if mira-literate "Miranda-lit" "Miranda"))
  (run-hooks 'miranda-mode-hook))

;;; General functions and macros

;;;---------------------------------------------------------------------------
;;; Incrementation and decrementation macros

(defmacro inc (var)
  "Increment VAR by 1."
  (`(setq (, var) (1+ (, var)))))

(defmacro dec (var)
  "Decrement VAR by 1."
  (`(setq (, var) (1- (, var)))))

;;;---------------------------------------------------------------------------
;;; Creation of a two-dimensional vector

(defun make-2D-vector (rows columns &optional init-value)
  "Creates a 2D vector of specified number of ROWS and COLUMNS.
Optional INIT value for all cells."
  (let ((v (make-vector rows nil))
	(i 0))
    (while (< i rows)
      (aset v i (make-vector columns init-value))
      (inc i))
    v))

;;;---------------------------------------------------------------------------
;;; Column of a point.

(defun point-to-column (apoint)
  "Returns the column of a POINT."
  (save-excursion
    (goto-char apoint)
    (current-column)))

;;; Indentation section
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Constant strings of symbols

(defconst mira-lowercase "a-z")
(defconst mira-uppercase "A-Z")
(defconst mira-letters (concat mira-lowercase mira-uppercase))
(defconst mira-digits "0-9")
(defconst mira-id-punct "_'")
(defconst mira-whitespace " \t\n")
(defconst mira-id-regexp
    (concat "[" mira-letters "]"
	    "[" mira-letters mira-digits mira-id-punct "]*"))
(defconst mira-nonescaped-apos-regexp "[^\\]'")
(defconst mira-nonescaped-quote-regexp "\\([^\\]\\|^\\)\"")
(defconst mira-char-const-regexp
    (concat "'"     ; It starts with an '
	    "\\("
	    "[^\\\n]" ; Something other than \ or return
	    "\\|" 
	    "\\\\"    ; or something which starts with \
	    "\\("
	    "."    ; followed by a single character
	    "\\|"
					; or a string of three digits.
	    "["mira-digits"]["mira-digits"]["mira-digits"]"
	    "\\)"
	    "\\)"
	    "'"))   ; and ends with an '
(defconst mira-sym1 "==")
(defconst mira-sym2 "=")
(defconst mira-sym3 "::=")
(defconst mira-sym4 "::")
(defconst mira-sym5 "%")
(defconst mira-sym6 "abstype")
(defconst mira-sym7 "with")
(defconst mira-sym-regexp
  (let ((or "\\)\\|\\("))		; useful macro for next expression
    (concat "\\(" mira-sym1 or mira-sym2 or mira-sym3
               or mira-sym4 or mira-sym5 or mira-sym6 or mira-sym7 "\\)"))
  "All the alternatives have been enclosed in ()'s to take advantage
of the 'matched data' capabilities of emacs-lisp.")

(defun mira-empty-line-regexp ()
  (concat "^" (if mira-literate ">*") "[" mira-whitespace "]*$"))

;;; Functions for the indentation stack

(defun mira-empty-indentation-stack ()
  "Empties the buffer local indentation stack."
  (setq mira-indentation-stack-top -1)
  (setq mira-indentation-stack-cur -1))

(defun mira-init-indentation-rotation ()
  "Settings for the rotation of the indentation stack."
  (setq mira-indentation-stack-cur mira-indentation-stack-top))

(defun mira-indentation-stack-rotate ()
  "Rotates to the next indentation on the stack."
  (dec mira-indentation-stack-cur)
  (if (= -1 mira-indentation-stack-cur)
      (setq mira-indentation-stack-cur mira-indentation-stack-top)))

(defun mira-stack-indentation
    (endcolumn &optional textcolumn textpoint textend)
  "Pushes on the indentation stack the COLUMN number where the cursor should
be placed. Optionaly, a text can be inserted at TEXTCOLUMN.  This text is
to be found between TEXT and TEXTEND, if text is a point.  The text parameter
can also be a string to be inserted as is, in which case the textend parameter
is not considered."
  (let ((entry
	 (aref mira-indentation-stack
	       (inc mira-indentation-stack-top))))
    (aset entry 0 endcolumn)
    (aset entry 1 textcolumn)
    (aset entry 2 textpoint)
    (aset entry 3 textend)))

(defun mira-current-endcolumn ()
  "Based on the current indentation, returns the column number where
the cursor must end, or nil if stack is empty."
  (if (= mira-indentation-stack-cur -1)
      nil
      (aref (aref mira-indentation-stack mira-indentation-stack-cur) 0)))

(defun mira-current-textcolumn ()
  "Based on the current indentation, returns the column number, if
non-nil, where some text must be inserted."
  (if (= mira-indentation-stack-cur -1)
      nil
      (aref (aref mira-indentation-stack mira-indentation-stack-cur) 1)))

(defun mira-current-textpoint ()
  "Based on the current indentation, returns the point where the text
to be inserted is to be found."
  (if (= mira-indentation-stack-cur -1)
      nil
      (aref (aref mira-indentation-stack mira-indentation-stack-cur) 2)))

(defun mira-current-textend ()
  "Based on the current indentation, returns the point ending the
text to be inserted."
  (if (= mira-indentation-stack-cur -1)
      nil
      (aref (aref mira-indentation-stack mira-indentation-stack-cur) 3)))

(defun mira-pop-indentation ()
  "Same as mira-current-endcolumn, with the whole entry being popped."
  (let ((value (mira-current-endcolumn)))
    (if value
	(progn
	  (dec mira-indentation-stack-top)
	  (setq mira-indentation-stack-cur mira-indentation-stack-top)))
    value))

;;;---------------------------------------------------------------------------
;;; Indentation functions based on the indentation stack

(defun mira-indent (add-lit)
  "Indents in accord with the indentation stack. Returns the number of
chars inserted by this indentation. If ADD-LIT is true then it inserts a >
at the start of the line"
  (let ((text-col (mira-current-textcolumn))
	(text-pt  (mira-current-textpoint))
	(indent-length 0))
    (beginning-of-line)
    (if (and add-lit (looking-at ">"))
        (delete-char 1))
    (delete-horizontal-space)
    (if text-col
      (let ((str (or (and (stringp text-pt) text-pt)
		     (and (not text-pt) "")
		     (buffer-substring text-pt (mira-current-textend)))))
	(if (and add-lit (>= text-col 2))
            (progn
              (insert "> ")
              (insert-char ?\  (- text-col 2)))
          (insert-char ?\  text-col))
	(setq indent-length (+ indent-length text-col))
	(if (looking-at str)
            (forward-char (length str)) ; skip over existing text
          (progn
            (insert str)
            (setq indent-length (+ indent-length (length str)))))
        (if (looking-at "[ \t]*$")
            (let ((bl (- (mira-current-endcolumn) (current-column))))
              (insert-char ?\  bl)
              (setq indent-length (+ indent-length bl)))))
      (let ((bl (- (mira-current-endcolumn) (current-column))))
	(if (and add-lit (>= bl 2))
            (progn
              (insert "> ")
              (insert-char ?\  (- bl 2)))
          (insert-char ?\  bl))
        (setq indent-length (+ indent-length bl))))
    indent-length))

;;; Functions for the contour stack

(defun mira-empty-contour-stack ()
  "Empties the buffer local contour stack."
  (setq mira-contour-stack-top -1))

(defun mira-stack-contour (value)
  "Pushes a value on top of the contour stack."
  (inc mira-contour-stack-top)
  (aset mira-contour-stack mira-contour-stack-top value))

(defun mira-current-contour ()
  "Returns the current value on top of the contour stack, or nil
if stack is empty."
  (if (= mira-contour-stack-top -1)
      nil
      (aref mira-contour-stack mira-contour-stack-top)))

(defun mira-pop-contour ()
  "Same as mira-current-contour except that the top of the stack is popped."
  (let ((value (mira-current-contour)))
    (if value
	(dec mira-contour-stack-top))
    value))

;;;---------------------------------------------------------------------------
;;; Updating the contour line

(defun mira-update-contour-stack (column)
  "Pops from the contour stack the points which lie on the left of
a given COLUMN.  Returns t if current contour column matches, nil
otherwise."
  (while (and (mira-current-contour)
	      (< (point-to-column (mira-current-contour)) column))
    (mira-pop-contour))
  (and (mira-current-contour)
       (= (point-to-column (mira-current-contour)) column)))


;;;---------------------------------------------------------------------------
;;; Determination of the contour line

(defun mira-contour-line (end start)
  "Generates contour information between END and START points.
The information is stored in the buffer-local contour stack."
  (save-excursion
    (let ((cur-column 1024)
	  (top-reached nil))
      (mira-empty-contour-stack)
      (goto-char end)
      (mira-skip-white-backwards start)
      (mira-beginning-of-line)
      (mira-skip-white end)
      ;; We stack the contour until the start point is trespassed.
      (catch 'top-of-buffer
             (while (and (>= (point) start) (not top-reached))
               (if (and (< (current-column) cur-column)
                        (not (looking-at comment-start)))
                   (progn
                     (mira-stack-contour (point))
                     (setq cur-column (current-column))))
               (setq top-reached (<= (point) start))
               (if (= (mira-forward-line -1) -1)
                   (throw 'top-of-buffer nil))
               (mira-skip-white end)))
      )))

;;; Search and moving around

(defun mira-find-follower (apoint &optional limit)
  "Searches for the next non-whitespace character, starting at POINT,
optionally accepting a limit.  Returns nil if stopped on or after the limit."
  (save-excursion
    (if (not apoint)
	nil
      (goto-char apoint)
      (while
	  (progn
	    (mira-skip-white limit)
            (if (and mira-literate (bolp) (looking-at ">"))
                (progn (forward-char 1)
                       (mira-skip-white limit)))
	    (if (looking-at comment-start)
		(mira-forward-line 1))))
      (if (and limit (>= (point) limit))
	  nil
	(point)))))

;;;---------------------------------------------------------------------------
;;; Skipping whitespace

(defun mira-skip-white (&optional limit)
  "Moves point before nearest non-whitespace character (forward).
Optional LIMIT."
  (skip-chars-forward mira-whitespace limit))

(defun mira-skip-white-backwards (&optional limit)
  "Moves point after nearest non-whitespace character (backward).
Optional LIMIT."
  (skip-chars-backward mira-whitespace limit))

;;;---------------------------------------------------------------------------
;;; Legal miranda identifier extraction

(defun mira-extract-identifier (&optional apoint)
  "Returns a string of the identifier currently following the point (or the
POINT you supply.  Returns nil if none."
  (save-excursion
    (if apoint (goto-char apoint))
    (if (not (looking-at mira-id-regexp))
	nil
	(buffer-substring (match-beginning 0) (match-end 0)))))

;;;---------------------------------------------------------------------------
;;; End of identifier

(defun mira-end-of-id (apoint)
  "Given a POINT at the beginning of a legal Miranda identifier, returns
the corresponding end point."
  (save-excursion
    (goto-char apoint)
    (if (looking-at mira-id-regexp)
	(match-end 0)
	nil)))

;;;---------------------------------------------------------------------------
;;; Matched expression

(defun mira-matched-exp (from to)
  "After a regular expression search, this function is called to find
the index of the matched expression between FROM and TO.
e.g. (mira-matched-exp 1 8)."
  (if (match-beginning 0)
      (let ((number nil)
	    (i from))
	(while (and (not number)
		    (<= i to))
	  (if (match-beginning i)
	      (setq number i))
	  (inc i))
	number)
      nil))

;;; Context

(defun mira-point-in-string (apoint)
  "True if POINT is enclosed in a string."
  (save-excursion
    (goto-char apoint)
    (mira-beginning-of-line)
    (let ((num-quotes 0))
      (while (re-search-forward mira-nonescaped-quote-regexp apoint t)
	(if (= 0 (% num-quotes 2))
	    (if (not (mira-point-in-char (point)))
		(inc num-quotes))
	    (inc num-quotes)))
      (= 1 (% num-quotes 2)))))

(defun mira-point-in-char (apoint)
  "True if POINT is enclosed in a char constant.
May be fooled by uncommon identifiers like pos'2'3."
  (save-excursion
    (goto-char apoint)
    (mira-beginning-of-line)
    (store-match-data ())
    (while (and (re-search-forward mira-char-const-regexp nil t)
		(< (match-end 0) apoint)))
    (and (match-beginning 0)
	 (< (match-beginning 0) apoint)
	 (> (match-end 0) apoint))))

(defun mira-find-comment ()
  "Returns the point of the comment on the current line, or nil."
  (save-excursion
    (let (end found)
      (setq end (progn (end-of-line) (point)))
      (beginning-of-line)
      (if (and mira-literate (not (looking-at ">")))
          (progn
            (mira-skip-white)
            (point))
        (while (and (< (point) end)
                    (not found)
                    (search-forward comment-start end t))
          (if (not (mira-point-in-string (point)))
              (setq found (- (point) 2))))
        found
        ))))

(defun mira-point-in-comment (apoint)
  "True if POINT is in a comment"
  (save-excursion
    (let (com-pt)
      (goto-char apoint)
      (if (not (setq com-pt (mira-find-comment)))
	  nil
	  (< com-pt apoint)))))

(defun mira-non-meaningful-context (apoint)
  "True if POINT is enclosed in a string or char constant,
or in a comment section."
  (or (mira-point-in-string apoint)
      (mira-point-in-char apoint)
      (mira-point-in-comment apoint)))

;;;---------------------------------------------------------------------------
;;; Definition special-symbol detection

(defun mira-search-special-symbol (from to)
  "Finds the nearest of the following symbols:
1) ==   2) =  3) ::=  4) ::  5) %  6) abstype  7) with
and returns the symbol-number, or nil if none found.
Use (match-beginning 0) and (match-end 0) for the location
of the symbol found."
  (save-excursion
    (let (data finished)
      (goto-char from)
      (while (not finished)
	(store-match-data nil)
	(re-search-forward mira-sym-regexp to t)
	(setq finished (or (not (setq data (match-data)))
			   (not (mira-non-meaningful-context (point))))))
      (if (not data)
	  nil
	  (store-match-data data)
	  (mira-matched-exp 1 7)))))
;;;---------------------------------------------------------------------------
;;; Definition special-symbol detection

(defun mira-search-keyword (keyword from to)
  "Finds the nearest KEYWORD, FROM a buffer position TO another.
Returns it's buffer position or nil.  You can use the
matching data facilities afterwards."
  (save-excursion
    (goto-char from)  ; particularly important because of the recursive calls
    (cond ((> (+ from (length keyword)) to) nil)
	  ((not (search-forward keyword to t)) nil)
	  (t (let ((data (match-data))
		   (pos (match-beginning 0))
		   (pps (parse-partial-sexp from (point))))
	       (cond ( (> (nth 0 pps) 0) ; in parentheses
		       (if (nth 3 pps)   ; if in a string get out of it before
			   (search-forward (char-to-string (nth 3 pps)) to))
		       (mira-search-keyword keyword ; going out of the parens
					    (scan-lists (point) 1 (nth 0 pps))
					    to ))
		     ( (nth 3 pps)	; in a string
		       (search-forward (char-to-string (nth 3 pps)) to)
		       (mira-search-keyword keyword (point) to))
		     ( (mira-point-in-comment (point))
		       (mira-search-keyword keyword
					    (save-excursion (end-of-line)
							    (point))
					    to))
		     ( t
		       (store-match-data data) pos))
	       )))))

;;; Determining some limit to our search for indentation clues.

(defun mira-start-point ()
  "Returns point of the current top-level function.
The point must be somewhere in the function, or on the empty line
lying immediately after it.  Returns nil if we are not on a function."
  (save-excursion
    (let ((here (point)))
      ;; The search starts on the preceding line, if this one is empty.
      (if (save-excursion
            (mira-beginning-of-line) (looking-at (mira-empty-line-regexp)))
	  (mira-forward-line -1))
      (if (looking-at (mira-empty-line-regexp))
	  nil
        ;; First limit: the empty line or the beginning of the buffer.
        (if (re-search-backward (mira-empty-line-regexp) nil t)
            (mira-forward-line 1)
          (beginning-of-buffer))
        ;; Search for the real limit.
        (mira-skip-white)
        (while (looking-at comment-start)
          (mira-forward-line 1)
          (mira-skip-white here))
        ;; Let's see if there is no function here
        (if (and (= (point) here)
                 (looking-at "[ \t]*$"))
            nil
          (point))))))

;;;---------------------------------------------------------------------------
;;; Search for the end of the current function.

(defun mira-end-point ()
  "Returns the end point of the current top-level function.
The point must be somewhere in the function, or on the empty line
lying immediately after it.  Returns nil if we are not on a function."
  (save-excursion
    (let ((here (point)))
      ;; The search starts on the beginning of this line
      (mira-beginning-of-line)
      (if (not (re-search-forward (mira-empty-line-regexp) nil t))
	  nil
	  (mira-skip-white-backwards here)
	  (point)))))

;;;---------------------------------------------------------------------------
;;; Detection of opened structures

(defun mira-open-structure (end start)
  "If any structure (list or tuple) is not closed, between the END and START
points, this functions returns the location of the opening symbol, nil otherwise."
  (save-excursion
    (let ((pps (parse-partial-sexp start end)))
      (if (> (nth 0 pps) 0)
	  (nth 1 pps)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Stacking informations about indentation

(defun mira-indentation-info (end start)
  "Generates indentation information for the code between END and START
points. This information is stored in the buffer-local indentation stack."
  (save-excursion
    (mira-empty-indentation-stack)
    ;; Maybe there is no function nearby
    (if (or (not start)
	    (>= start end))
	(progn
	  (mira-stack-indentation 0)
	  (mira-stack-indentation mira-indent0))
      (let (id open contour contour-col follow end-of-id match-b match-e)
	(if (setq open (mira-open-structure end start))
	    ;; Priority to this unclosed structure
	    (if (setq follow (mira-find-follower (1+ open) end))
		(mira-stack-indentation (point-to-column follow))
	      (mira-stack-indentation
	       (+ mira-indent5 (point-to-column open))))
	  ;; All structures are closed, we can continue
	  (mira-contour-line end start)
	  ;; Let's check if any top-level contour has been detected
	  (if (setq contour (mira-pop-contour))
	      (progn
		(setq contour-col (point-to-column contour))
		;; then we search for some definition separator
		(setq id (mira-search-special-symbol contour end))
		(setq match-b (match-beginning 0))
		(setq match-e (match-end 0))
		(cond
		 ((not id)    ; No special-symbol (default: function def.)
		  (mira-function-definition contour nil nil end))
		 ((= id 2)		; Function definition =
		  (mira-function-definition contour
					    match-b match-e end))
		 ((or (= id 1)		; Type synonym ==
		      (= id 3))		; Algebraic type definition ::=
		  (if (setq follow (mira-find-follower match-e end))
		      (progn
			(mira-stack-indentation contour-col)
			(mira-stack-indentation (point-to-column follow)))
		    (mira-stack-indentation (+ (point-to-column contour)
					       mira-indent1))))
		 ((= id 4)		; Type specification ::
		  (if (setq follow (mira-find-follower match-e end))
		      (if (save-excursion
			    (goto-char follow) (looking-at "type"))
			  (mira-stack-indentation contour-col)
			(mira-stack-indentation contour-col)
			(mira-stack-indentation
			 (1+ (point-to-column
			      (setq end-of-id (mira-end-of-id contour))))
			 contour-col contour end-of-id)
			(mira-stack-indentation (point-to-column follow)))
		    (mira-stack-indentation (+ (point-to-column contour)
					       mira-indent1))))
		 ((= id 5)		; Library directive %
		  (mira-stack-indentation (point-to-column contour))
		  (mira-stack-indentation (1+ (point-to-column contour))
					  (point-to-column contour)
					  "%" nil))
		 ((or (= id 6)		; Abstract type definition
		      (= id 7))		; with keyword
		  (mira-abstype-definition match-b match-e end))))))))))

;;;---------------------------------------------------------------------------
;;; Stacking indentations for abstract types

(defun mira-abstype-definition (abs-pt abs-end-pt end)
  "Given the POINT of the 'abstype' symbol, its END-POINT, and a LIMIT
for our searches, stacks some indentation information."
  (save-excursion
    (let ((with-pt (mira-search-keyword "with" abs-pt end)))
      (goto-char abs-pt)
      (if with-pt			; is there a "with" keyword?
	  (let ((with-col (point-to-column with-pt))
		follower)
	    (if (setq follower (mira-find-follower (+ 4 with-pt) end))
		;; "with" is not alone
		(progn
		  (mira-stack-indentation with-col)
		  (mira-stack-indentation (point-to-column follower)))
	      ;; Prepare indentation for first type specification
	      (mira-stack-indentation (+ with-col mira-indent2))))
	;; No "with"
	(let (follower)
	  (if (setq follower (mira-find-follower abs-end-pt end))
	      ;; There is a follower
	      (progn
		(mira-stack-indentation
		 (+ 5 (point-to-column abs-pt))
		 (point-to-column abs-pt) "with")
		(mira-stack-indentation (point-to-column follower)))
	    ;; Nothing follows
	    (mira-stack-indentation
	     (+ mira-indent2 (point-to-column abs-pt)))))))))

;;;---------------------------------------------------------------------------
;;; Stacking indentations for functions

(defun mira-function-definition (fun-name-pt def-sign-pt def-sign-end-pt end)
  "Given a POINT1 on the function name; a POINT2 on the equal sign and a POINT3
on the its end; and a last point to LIMIT our searches, this function pushes
information onto the buffer-local indentation stack about Miranda function
definitions."
  (save-excursion
    (let (empty where eql comment guard ; info about current line
	  fun-col arg-pt arg-col  ; info about current function
	  fol-pt fol-col guard-pt fol-guard-pt where-pt)
      ;; look for information about the start of current line
      (goto-char end)
      (mira-beginning-of-line)
      (if (looking-at (mira-empty-line-regexp))
	  (setq empty t)
	(mira-skip-white end)
	(cond ((setq where (looking-at "where")))
	      ((setq eql   (looking-at "= ")))
	      ((setq guard (looking-at ",")))
	      ((setq comment (looking-at comment-start)))))
      (setq fun-col (point-to-column fun-name-pt))
      ;; get information about the current function
      (goto-char fun-name-pt)
      ;; Is there any argument to this function?
      (setq arg-pt (mira-find-follower (mira-end-of-id fun-name-pt) end))
      (if arg-pt
	  (if (and def-sign-pt (= arg-pt def-sign-pt))
	      (setq arg-pt nil)
	    (setq arg-col (point-to-column arg-pt))))
      (cond
       ((not def-sign-pt)		;function without equal sign
	(mira-empty-indentation-stack)
	(if arg-pt
	    (mira-stack-indentation arg-col)
	  (mira-stack-indentation (+ fun-col mira-indent3)))
	(mira-stack-indentation (+ 2 mira-indent3 fun-col)
				(+ mira-indent3 fun-col)
                                "= "))
					;
       ((not (setq fol-pt (mira-find-follower def-sign-end-pt end)))
	;; No follower, so we will wait for one
	(mira-stack-indentation (+ mira-indent1 fun-col)))
					;
       (t;; There is a follower to the equal sign
	(if (not (or where eql comment guard)) ; current line is not special
	    (progn (mira-stack-indentation fun-col) ; stack function name
		   (if arg-pt (mira-stack-indentation ;     and its args
			       arg-col fun-col fun-name-pt
			       (mira-end-of-id fun-name-pt)))))
	(cond
	 ((setq where-pt (mira-search-keyword "where" fol-pt end))
	  ;; there is a where
	  (if (setq fol-pt (mira-find-follower (+ 5 where-pt) end))
	      ;; Something after the "where":   recursive call
	      (apply 'mira-function-definition
		     (setq fun-name-pt
			   (if (mira-update-contour-stack
				(point-to-column fol-pt))
			       (mira-current-contour)
			     fol-pt))
		     (if (mira-search-keyword "="  fun-name-pt end)
			 (list (match-beginning 0) (match-end 0) end)
		       (list nil nil end)))
	    ;; Nothing follows the "where".  Must wait for something.
	    (mira-empty-indentation-stack)
	    (mira-stack-indentation (point-to-column where-pt))))
	 (t;; No "where", so it's time to consider the guards
	  (mira-update-contour-stack (1+ fun-col))
	  (if (mira-current-contour)
	      (goto-char (mira-current-contour)))
	  (if (looking-at "=")
	      (progn
		(setq def-sign-end-pt
		      (+ (point) (- def-sign-end-pt def-sign-pt)))
		(setq def-sign-pt (point))))
	  (if eql
	      (mira-stack-indentation (point-to-column def-sign-pt))
	    (if (setq guard-pt
		      (mira-search-keyword "," def-sign-end-pt end))
		(if guard
		    (mira-stack-indentation (point-to-column guard-pt))
		  ;; There is a guard, but is there something after it?
		  (if (setq fol-guard-pt
			    (mira-find-follower (1+ guard-pt) end))
		      ;; There is something after the guard
		      (progn 
			(goto-char fol-guard-pt)
			;; "otherwise" indicates the last case
			(if (or where (looking-at "otherwise"))
			    (mira-stack-indentation ; stack a "where"
			     (+ 6 (point-to-column fol-pt))
			     (point-to-column fol-pt)
			     "where")
			  (progn	; stack end of guard and definition
			    (mira-stack-indentation
			     (1+ (point-to-column def-sign-end-pt))
			     (point-to-column def-sign-pt)
			     def-sign-pt def-sign-end-pt)
			    (mira-stack-indentation
			     (+ (point-to-column fol-guard-pt)
				(if (looking-at "if ") 3 0))))))
		    ;; Nothing after the guard: priority wait
		    (progn
		      (mira-empty-indentation-stack)
		      (mira-stack-indentation
		       (+ mira-indent4 (1+ (point-to-column guard-pt)))))))
	      ;; No guard.
	      (mira-stack-indentation (point-to-column fol-pt)))))
	 )))
      ;; Puts another indentation on the stack if the current line
      ;; starts with a comment
      (if comment
	(let ((pos (progn (goto-char end)
                          (mira-forward-line -1)
                          (mira-find-comment))))
	  (if pos
	      (mira-stack-indentation (point-to-column pos))
	    (mira-stack-indentation comment-column))))
      )))


;;; Patterns and guards alignment

(defun mira-shift-columns (dest-column)
  "Shifts columns in contour stack according to a DESTINATION-COLUMN.
The contour stack elements are pairs of points indicating the region to
be moved."
  (let (pts col diffcol top)
    (catch 'top-of-buffer
           (while (setq pts (mira-pop-contour))
             (setq top (car pts))
             (setq col (point-to-column top))
             (goto-char (cdr pts))
             (setq diffcol (- dest-column col))
             (if (not (zerop diffcol))
                 (while (>= (point) top)
                   (if (< diffcol 0)
                       (backward-delete-char-untabify (- diffcol) nil)
                     (insert-char ?\  diffcol))
                   (if (= (mira-forward-line -1) -1)
                       (throw 'top-of-buffer nil))
                   (move-to-column col)))
             ))
    ))

(defun mira-spaces-before ()
  "Returns t if the current line has only spaces before point, nil otherwise"
  (let ((beg (save-excursion
               (mira-beginning-of-line) (point))))
    (and (string-match "^[ \t]*$" (buffer-substring beg (point)))
         t)))

(defun mira-current-function-start ()
  "Returns a list of information about the function around point, nil 
if no function can be found. The list contains the function name, the column
where it is indented and a list of the positions of the start of each
equation of the function.  All lines of the function
should start at the same column."
  (let ((limit (point))
        (start (mira-start-point))
        cfstart cfstarts cfcol cfname s)
    (if start
        (save-excursion
          (mira-contour-line limit start)
          ;; take elements of the contour stack in reverse...
          (while (mira-current-contour)
            (setq s (cons (mira-pop-contour) s)))
          (while (and s (not cfname))
            (setq cfstart (car s))
            (setq cfname (mira-extract-identifier cfstart))
            (setq s (cdr s)))
          (if cfname
              (progn
                (goto-char cfstart)
                (setq cfcol (point-to-column cfstart))
                (setq cfstarts (list cfstart))
                (catch
                    'top-of-buffer
                    (while (and (> (point) start)
                                (mira-spaces-before))
                      (if (= (mira-forward-line -1) -1)
                          (throw 'top-of-buffer nil))
                      (move-to-column cfcol)
                      (if (not (mira-point-in-comment (point)))
                          (if (and
                               (looking-at (concat cfname "[ \t]"))
                               (not (save-excursion
                                          (goto-char (mira-find-follower
                                                           (mira-end-of-id (point))))
                                          (looking-at "::")))
                               )
                              (setq cfstarts (cons (point) cfstarts))))))
                (list cfname cfcol cfstarts)))))))

(defun mira-stack-regions-to-align (sym withinsym col starts)
  "Stacks, on the contour stack, pairs giving the start and the end of the
columns to be shifted."
  (let ((end (point))
        (destcol 0)
        top limit lastpt cfstart symcol)
    (save-excursion
      (mira-empty-contour-stack)
      (while starts
        (setq cfstart (car starts))   ; start of current function
        (setq starts (cdr starts))
        (setq limit (or (car-safe starts) ; end of the current function
                        end))
        (goto-char cfstart)
        (while (< (point) limit)
          (if (mira-point-in-comment (point))
              (progn (mira-forward-line)
                     (move-to-column col))
            (if (looking-at withinsym)
                (progn
                  (while (setq top (mira-search-keyword sym (point) limit))
                    (goto-char (setq lastpt top))
                    (setq symcol (current-column))
                    (save-excursion     ; find destination column
                      (skip-chars-backward " \t")
                      (setq destcol
                            (max destcol
                                 (if (bolp)
                                     mira-indent1
                                   (+ mira-indent7 (current-column))))))
                    (progn (mira-forward-line)
                           (move-to-column symcol))
                    ;; find all lines indented farther than col
                    (while (and (< (point) limit) 
                                (mira-spaces-before))
                      (setq lastpt (point))
                      (progn (mira-forward-line)
                             (move-to-column symcol)))
                    (mira-stack-contour (cons top lastpt))
                    ;; go to the end of the last line of the region
                    (goto-char lastpt)
                    (end-of-line))
                  (goto-char limit))
              (goto-char limit))))
        ))
    destcol))

;;; Interactive functions

;;;---------------------------------------------------------------------------
;;; Indentation cycle

(defun mira-indent-cycle ()
  "Indentation cycle.
We stay in the cycle as long as the TAB key is pressed.
Any other key exits from the cycle and is interpreted, with
the exception of the RET key which is the way to exit
without any other treatment."
  (interactive "*")
  (let (com number indent-length
        (pos (point))
        (add-lit (and mira-literate
                      (save-excursion (forward-line -1)
                                      (looking-at ">")))))
    (mira-beginning-of-line)
    ;; If we are indenting some text, we compute the offset from the eoln.
    (if (looking-at (mira-empty-line-regexp))
        (setq pos nil)
      (save-excursion (end-of-line) (setq pos (- (point) pos)))
      (mira-skip-white))
    (mira-indentation-info (point) (mira-start-point))
    (mira-init-indentation-rotation)
    (setq number (1+ mira-indentation-stack-top))
    (setq indent-length (mira-indent add-lit))
    (if pos
	(progn (end-of-line)
	       (if (<= (current-column) pos)
		   (mira-beginning-of-line)
		 (backward-char pos))))
    (if (= number 1)
	(message "Sole indentation.")
      (message (format "Indent cycle (%d)..." number))
      (while (equal (event-basic-type (setq com (read-event))) 'tab)
	(beginning-of-line)
	(delete-char indent-length)
	(mira-indentation-stack-rotate)
	(setq indent-length (mira-indent add-lit))
	(if pos
	    (progn (end-of-line)
		   (if (<= (current-column) pos)
		       (mira-beginning-of-line)
		     (backward-char pos))))
	(message "indenting..."))
      (if (not (equal (event-basic-type com) 'return))
            (setq unread-command-events (list com)))
      (message "done."))))
    
;;;---------------------------------------------------------------------------
;;; Moving the cursor at the beginning of the current function

(defun mira-beginning-of-function ()
  "Moves the point at the beginning of the current top-level function."
  (interactive)
  (let ((start (mira-start-point)))
    (if start
	(progn
	  (goto-char start)
	  (message "Function start location."))
	(message "No function nearby."))))

;;;---------------------------------------------------------------------------
;;; Moving the cursor at the end of the current function

(defun mira-end-of-function ()
  "Moves the point at the end of the current top-level function."
  (interactive)
  (let ((end (mira-end-point)))
    (if end
	(progn
	  (goto-char end)
	  (message "Function end location."))
	(message "No function nearby."))))

;;;---------------------------------------------------------------------------
;;; Marking the current function

(defun mira-mark-function ()
  "Marks the end and moves the point on the first column of the first line
of the current top-level function."
  (interactive)
  (let (start end)
    (if (setq start (mira-start-point))
	(progn
	  (push-mark (mira-end-point) 'nomsg)
	  (goto-char start)
	  (mira-beginning-of-line) ; many commands require the point there.
	  (message "Function marked."))
	(message "No function nearby."))))

;;;---------------------------------------------------------------------------
;;; Alignment functions

(defun mira-align-patterns ()
  "Aligns the patterns within lines of a function."
  (interactive "*")
  (save-excursion
        (if (not (eolp))
            (end-of-line))
        ;; Uses the contour stack for the job.
        (let ((cf (mira-current-function-start)))
          (if cf
              (mira-shift-columns (apply 'mira-stack-regions-to-align "=" cf))
            (message "no function found with patterns to align")))))

(defun mira-align-guards ()
  "Aligns the guards within lines of a function."
  (interactive "*")
  (save-excursion
    (if (not (eolp))
        (end-of-line))
    ;; Uses the contour stack for the job.
    (let ((cf (mira-current-function-start)))
      (if cf
          (mira-shift-columns (apply 'mira-stack-regions-to-align "," cf))
        (message "no function found with guards to align")))))

;;; Insertions of symbols
;;;---------------------------------------------------------------------------
;;; Where keyword insertion

(defun mira-insert-where ()
  "Places the `where' keyword at point."
  (interactive "*")
  (insert "where "))

;;;---------------------------------------------------------------------------
;;; Insertion of the equal sign of the pattern.

(defun mira-insert-equal ()
  "Inserts an equality sign for the current pattern, at the end of the
current line.  Automatically aligns the other patterns for the same function
if NO argument is supplied interactively."
  (interactive "*")
  (insert "= ")
  (if (not current-prefix-arg)
      (save-excursion (mira-align-patterns))))

;;;---------------------------------------------------------------------------
;;; Insertions of the guard and of the otherwise keyword

(defun mira-insert-guard ()
  "Inserts a guard at the end of the current line if there is not one already.
Aligns the guards afterwards if NO argument is supplied interactively.
DO NOT use it to jump on the current guard."
  (interactive "*")
  (if mira-strict-if
      (insert ", if ")
    (insert ", "))
    (if (not current-prefix-arg)
	(save-excursion (mira-align-guards))))  

(defun mira-insert-otherwise ()
  "Inserts a guard (see the documentation for 'mira-insert-guards') and then
follows it with the keyword 'otherwise'.  Aligns the guards if NO argument
is supplied interactively."
  (interactive "*")
  (insert ", otherwise")
  (if (not current-prefix-arg)
      (save-excursion (mira-align-guards))))

;;; Functions for comments
;;;    uses the same convention as Lisp

(defun mira-comment-indent ()
  (if (looking-at "||||")
      (if mira-literate 2 0)
    (if (looking-at "|||")
	(progn
	  (mira-indentation-info (point) (mira-start-point))
	  (mira-init-indentation-rotation)
	  (mira-pop-indentation) ; skip usual comment indentation
	  (mira-current-endcolumn))
      (skip-chars-backward " \t")
      (max (if (bolp)
               (if mira-literate 2 0)
             (1+ (current-column)))
	   comment-column))))

(defun mira-comment-region (beg-region end-region arg)
  "Comments every line in the region.
Puts mira-comment-region at the beginning of every line in the region. 
BEG-REGION and END-REGION are args which specify the region boundaries. 
With non-nil ARG, uncomments the region."
  (interactive "*r\nP")
  (save-excursion
        (mira-prefix-lines-in-region
              (if mira-literate "> ||=" "||=")
              beg-region end-region arg)
        ))

(defun mira-prefix-lines-in-region (prefix beg-region end-region  arg)
  "Add a PREFIX to every complete line in the region.
Puts mira-comment-region at the beginning of every line in the region. 
BEG-REGION and END-REGION are args which specify the region boundaries. 
With non-nil ARG, unprefix the region."
  (goto-char beg-region)
  (if (not (bolp))                      ; if not at the beginning of a line
      (progn (forward-line 1) (setq beg-region (point)))) ;go to the next line
  ;; start from the end and move up 
  (goto-char end-region)
  (if (bolp)
      (forward-line -1)
    (beginning-of-line))
  (if arg
      (let ((lp (length prefix)))
        (while (>= (point) beg-region)
          (if (looking-at prefix)
              (delete-char lp))
          (forward-line -1)))
    (while (>= (point) beg-region)
      (insert prefix)
      (forward-line -1)))
  )

;;; Literate mode (it is not a real minor mode but a flag in miranda-mode)

(defun miranda-lit-mode (arg)
  "Toggle Miranda literate mode
With arg, turn Miranda  mode on iff arg is positive."
  (interactive "P")
  (if (null arg)
      (setq mira-literate (not mira-literate))
    (setq mira-literate (> (prefix-numeric-value arg) 0)))
  (setq mode-name (if mira-literate "Miranda-lit" "Miranda"))
  (set-buffer-modified-p (buffer-modified-p));; update mode-line
  )

(defun mira-put-region-in-lit-code (beg-region end-region arg)
  "Inserts `> ' before every line in the region.
BEG-REGION and END-REGION are args which specify the region boundaries.
Useful for importing code into literate scripts.
With non-nil ARG, removes `> ' from the region. Useful for exporting code
from literate scripts."
  (interactive "*r\nP")
  (save-excursion
        (mira-prefix-lines-in-region
              "> "
              beg-region end-region arg)
        ))

(defun mira-beginning-of-line (&optional count)
  "Move point to beginning of current Miranda line (in literate mode or not).
With argument ARG not nil or 1, move forward ARG - 1 lines first.
If scan reaches end of buffer, stop there without error."
  (interactive)
  (prog1
      (beginning-of-line count)
    (if (and mira-literate (looking-at ">"))
        (forward-char 1))))

(defun mira-forward-line (&optional count)
  "If point is on line i, move to the start of Miranda line i + ARG (literate
mode or not.  If there isn't room, go as far as possible (no error).
Returns the count of lines left to move.
With positive ARG, a non-empty line at the end counts as one line
  successfully moved (for the return value)."
  (interactive)
  (prog1
      (forward-line count)
    (if (and mira-literate (looking-at ">"))
        (forward-char 1))))

;;; Fill mode
;; hack here to implement some form of dynamic scoping of functions...
(fset 'old-indent-new-comment-line (symbol-function 'indent-new-comment-line))

(defun indent-new-comment-line ()
  (interactive "*")
  (if (eq major-mode 'miranda-mode)
      (mira-indent-new-comment-line)
    (old-indent-new-comment-line)))

(defun mira-indent-new-comment-line ()
  "Break line at point and indent, continuing comment if presently within one.
The body of the continued comment is indented under the previous comment line."
  ;; this is a replacement of the usual function (from simple.el) to be used
  ;; in miranda-mode
  (let ((mc (mira-find-comment))
        mcc start)
    (if mc
        (progn
          (delete-horizontal-space)               ; kill current space
          (setq mcc (point-to-column mc))
          (if (save-excursion           ; check if there is a real comment
                    (goto-char mc)
                    (looking-at comment-start-skip))
              (if mira-literate
                  (insert "\n> "        ; real comment in literate
                          (make-string (max (- mcc 2)) ?\ )
                          (buffer-substring (match-beginning 0) (match-end 0)))
                (insert "\n"            ; real comment not in literate
                        (make-string mcc ?\ )
                        (buffer-substring (match-beginning 0) (match-end 0))))
            (insert "\n" (make-string mcc ?\ ))) ; plain text in literate
          ))))


(defun mira-auto-fill-mode (arg)
  "Toggle mira-auto-fill mode.
With arg, turn mira-auto-fill mode on iff arg is positive.
In auto-fill mode, inserting a space at a column beyond  fill-column
automatically breaks the line at a previous space."
  ;; copied almost verbatim from simple.el
  (interactive "P")
  (prog1 (setq auto-fill-function
	       (if (if (null arg)
		       (not auto-fill-function)
		       (> (prefix-numeric-value arg) 0))
		   'mira-do-auto-fill
		   nil))
    ;; update mode-line
    (set-buffer-modified-p (buffer-modified-p))))

(defun mira-do-auto-fill ()
  "Auto fill for Miranda programs should only apply to comments."
  (if (mira-find-comment)
      (do-auto-fill)))


;;; Inferior mira mode by Tim Lambert
;;;
;;; Modified to
;;; - Remove the client facilities.
;;; - Handle compilation errors.

(defvar inferior-mira-program "/usr/local/bin/mira"
  "*Where the Miranda interpreter lives on your system.")

(defvar mira-current-script "script.m"
  "Name of script inferior mira is looking at.
This should be updated when the user types /file,
but it currently isn't.")

(defvar mira-error-marker nil
  "Marker for the next Miranda error.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     Handling of error messages
;;;     

(defvar mira-new-errors t
  "True if a script has been compiled and new errors may have
been discovered.")

(defconst  mira-type-error-re
    "^(line\\([ 0-9]+\\) of \"\\([^\"]*\\)\")[ ]+\\([^\n]*\\)$"
  "Regular expression to retrieve type error parameters.")

(defconst  mira-syntax-error-re
    "^syntax error\\([^\n]*\\)\n.*line\\([ 0-9]+\\).* \"\\([^\"]*\\)\""
  "Regular expression to retrieve syntax error parameters.")

(defconst  mira-un-error-re
    "^\\([^(\n]+\\)(line\\([ 0-9]+\\).* \"\\([^\"]*\\)\""
  "Regular expression to retrieve error parameters.")

(defconst  mira-two-lines-error-re
    "^\\([^\n]+\\)\n(line\\([ 0-9]+\\).*\"\\([^\"]*\\)\")$"
  "Regular expression to retrieve two lines error parameters.")

(defun mira-reset-next-error ()
  "Resets the marker for the next error."
  (save-excursion
    (set-buffer "*mira*")
    (end-of-buffer)
    (if (re-search-backward "^Miranda compiling \\|^compiling" nil t)
	(setq mira-error-marker (point-marker))
      (setq mira-error-marker nil))))

(defun mira-next-error ()
  "Goes to the next error indicated in the inferior Miranda buffer."
  (interactive)
  (if mira-new-errors
      (progn
	(setq mira-new-errors nil)
	(setq mira-compiling-mark (copy-marker (mira-reset-next-error)))))
  (let (error-found source-filename source-line source-error buffer)
    (if (not mira-error-marker)
	(error "Please compile first.")
      (set-buffer (marker-buffer mira-error-marker))
      (goto-char (marker-position mira-error-marker))
      (pop-to-buffer (current-buffer))
      (recenter 0)
      (while (and (not source-line) (< (point) (buffer-end 1)))
	(cond
	 ((looking-at mira-type-error-re)
	  (setq source-line
		(string-to-int
			(buffer-substring (match-beginning 1) (match-end 1))))
	  (setq source-filename
		(buffer-substring (match-beginning 2) (match-end 2)))
	  (setq source-error
		(buffer-substring (match-beginning 3) (match-end 3)))
          (save-excursion
            (if (re-search-backward "^warning, \\(.*\\)"
                                    (marker-position mira-compiling-mark)
                                    t)
                (setq source-error
                      (concat (buffer-substring (match-beginning 1)
                                                (match-end 1))
                              source-error))))
          )
	 ((or (looking-at mira-syntax-error-re)
	      (looking-at mira-un-error-re)
	      (looking-at mira-two-lines-error-re))
	  (setq source-error
		(buffer-substring (match-beginning 1) (match-end 1)))
	  (setq source-line
		(string-to-int
			(buffer-substring (match-beginning 2) (match-end 2))))
	  (setq source-filename
		(buffer-substring (match-beginning 3) (match-end 3)))
	  ))
	(forward-line)))
      (if source-line
	(progn ;; We set the marker for the next error
	   (set-marker mira-error-marker (point))
	   ;; We open a buffer on the erroneous file
	   (if (setq buffer (get-file-buffer source-filename))
	       (pop-to-buffer buffer)
	     (find-file source-filename))
	   (goto-line source-line)
	   (message "%s" (format "Miranda error: %s" source-error)))
	(progn
	    (setq mira-error-marker nil)
	    (error "No more errors.")))
      ))

(defun mira-find-file ()
  "Gets Miranda script to edit.  The selected script will be notified to
the inferior Miranda process."
  (interactive)
  (setq mira-current-script (mira-read-file-name "Edit script: "))
  (find-file mira-current-script)
  (if (buffer-modified-p) (save-buffer))
  (pop-to-buffer "*mira*")
  (send-string "mira" (concat "/f " mira-current-script "\n")))

(defun mira-set-current-script (&optional nofile)
  "Sets the script inferior mira is looking at.  If any buffer is set on
this script, then we pop to it and save it before issuing a /f to inferior Miranda."
  (interactive)
  (let (buffer)
    (setq mira-current-script
	  (mira-read-file-name "Set current script to: "))
    (if (setq buffer (get-file-buffer mira-current-script))
	(progn
	  (pop-to-buffer buffer)
	  (if (buffer-modified-p)
	      (save-buffer))))
    (if (not nofile) ;nofile means don't send /f to mira
	(progn
	  (pop-to-buffer "*mira*")
	  (send-string "mira" (concat "/f " mira-current-script "\n"))))
    ))

(defun mira-read-file-name (prompt)
  "Reads name of Miranda script from minibuffer."
  ;;default is first Miranda buffer in (buffer-list)
  (let ((default (mira-default-script))
	(completion-ignored-extensions mira-completion-ignored-extensions))
    (read-file-name (concat prompt "(default "
			    (file-name-nondirectory default) ") ")
		    nil default)))

;;default is first Miranda buffer in (buffer-list)

(defun mira-default-script ()
  (let ((buffs (buffer-list))
	(default nil))
    (save-excursion
      (while (and buffs (not default))
	(set-buffer (car buffs))
	(if (eq major-mode 'miranda-mode)
	    (setq default buffer-file-name))
	(setq buffs (cdr buffs))))
    (or default "script.m")))

(defun mira-interval (start end)
  "returns [start..end]."
  (let ((int nil))
    (while (<= start end)
      (setq int (cons end int))
      (setq end (1- end)))
    int))

;;Why isn't there a completion match regexp?

(defvar mira-completion-ignored-extensions
  (append (mapcar 'char-to-string
		  (delq ?m (mira-interval ?! ?~)))
	  (mapcar '(lambda (x) (concat (char-to-string x) "m"))
		  (delq ?. (mira-interval ?! ?~))))
  "Miranda files must end in `.m', so ignore all these if looking for a script.") 

(defvar inferior-mira-mode-map nil)

(defun inferior-mira-mode ()
  "Major mode for interacting with an inferior Miranda session.

The following commands are available:
\\{inferior-mira-mode-map}

Entry to this mode calls the value of mira-mode-hook with no arguments,
if that value is non-nil.  Likewise with the value of comint-mode-hook.
mira-mode-hook is called after comint-mode-hook.

You can send text to the inferior Mira from other buffers
using the commands send-region, send-string.

Commands:
Return at end of buffer sends line as input.
Return not at end copies rest of line to end and sends it.
\\[comint-kill-input] and \\[backward-kill-word] are kill commands, imitating normal Unix input editing.
\\[comint-interrupt-subjob] interrupts the comint or its current subjob if any.
\\[comint-stop-subjob] stops, likewise. \\[comint-quit-subjob] sends quit signal."
  (interactive)
  (require 'comint)
  (comint-mode)
  (setq major-mode 'inferior-mira-mode)
  (setq mode-name "Inferior Miranda")
  (setq comint-prompt-regexp "^Miranda ") ;Set mira prompt pattern
  (miranda-mode-variables)
  (if inferior-mira-mode-map
      nil
    (setq inferior-mira-mode-map (copy-keymap comint-mode-map))
    (miranda-mode-commands inferior-mira-mode-map))
  (use-local-map inferior-mira-mode-map)
  (run-hooks  'mira-mode-hook))

(defun run-mira ()
  "Run an inferior Mira process, input and output via buffer *mira*."
  (interactive)
  (require 'comint)
  (if (or (not (get-process "mira"))
          (not (memq (process-status "mira") '(run stop))))
      (mira-set-current-script t))
  (pop-to-buffer
   (make-comint "mira" inferior-mira-program nil mira-current-script))
  (inferior-mira-mode))

(defun mira-compile (prefix)
  "Compile current script using Miranda process created by run-mira.
With prefix, uses /file to set Miranda's idea of current file to this
buffer."
  (interactive "P")
  (save-buffer)
  (if (not (get-process "mira"))
      (run-mira)
    (let ((name (buffer-file-name))
          (directory default-directory))
      (pop-to-buffer "*mira*")
      (goto-char (point-max))
      (if (not prefix)
          (send-string "mira" "/f %\n")
        (setq default-directory directory)
        (setq mira-current-script name)
        (send-string "mira" (concat "/hush\n/cd " directory
                                    "\n/f " name "\n/nohush\n")))))
  (setq mira-new-errors t))

;;; Tags and symbol completion handling

(defun mira-find-tag (tagname)
  "Display definition of function whose name is TAGNAME.Selects buffer 
that the function is defined in and puts point at its definition.
If TAGNAME is a null string, the expression in the buffer
around or before point is used as the tag name.

Works by sending ??TAGNAME to mira process and parsing the output in
the *mira* buffer.
CAUTION: You must do once in a miranda session
              \"/editor echo ! %\"
for getting the right format from the ?? command.
After all, once in emacs, the ?? command is useless..."
  (interactive "P")
  (if (null tagname)
      (progn
        (setq tagname
              (save-excursion  ;; copied from find-tag-tag in etags.el
                (while (looking-at "\\sw\\|\\s_")
                  (forward-char 1))
                (if (or (re-search-backward "\\sw\\|\\s_"
                                            (save-excursion (beginning-of-line) (point))
                                            t)
                        (re-search-forward "\\(\\sw\\|\\s_\\)+"
                                           (save-excursion (end-of-line) (point))
                                           t))
                    (progn (goto-char (match-end 0))
                           (buffer-substring (point)
                                             (progn (forward-sexp -1)
                                                    (while (looking-at "\\s'")
                                                      (forward-char 1))
                                                    (point))))
                  nil)))
        (setq tagname (read-string "Find Miranda tag: " tagname))))
  (if (not (get-process "mira"))
      (save-excursion (run-mira)))
  (set-buffer "*mira*")
  (goto-char (point-max))
  (let ((start (point))
	buffer source-line source-filename)
    (send-string "mira"
		 (concat "??" tagname "\n"))
    (sit-for 1)     ; ugly patch because   (accept-process-output "mira")
                    ; does not seem to work in Emacs 19 (it waits for input
                    ; before returning and then inserts this in the file..
    (goto-char start)
    (if (looking-at "\\([0-9]+\\) \\(.*\\)")
	(progn
	  (setq source-line
		(string-to-int
		 (buffer-substring (match-beginning 1) (match-end 1))))
	  (setq source-filename
		(buffer-substring (match-beginning 2) (match-end 2)))
	  (goto-char (point-max))
	  ;; We open a buffer on the file
	  (if (setq buffer (get-file-buffer source-filename))
	      (pop-to-buffer buffer)
	    (find-file source-filename))
	  (goto-line source-line))
      (error "Tag %s not found" tagname))
    ))
  

(defvar mira-reserved-words
  '(("abstype") ("div") ("if") ("mod") ("otherwise") ("readvals")
    ("show") ("type") ("where") ("with"))
  "Miranda reserved words.")

(defun mira-identifiers ()
  "Return association list of all identifiers in current scope."
  (save-excursion
    (if (not (eq major-mode 'mira-mode))
	(set-buffer (find-file-noselect mira-current-script)))
    (or mira-identifiers
	(setq mira-identifiers
	      (let ((buff (get-buffer-create " *mira-ident*"))
		    (name (buffer-file-name))
		    (identifiers mira-reserved-words))
		(message "Asking mira about identifiers...")
		(save-excursion
		  (set-buffer buff)
		  (erase-buffer)
		  (insert "?\n")
		  (call-process-region (point-min) (point-max)
				       inferior-mira-program
				       t
				       buff
				       nil
				       name)
		  ;; The names of all the identifiers should be in buff now
		  (goto-char (point-min))
		  (while (re-search-forward "\\s-\\([a-zA-Z0-9_']+\\)" nil t)
		    (setq identifiers
			  (cons (list (buffer-substring (match-beginning 1)
							(match-end 1)))
				identifiers)))
		  (message "Asking mira about identifiers...%s" "done")
		  identifiers))))))

(defun mira-complete-symbol ()
  "Perform completion on identifier preceding point.
That identifier is compared against the identifiers that exist
and any additional characters determined by what is there
are inserted.

Works by sending a ? to mira.  Saving the file triggers recalculation
of the identifiers.  If the file contains syntax errors, only the
standard indentifiers will be understood."
  (interactive)
  (let* ((end (point))
	 (beg (save-excursion
		(skip-chars-backward "a-zA-Z0-9_'")
		(point)))
	 (pattern (buffer-substring beg end))
	 (completion (try-completion pattern (mira-identifiers))))
    (cond ((eq completion t))
	  ((null completion)
	   (message "Can't find completion for \"%s\"" pattern)
	   (ding))
	  ((not (string= pattern completion))
	   (delete-region beg end)
	   (insert completion))
	  (t
	   (message "Making completion list...")
	   (let ((list (all-completions pattern (mira-identifiers))))
	     (with-output-to-temp-buffer " *Completions*"
	       (display-completion-list list)))
	   (message "Making completion list...%s" "done")))))

(defun mira-write-file-hook ()
  "Function called whenever Miranda script is written to disk."
  (setq mira-identifiers nil))  ;; this forces recalculation of identifiers

;;; Miranda manual browser by Tim Lambert

(defun mira-man-menu (section)
  "Display Miranda manual node SECTION."
  (interactive "P")
  (switch-to-buffer "*mira-man*")
  (or (eq major-mode 'mira-man-mode)
      (mira-man-mode))
  (if (not section)
      (let ((insert-default-directory nil))
	(setq section (read-file-name "Miranda manual section no: " default-directory nil t)))
    (setq section (int-to-string (prefix-numeric-value section)))
    (if (file-directory-p section)
	(setq section (concat section "/"))))
  (setq default-directory (file-name-directory (expand-file-name section)))
  (setq mira-man-current-section (string-to-int (file-name-nondirectory section)))
  (mira-man-set-mode-line)
  (let* ((buffer-read-only nil)
	(name (if (= 0 mira-man-current-section)
		  "contents"
		(int-to-string mira-man-current-section)))
	(executable (= 1 (logand 1 (or (file-modes name)
				       (error "Section %s not found" name))))))
    (erase-buffer)
    (if executable
	(progn
	  (call-process (expand-file-name name) nil t)
	  (goto-char (point-min)))
      (insert-file-contents name))
    (ununderline-region (point-min) (point-max))))

(defvar mira-man-directory
  (concat (or (getenv "MIRALIB")
	      (if (file-exists-p "/usr/lib/miralib")
		  "/usr/lib/miralib")
	      "/usr/local/lib/miralib")
	  "/manual/")
  "*Directory where the Miranda manual lives.")

(defvar mira-man-current-section 0
  "Name of section mira-man is displaying.")

(defun mira-man-next ()
  "Display next section in Miranda manual."
  (interactive)
  (mira-man-menu (if (< mira-man-current-section 35)
                     (1+ mira-man-current-section)
                   35)))

(defun mira-man-prev ()
  "Display next section in Miranda manual."
  (interactive)
  (mira-man-menu (if (> mira-man-current-section 0)
                     (1- mira-man-current-section)
                   0)))

(defun mira-man-up ()
  "Display contents page, or if at contents page, parent's contents page."
  (interactive)
  (if (= 0 mira-man-current-section)
      (if (string= default-directory mira-man-directory)
	  (error "Can't go up from the top")
	(setq default-directory
	      (file-name-directory (substring default-directory 0 -1)))))
  (mira-man-menu 0))

(defun mira-man-RTN (prefix)
  "Like mira-man-menu, except that no prefix means go up."
  (interactive "P")
  (if prefix
      (mira-man-menu prefix)
    (mira-man-up)))

(defun mira-man-exit ()
  "Exits Miranda manual."
  (interactive)
  (kill-buffer "*mira-man*"))

(defun mira-man-summary ()
  "One line summary of Miranda manual mode."
  (interactive)
  (message "Type section number and press RETURN. Press `h' for more help."))

(defun mira-man-set-mode-line ()
  (setq mode-line-buffer-identification
	(concat
	  "Miranda manual section: "
	  mira-man-current-section)))

(defvar mira-man-mode-map nil
  "Keymap containing mira-man commands.")
(if mira-man-mode-map
    nil
  (setq mira-man-mode-map (make-keymap))
  (suppress-keymap mira-man-mode-map)
  (define-key mira-man-mode-map "." 'beginning-of-buffer)
  (define-key mira-man-mode-map "\r" 'mira-man-RTN)
  (define-key mira-man-mode-map " " 'scroll-up)
  (define-key mira-man-mode-map "?" 'mira-man-summary)
  (define-key mira-man-mode-map "b" 'beginning-of-buffer)
  (define-key mira-man-mode-map "h" 'describe-mode)
  (define-key mira-man-mode-map "m" 'mira-man-menu)
  (define-key mira-man-mode-map "n" 'mira-man-next)
  (define-key mira-man-mode-map "+" 'mira-man-next)
  (define-key mira-man-mode-map "p" 'mira-man-prev)
  (define-key mira-man-mode-map "-" 'mira-man-prev)
  (define-key mira-man-mode-map "q" 'mira-man-exit)
  (define-key mira-man-mode-map "u" 'mira-man-up)
  (define-key mira-man-mode-map "\177" 'scroll-down))

(defun mira-man-mode ()
  "mira-man mode provides commands for browsing through the Miranda manual.
Documentation in mira-man is divided into \"nodes\", each of which
discusses one topic.

Selecting other nodes:
n	Move to the \"next\" node of this node.
p	Move to the \"previous\" node of this node.
u	Move \"up\" from this node.
m	Pick menu item specified by number.
        With numeric prefix picks that item.

Moving within a node:
Space	scroll forward a page.     DEL  scroll backward.
b	Go to beginning of node."

  (kill-all-local-variables)
  (setq major-mode 'mira-man-mode)
  (setq mode-name "Miranda manual")
  (use-local-map mira-man-mode-map)
  (set-syntax-table text-mode-syntax-table)
  (setq case-fold-search t)
  (setq buffer-read-only t)
  (setq default-directory mira-man-directory))

(defun mira-man ()
  "Enter the online Miranda manual."
  (interactive)
  (if (get-buffer "*mira-man*")
      (switch-to-buffer "*mira-man*")
    (mira-man-menu 0))
  (mira-man-summary))
