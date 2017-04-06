
;; Emacs outputs e-lisp when it is used to custom set variables and options.
;; The following sets the 'custom-file' variable to be distinct from the
;; 'init.el'/'.emacs.el' file. It also loads the existing custom settings.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;; package.el comes bundles with emacs24+. 
(require 'package) 

(setq package-archives                        ;; The package-archives list variable contains the
  '(("gnu" . "http://elpa.gnu.org/packages/") ;; information of where emacs should look for packages
    ("melpa" . "https://melpa.org/packages/") ;; (e.g. when using M-x list-packages or otherwise).
    ;; ("marmalade" . "https://marmalade-repo.org/packages/")
   )) 

;; Whenever Emacs starts up, it automatically calls the function ‘package-initialize’ to
;; load installed packages AFTER loading the init file and abbrev file (if any) and
;; before running ‘after-init-hook’. However, we want to explictly load and configure
;; packages using the 'use-package' tool so we '(package-initialize)' here rather
;; than wait for emacs to do it after processing the init file.
(package-initialize)  ;; For loading packages explicitly in the init file.

;; The following packages are mandatory for this emacs config. The following
;; checks whether they are installed and if they aren't installs them.
;; (unless (package-installed-p 'use-package) ;; use-package used to isolate 
;;  (package-refresh-contents)               ;; and configure packages in
;;  (package-install 'use-package))          ;; a friendly and tidy manner. 

;; (unless (package-installed-p 'bind-key) 
;;  (package-refresh-contents)            
;;  (package-install 'use-package))       

;; (unless (package-installed-p 'diminish) ;; For reducing the minor modes which
;;  (package-refresh-contents)            ;; appear in the mode line.
;;  (package-install 'use-package)) 

;; use-package is not needed at runtime so evaluate it at compile time to reduce
;; emacs load time.
(eval-when-compile (require 'use-package))
(require 'diminish) ;; To diminish minor modes clogging mode line.
(require 'bind-key) ;; For easy binding of keys.

;; Rather than create a spaghetti mess of e-lisp in this one 'init.el' file, we
;; delegate the organisation of the customisation source code to an org-mode
;; file which contains the e-lisp in source blocks.  ob-tangle allows you to
;; extract source code from org-mode files
(require 'ob-tangle)  

;; (org-babel-load-file <file>) loads the Emacs Lisp source code
;; blocks in the given Org-mode <file>.
(org-babel-load-file (concat user-emacs-directory "config.org"))

;; If we are running in Windows load the Windows specific config
(if (eq system-type 'windows-nt)
  ;; if it is Windows load the windows org file
  (org-babel-load-file (concat user-emacs-directory "windows.org"))
  ;; otherwise do nothing
  ()
)


;;;;;;;;;;;;;;;;;;;;;;;;; Initialisation (End) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;; To be moved to conig.org file ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Automatically byte compile everything that needs byte compiling.
;; Needs to be put after changes to the load path.
;; (byte-recompile-directory (expand-file-name "~/.emacs.d") 0)

(require 'column-marker)


(setq custom-safe-themes t)
(load-theme 'blackboard-mybackground)


;; (global-linum-mode 1) ;; Add line numbers to side of emacs.
;; (which-function-mode 1) ;; Shows which function the point is in.

(global-set-key [f8] 'neotree-toggle)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; testing cua mode functions (delete once complete)


(defun cua-activate-plus-set-rectangle-mark()
  "If CUA mode not activated, activates it then runs cua-set-rectangle-mark.
   If it is active, just runs cua-set-rectangle-mark. "
   (interactive)

   ; After emacs 23.2: no arg to minor mode will turn on. Arg of nil will also turn on.
   (cua-mode) ; Make sure cua-mode is on 
   (cua-set-rectangle-mark))

;(bind-key "<f6>"  'cua-activate-plus-set-rectangle-mark)
;; 
(global-set-key (kbd "<f6>") 'cua-activate-plus-set-rectangle-mark)

(defun cua-mode-off()
  "Cancels any open active region/rectangle and turns CUA mode off"
  (interactive)
  (cua-cancel)
  (setq cua-mode nil))
 
(global-set-key (kbd "<f5>") 'cua-mode-off)







;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



