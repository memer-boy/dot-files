;; My packages
(require 'package)

(setq package-list
      '(solarized-theme
	clojure-mode
	smex
	auto-complete
	ac-cider
	cider
	rainbow-delimiters
	rainbow-mode
	smartparens
	popup
	hideshow
	csv-mode
	haskell-mode
	intero))

(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/"))

;;(add-to-list 'package-archives
;;	     '("melpa-stable" . "http://melpa-stable.milkbox.net/packages/"))

;;(add-to-list 'package-archives
;;	     '("melpa" . "http://melpa.milkbox.net/packages/"))

(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/"))

(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives
	       '("gnu" . "http://elpa.gnu.org/packages/")))

(package-initialize)

; fetch the list of packages available 
(unless package-archive-contents
  (package-refresh-contents))

; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; Shell integration, nicely B)
(setq explicit-bash-arguments "--login")

;; 
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(csv-field-quotes (quote ("\"")))
 '(custom-safe-themes
   (quote
    ("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default)))
 '(inhibit-startup-screen t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;--------------------------------------------------------------
;; Emacs functionality
;;--------------------------------------------------------------

;; nice Alt+x manager
(require 'smex)
(smex-initialize)

(global-set-key [(meta x)] 'smex)
(global-set-key [(shift meta x)] 'smex-major-mode-commands)

;; change theme
(load-theme 'solarized-light t)

;; disable toolbar
(tool-bar-mode -1)

;;;;;;;;;;;;;;;;;;
;;
;; Clojure !
;;
;;;;;;;;;;;;;;;;;;
(require 'smartparens-config)
(require 'ac-cider)

(show-paren-mode 1)
(add-hook 'clojure-mode-hook #'smartparens-mode)
(add-hook 'clojure-mode-hook #'rainbow-delimiters-mode)
(add-hook 'clojure-mode-hook #'eldoc-mode)
(add-hook 'cider-repl-mode-hook #'eldoc-mode)
(add-hook 'clojure-mode-hook #'linum-mode)
(add-hook 'clojure-mode-hook #'auto-complete-mode)
(setq nrepl-popup-stacktraces nil)
(add-to-list 'same-window-buffer-names "<em>nrepl</em>")

;; ugly windows
(setq nrepl-log-messages nil)
(setq nrepl-hide-special-buffers t)
(setq cider-show-error-buffer nil)
(setq cider-auto-select-error-buffer nil)
(setq cider-repl-pop-to-buffer-on-connect nil)

(setq cider-repl-display-in-current-window t)

;; auto-complete
(add-hook 'cider-mode-hook 'ac-flyspell-workaround)
(add-hook 'cider-mode-hook 'ac-cider-setup)
(add-hook 'cider-repl-mode-hook 'ac-cider-setup)
(eval-after-load "auto-complete"
  '(progn
     (add-to-list 'ac-modes 'cider-mode)
     (add-to-list 'ac-modes 'cider-repl-mode)))
(defun set-auto-complete-as-completion-at-point-function ()
  (setq completion-at-point-functions '(auto-complete)))
(add-hook 'auto-complete-mode-hook 'set-auto-complete-as-completion-at-point-function)
(add-hook 'cider-mode-hook 'set-auto-complete-as-completion-at-point-function)

(defun clojure-auto-complete ()
  (interactive)
  (let ((ac-sources
         `(ac-source-nrepl-ns
           ac-source-nrepl-vars
           ac-source-nrepl-ns-classes
           ac-source-nrepl-all-classes
           ac-source-nrepl-java-methods
           ac-source-nrepl-static-methods
           ,@ac-sources)))
    (auto-complete)))

(defun my-clojure-hook ()
  (auto-complete-mode 1)
  (define-key clojure-mode-map
      (kbd "β") 'clojure-auto-complete))

(add-hook 'clojure-mode-hook 'my-clojure-hook)
(setq ac-delay 0.1)
(setq ac-quick-help-delay 0.1)

;; Poping-up contextual documentation
(eval-after-load "cider"
  '(define-key cider-mode-map (kbd "C-c C-d") 'ac-cider-popup-doc))
;; initial mode
(setq initial-major-mode 'clojure-mode)

;;--------------------------------------------------------------
;; File extension to modes
;;--------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.[Cc][Ii][Dd]\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.[Ii][Cc][Dd]\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.[Ii][Ii][Dd]\\'" . nxml-mode))

(require 'hideshow)
(require 'sgml-mode)
(require 'nxml-mode)

(add-to-list 'hs-special-modes-alist
             '(nxml-mode
               "<!--\\|<[^/>]*[^/]>"
               "-->\\|</[^/>]*[^/]>"

               "<!--"
               sgml-skip-tag-forward
               nil))



(add-hook 'nxml-mode-hook 'hs-minor-mode)

;; optional key bindings, easier than hs defaults
(define-key nxml-mode-map (kbd "C-c h") 'hs-toggle-hiding)


;; disable auto-save
(setq auto-save-default nil)


;;--------------------------------------------------------------
;; Haskell
;;--------------------------------------------------------------

;; (add-hook 'haskell-mode-hook #'intero-mode)
(add-hook 'haskell-mode-hook #'smartparens-mode)
(add-hook 'haskell-mode-hook #'rainbow-delimiters-mode)
(add-hook 'haskell-mode-hook #'linum-mode)
