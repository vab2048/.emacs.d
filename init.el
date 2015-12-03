(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-command-style (quote (("" "%(PDF)%(latex) -shell-escape %(file-line-error) %(extraopts) %S%(PDFout)"))))
 '(ansi-color-names-vector ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(column-number-mode t)
 '(haskell-mode-hook (quote (turn-on-haskell-indentation)))
 '(package-archives (quote (("gnu" . "http://elpa.gnu.org/packages/") ("melpa" . "https://melpa.org/packages/"))))
 '(python-indent-offset 4)
 '(python-shell-interpreter "python3")
 '(tool-bar-mode nil))

;; Does not recursively add subdirectories. 
(add-to-list 'load-path "~/.emacs.d/lisp/")  


(require 'column-marker)
(require 'igrep) ;; 'M-x fgrep-find' useful for finding occurences of a string in a directory.


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Initialise Packages (Start) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(package-initialize)

(elpy-enable) ;; Always initialise elpy mode (for Python)
(define-key yas-minor-mode-map (kbd "C-c k") 'yas-expand) ;; Fixing a key binding bug in elpy
(define-key global-map (kbd "C-c o") 'iedit-mode) ;; Fixing another key binding elpy bug in iedit mode

;;;;;;;;;;;;;;;;;;;;; Initialise Packages (End) ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;; Setting stock variables (Start) ;;;;;;;;;;;;;;;;;;;;;;;;;

(setq custom-theme-directory "~/.emacs.d/themes/") ;; For enabling color themes.
(setq custom-safe-themes t)
(load-theme 'blackboard-mybackground)
(setq-default indent-tabs-mode nil) ;; Do not use tabs - use spaces instead. 
(setq org-support-shift-select 'always) ;; For org mode allow using shift to highlight text
(setq confirm-kill-emacs 'y-or-n-p) ;; Always confirm when exiting
(setq inhibit-startup-message t) ;; Don't show the startup message.
(tool-bar-mode -1) ;; Get rid of the toolbar at the top
(show-paren-mode 1) ;; Highlight pairs of parens
(electric-pair-mode 1) ;; Automatically introduces closing parenthesis, brackets, braces, etc.
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


