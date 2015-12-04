;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; Initialisation (Start) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Turn off mouse interface early in startup to avoid momentary display
(when window-system
  (menu-bar-mode -1)    ;; Menu bar - file, edit, etc.
  (tool-bar-mode -1)    ;; Tool bar - buttons under menu bar.
  (scroll-bar-mode -1)  ;; Scroll bar on side of buffers
  (tooltip-mode -1))    ;; On: Help text as popup/Off: as text in minibuffer.

;; Don't show the tutorial startup page.
(setq inhibit-startup-message t) 

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

;; 'use-package' is used to isolate and configure different packages in a 
;; friendly and tidy manner. It is mandatory for this emacs config.
;; The following, checks if it is installed - if it isn't it installs it.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; ob-tangle allows you to extract source code from org-mode files
(require 'ob-tangle)  

;; (org-babel-load-file <file>) loads the Emacs Lisp source code blocks in the given Org-mode <file>.
(org-babel-load-file (concat user-emacs-directory "config.org"))

;;;;;;;;;;;;;;;;;;;;;;;;; Initialisation (End) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Initialise Packages (Start) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;




;; Automatically byte compile everything that needs byte compiling.
;; Needs to be put after changes to the load path.
;; (byte-recompile-directory (expand-file-name "~/.emacs.d") 0)

(require 'column-marker)
(require 'igrep) ;; 'M-x fgrep-find' useful for finding occurences of a string in a directory.



(elpy-enable) ;; Always initialise elpy mode (for Python)
(define-key yas-minor-mode-map (kbd "C-c k") 'yas-expand) ;; Fixing a key binding bug in elpy
(define-key global-map (kbd "C-c o") 'iedit-mode) ;; Fixing another key binding elpy bug in iedit mode



;;;;;;;;;;;;;;;;;;;;; Initialise Packages (End) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Setting stock variables (Start) ;;;;;;;;;;;;;;;;;;;;;;;;;


(setq custom-safe-themes t)
(load-theme 'blackboard-mybackground)


;; (global-linum-mode 1) ;; Add line numbers to side of emacs.



;; (which-function-mode 1) ;; Shows which function the point is in.

;;;;;;;;;;;;;;;;;;;;; Setting stock variables (End) ;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;





;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Global Key Bindings (Start) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-x r b") 'helm-bookmarks)
(global-set-key (kbd "C-x m") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "M-s o") 'helm-swoop)
;; (global-set-key (kbd "C-x C-f") 'helm-find-files) ;; Prefer normal behaviour.

(global-set-key [f8] 'neotree-toggle)




;;;;;;;;;;;;;;;;;;;;; Global Key Bindings (End) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(add-hook 'LaTeX-mode-hook #'turn-on-flyspell) ;; Enable flyspell mode by default when editing LaTex.




(add-hook 'ansi-termhook 'auto-fill-mode)

