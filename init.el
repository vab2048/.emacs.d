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



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-command-style (quote (("" "%(PDF)%(latex) -shell-escape %(file-line-error) %(extraopts) %S%(PDFout)"))))
 '(ansi-color-names-vector ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(column-number-mode t)
 '(haskell-mode-hook (quote (turn-on-haskell-indentation)))
 '(python-indent-offset 4)
 '(python-shell-interpreter "python3"))






;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Global Key Bindings (Start) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-x r b") 'helm-bookmarks)
(global-set-key (kbd "C-x m") 'helm-M-x)
(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "M-s o") 'helm-swoop)
;; (global-set-key (kbd "C-x C-f") 'helm-find-files) ;; Prefer normal behaviour.

(global-set-key [f8] 'neotree-toggle)

(global-set-key (kbd "C-M-2") 'ansi-term) ;; C-M-2 opens new ANSI terminal in the current window. 

;; Move between windows: ;;
(global-set-key (kbd "C-c <left>")  'windmove-left)
(global-set-key (kbd "C-c <right>") 'windmove-right)
(global-set-key (kbd "C-c <up>")    'windmove-up)
(global-set-key (kbd "C-c <down>")  'windmove-down)

;;;;;;;;;;;;;;;;;;;;; Global Key Bindings (End) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(add-hook 'LaTeX-mode-hook #'turn-on-flyspell) ;; Enable flyspell mode by default when editing LaTex.


;; Binds C-M-! to open a new shell in a new window.
(defun new-shell (name)
  "Opens a new shell buffer with the given name in asterisks (*name*) in the current directory and changes the prompt to 'name>'."
  (interactive "sShell in new window. Enter Name: ")
  (pop-to-buffer (concat "*" name "*"))
  (unless (eq major-mode 'shell-mode)
    (shell (current-buffer))
    (sleep-for 0 200)
    (delete-region (point-min) (point-max))
    (comint-simple-send (get-buffer-process (current-buffer)) 
                        (concat "export PS1=\"\033[33m" name "\033[0m:\033[35m\\W\033[0m>\""))))
(global-set-key (kbd "C-M-!") 'new-shell)

;; Binds C-M-1 to open a new shell in the current window.
(defun new-shell-same-window (name)
  "Opens a new shell buffer with the given name in asterisks (*name*) in the current directory and changes the prompt to 'name>'."
  (interactive "sShell in same window. Enter Name: ")
  (pop-to-buffer-same-window (concat "*" name "*"))
  (unless (eq major-mode 'shell-mode)
    (shell (current-buffer))
    (sleep-for 0 200)
    (delete-region (point-min) (point-max))
    (comint-simple-send (get-buffer-process (current-buffer)) 
                        (concat "export PS1=\"\033[33m" name "\033[0m:\033[35m\\W\033[0m>\""))))
(global-set-key (kbd "C-M-1") 'new-shell-same-window)



;; Default face
(set-face-attribute 'default nil
:inherit nil 
:stipple nil 
:background "#2D3743" 
:foreground "#F8F8F8" 
:inverse-video nil 
:box nil 
:strike-through nil 
:overline nil 
:underline nil 
:slant 'normal 
:weight 'normal 
:height 113 
:width 'normal 
:foundry "unknown" 
:family "DejaVu Sans Mono")

(add-hook 'ansi-termhook 'auto-fill-mode)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(term ((t (:inherit default :foreground "white" :height 113 :width normal :family "DejaVu Sans Mono"))))
 '(term-color-blue ((t (:background "#008B8B" :foreground "#008B8B"))))
 '(term-color-red ((t (:background "tomato" :foreground "tomato")))))


