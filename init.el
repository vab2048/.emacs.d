
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


;;;;;;;;;;;;;;;;;;;;;;;;; Initialisation (End) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;; To be moved to conig.org file ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Automatically byte compile everything that needs byte compiling.
;; Needs to be put after changes to the load path.
;; (byte-recompile-directory (expand-file-name "~/.emacs.d") 0)

(require 'column-marker)
(require 'igrep) ;; 'M-x fgrep-find' useful for finding occurences of a string in a directory.

(elpy-enable) ;; Always initialise elpy mode (for Python)
(define-key yas-minor-mode-map (kbd "C-c k") 'yas-expand) ;; Fixing a key binding bug in elpy
(define-key global-map (kbd "C-c o") 'iedit-mode) ;; Fixing another key binding elpy bug in iedit mode


(setq custom-safe-themes t)
(load-theme 'blackboard-mybackground)


;; (global-linum-mode 1) ;; Add line numbers to side of emacs.
;; (which-function-mode 1) ;; Shows which function the point is in.

(global-set-key [f8] 'neotree-toggle)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



