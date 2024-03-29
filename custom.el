
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(LaTeX-command-style
   '(("" "%(PDF)%(latex) -shell-escape %(file-line-error) %(extraopts) %S%(PDFout)")))
 '(ansi-color-names-vector
   ["#242424" "#e5786d" "#95e454" "#cae682" "#8ac6f2" "#333366" "#ccaa8f" "#f6f3e8"])
 '(haskell-mode-hook '(turn-on-haskell-indentation))
 '(package-selected-packages
   '(diminish vagrant-tramp yaml-mode which-key undo-tree multiple-cursors highlight-indent-guides helm-swoop helm expand-region ace-jump-mode ido-vertical-mode docker-tramp php-mode ini-mode idris-mode ensime haskell-mode elpy langtool bash-completion scratch powerline use-package))
 '(python-indent-offset 4)
 '(python-shell-interpreter "python3"))


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
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(comint-highlight-prompt ((t (:foreground "green"))))
 '(minibuffer-prompt ((t (:foreground "green"))))
 '(term-color-blue ((t (:background "#008B8B" :foreground "#008B8B"))))
 '(term-color-red ((t (:background "tomato" :foreground "tomato")))))
