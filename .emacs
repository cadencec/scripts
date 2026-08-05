;; -*- lexical-binding: t; -*-
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(custom-set-variables
 '(package-selected-packages '(evil-visual-mark-mode zenburn-theme)))
(custom-set-faces)
(load-theme 'zenburn t)

;; Disable the tool bar
(tool-bar-mode -1)

;; Disable splash screen
(setq inhibit-startup-screen t)

(setq initial-buffer-choice nil)

(setq ring-bell-function 'ignore)

(setq use-dialog-box nil)

(setq make-backup-files nil)

(setq auto-save-default nil)

(setq-default indent-tabs-mode nil)
(c-set-offset 'substatement-open 0)
(set-charset-priority 'unicode)
(set-terminal-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8-unix)
(set-selection-coding-system 'utf-8-unix)
(prefer-coding-system 'utf-8)
(delete-selection-mode t)
(defalias 'view-emacs-news 'ignore)
(defalias 'describe-gnu-project 'ignore)

;; Enable line numbering in `prog-mode'
(add-hook 'prog-mode-hook #'display-line-numbers-mode)

;; Automatically pair parentheses
;(electric-pair-mode t)

(electric-indent-mode -1)
(paredit-mode 1)
;(add-hook 'php-mode-hook 'paredit-mode)
;(add-hook 'js2-mode-hook 'paredit-mode)
;(add-hook 'shell-mode-hook 'paredit-mode)
;(add-hook 'prog-mode-hook #'paredit-mode)

;; (global-font-lock-mode -1)
;;; LSP Support
(unless (package-installed-p 'eglot)
  (package-install 'eglot))

;; Enable LSP support by default in programming buffers
;(add-hook 'prog-mode-hook #'eglot-ensure)

;;; Inline static analysis

;; Enabled inline static analysis
(add-hook 'prog-mode-hook #'flymake-mode)

;;; Pop-up completion
(unless (package-installed-p 'corfu)
  (package-install 'corfu))

;; Enable autocompletion by default in programming buffers
(add-hook 'prog-mode-hook #'corfu-mode)

;; Enable automatic completion.
(setq corfu-auto t)
(setq corfu-auto-prefix 1)
(setq corfu-auto-delay 0.12)

;; Show docstring/signature popup alongside the completion popup.
(add-hook 'corfu-mode-hook #'corfu-popupinfo-mode)
(setq corfu-popupinfo-delay '(0.3 . 0.1))

(defvar my/corfu-max-buffer-lines 1000
  "Maximum buffer size in lines for enabling Corfu.")

(defun my/disable-corfu-in-large-buffer ()
  "Disable Corfu when the current buffer exceeds the configured line limit."
  (when (and (bound-and-true-p corfu-mode)
             (> (line-number-at-pos (point-max)) my/corfu-max-buffer-lines))
    (corfu-mode -1)
    (message "Buffer over %s lines: disabled Corfu"
             my/corfu-max-buffer-lines)))

;; Run after the normal programming-mode setup, including Corfu itself.
(add-hook 'prog-mode-hook #'my/disable-corfu-in-large-buffer t)

(defun my/disable-ide-features-in-scratch ()
  "Keep IDE features out of the standard `*scratch*' buffer."
  (when (equal (buffer-name) "*scratch*")
    ;; A buffer-local nil mapping also prevents a later `eglot-ensure' from
    ;; finding a language server for this buffer.
    (setq-local eglot-server-programs nil)
    (when (and (fboundp 'eglot-managed-p)
               (eglot-managed-p))
      (when (fboundp 'eglot--signal-textDocument/didClose)
        (eglot--signal-textDocument/didClose))
      (eglot--managed-mode -1))
    (flymake-mode -1)
    (eldoc-mode -1)
    (when (bound-and-true-p corfu-mode)
      (corfu-mode -1))
    (when (bound-and-true-p corfu-popupinfo-mode)
      (corfu-popupinfo-mode -1))))

;; `*scratch*' uses `lisp-interaction-mode', which derives from `prog-mode'.
;; Run last so this overrides the general programming-buffer setup above.
(add-hook 'prog-mode-hook #'my/disable-ide-features-in-scratch 100)

;; The scratch buffer already exists while the init file is being loaded.
(when-let ((scratch (get-buffer "*scratch*")))
  (with-current-buffer scratch
    (my/disable-ide-features-in-scratch)))

;; Shorter binding for manual completion-at-point.
(global-set-key (kbd "C-.") #'completion-at-point)

;; php-mode binds <M-tab> to its TAGS-based completer; override it.
(with-eval-after-load 'php-mode
  (define-key php-mode-map (kbd "<M-tab>") #'completion-at-point)
  (define-key php-mode-map (kbd "M-TAB")    #'completion-at-point))
(with-eval-after-load 'php-ts-mode
  (define-key php-ts-mode-map (kbd "<M-tab>") #'completion-at-point)
  (define-key php-ts-mode-map (kbd "M-TAB")    #'completion-at-point))

;;; Git client
(unless (package-installed-p 'magit)
  (package-install 'magit))

;; Bind the `magit-status' command to a convenient key.
(global-set-key (kbd "C-c g") #'magit-status)

;;; Indication of local VCS changes
(unless (package-installed-p 'diff-hl)
  (package-install 'diff-hl))

;; Enable `diff-hl' support by default in programming buffers
(add-hook 'prog-mode-hook #'diff-hl-mode)

;;; Clojure Support
(unless (package-installed-p 'clojure-mode)
  (package-install 'clojure-mode))

;;; JSON Support
(unless (package-installed-p 'json-mode)
  (package-install 'json-mode))

;;; PHP Support
(unless (package-installed-p 'php-ts-mode)
  (package-install 'php-ts-mode))

;;; F# Support
(unless (package-installed-p 'fsharp-mode)
  (package-install 'fsharp-mode))

;;; Typescript Support
(unless (package-installed-p 'typescript-mode)
  (package-install 'typescript-mode))

;;; YAML Support
(unless (package-installed-p 'yaml-mode)
  (package-install 'yaml-mode))

;;; LaTeX support
(unless (package-installed-p 'auctex)
  (package-install 'auctex))
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

;;; Markdown support
(unless (package-installed-p 'markdown-mode)
  (package-install 'markdown-mode))

;;; Outline-based notes management and organizer
(global-set-key (kbd "C-c a") #'org-agenda)

;;; Vim Emulation
(unless (package-installed-p 'evil)
  (package-install 'evil))

;; Enable Vim emulation
(evil-mode t)

(unless (package-installed-p 'yasnippet)
  (package-install 'yasnippet))

;; Miscellaneous options
(setq-default major-mode
              (lambda () ; guess major mode from file name
                (unless buffer-file-name
                  (let ((buffer-file-name (buffer-name)))
                    (set-auto-mode)))))
(setq confirm-kill-emacs #'yes-or-no-p)
(setq window-resize-pixelwise t)
(setq frame-resize-pixelwise t)
(save-place-mode t)
(savehist-mode t)
(recentf-mode t)

;; Store automatic customisation options elsewhere
(setq custom-file (locate-user-emacs-file "custom.el"))
(when (file-exists-p custom-file)
  (load custom-file))
(yas-global-mode 1)
(add-to-list 'auto-mode-alist '("\\.vue\\'" . web-mode))
(defalias 'yes-or-no-p 'y-or-n-p)
(global-eldoc-mode -1)

(defun find-project-root (file-name)
  (substring (file-name-directory file-name) 0 (string-match-p "app" (file-name-directory file-name))))

(defun code-format ()
  (interactive)
  (let ((default-directory (find-project-root (buffer-file-name))))
    (async-shell-command (concat ",format " (buffer-file-name)))
    (revert-buffer :ignore-auto :noconfirm)))

;(global-set-key (kbd "C-c f") 'code-format)
(setq shell-command-switch "-ic")

(setq gc-cons-threshold (* 100 1024 1024))
(setq read-process-output-max (* 1024 1024))
(setq treemacs-space-between-root-nodes nil)
;(setq company-idle-delay 0.0)
;(setq company-minimum-prefix-length 1)
;(setq lsp-idle-delay 0.500)
;(which-key-mode)
;(add-hook 'php-mode-hook 'lsp)
;(with-eval-after-load 'lsp-mode
;  (add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
;  (require 'dap-php))
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '((php-mode php-ts-mode)
                 . ("php" "-d" "memory_limit=3G"
                    "/usr/local/bin/phpactor"
                    "language-server"))))

(add-hook 'fsharp-mode-hook #'eglot-ensure)
(add-hook 'fsharp-mode-hook #'flymake-mode)
(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(fsharp-mode . ("fsautocomplete" "--adaptive-lsp-server-enabled"))))

(setq eglot-events-buffer-config '(:size 0 :format full)
      eglot-ignored-server-capabilities '(:hoverProvider
                                          :signatureHelpProvider
                                          :documentHighlightProvider
                                          :inlayHintProvider
                                          :codeLensProvider
                                          :colorProvider)
      eglot-autoshutdown t
      eglot-sync-connect nil
      eglot-send-changes-idle-time 1.0)

(defvar my/php-eglot-timeout 0.2
  "Maximum seconds a synchronous PHP Eglot request may block editing.")

(defvar my/php-large-file-lines 1000
  "PHP buffers over this many lines skip expensive IDE features.")

(defun my/php-large-buffer-p ()
  "Return non-nil when the current PHP buffer should use large-file settings."
  (>= (count-lines (point-min) (point-max)) my/php-large-file-lines))

(defun my/php-eglot-lightweight-mode ()
  "Keep PHP Eglot focused on diagnostics and basic completion."
  (setq-local jsonrpc-default-request-timeout my/php-eglot-timeout)
  ;; Avoid per-keystroke documentation/signature requests in large PHP files.
  (eldoc-mode -1)
  (when (bound-and-true-p corfu-popupinfo-mode)
    (corfu-popupinfo-mode -1)))

(defun my/php-large-file-mode ()
  "Disable expensive editor features in very large PHP buffers."
  (when (and (fboundp 'eglot-managed-p)
             (eglot-managed-p))
    ;; Detach only this buffer.  `eglot-shutdown' would kill the shared
    ;; project server and disrupt Eglot in every other PHP buffer.
    (when (fboundp 'eglot--signal-textDocument/didClose)
      (eglot--signal-textDocument/didClose))
    (eglot--managed-mode -1))
  (flymake-mode -1)
  (eldoc-mode -1)
  (when (bound-and-true-p corfu-mode)
    (corfu-mode -1))
  (when (bound-and-true-p corfu-popupinfo-mode)
    (corfu-popupinfo-mode -1))
  ;; Tree-sitter/font-lock and trailing-whitespace cleanup can dominate edits
  ;; and saves in very large generated or test files.
  (setq-local treesit-font-lock-level 1)
  (font-lock-mode -1)
  (setq-local before-save-hook nil)
  (message "Large PHP buffer over %s lines: disabled Eglot/Flymake/Corfu/font-lock/save cleanup"
           my/php-large-file-lines))

(defun my/php-setup ()
  "Configure PHP buffers for responsive editing."
  (my/php-eglot-lightweight-mode)
  (if (my/php-large-buffer-p)
      (my/php-large-file-mode)
    (flymake-mode 1)
    (eglot-ensure)))

(defun my/php-buffer-p (&optional buffer)
  "Return non-nil when BUFFER is a PHP editing buffer."
  (with-current-buffer (or buffer (current-buffer))
    (derived-mode-p 'php-mode 'php-ts-mode)))

(defun my/php-eglot-disable-after-slow-request (orig server method params &rest args)
  "Disable PHP Eglot when a synchronous request exceeds `my/php-eglot-timeout'."
  (let ((start (float-time))
        (buffer (current-buffer)))
    (condition-case err
        (apply orig server method params args)
      (jsonrpc-error
       (when (and (buffer-live-p buffer)
                  (my/php-buffer-p buffer)
                  (> (- (float-time) start) my/php-eglot-timeout))
         (with-current-buffer buffer
           (when (eglot-managed-p)
             (eglot-shutdown (eglot-current-server))
             (message "Disabled PHP Eglot after %s exceeded %.0fms"
                      method (* 1000 my/php-eglot-timeout)))))
       (signal (car err) (cdr err)))
      (:success result
       (when (and (buffer-live-p buffer)
                  (my/php-buffer-p buffer)
                  (> (- (float-time) start) my/php-eglot-timeout))
         (with-current-buffer buffer
           (when (eglot-managed-p)
             (eglot-shutdown (eglot-current-server))
             (message "Disabled PHP Eglot after slow %s request" method))))
       result))))

(with-eval-after-load 'eglot
  ;; A running project server normally auto-attaches every matching buffer.
  ;; Keep large PHP buffers excluded even when another buffer started Eglot.
  (advice-add 'eglot--maybe-activate-editing-mode :around
              (lambda (orig &rest args)
                (unless (and (my/php-buffer-p)
                             (my/php-large-buffer-p))
                  (apply orig args))))
  ;; Also prevent an explicit `eglot-ensure' (including `C-c l') from
  ;; bypassing the large-buffer exclusion.
  (advice-add 'eglot-ensure :around
              (lambda (orig &rest args)
                (if (and (my/php-buffer-p)
                         (my/php-large-buffer-p))
                    (progn
                      (my/php-large-file-mode)
                      (message "Eglot disabled: PHP buffer is over %s lines"
                               my/php-large-file-lines))
                  (apply orig args))))
  (advice-add 'eglot--request :around
              (lambda (orig server method params &rest args)
                (if (my/php-buffer-p)
                    (apply #'my/php-eglot-disable-after-slow-request
                           orig server method params args)
                  (apply orig server method params args)))))

(add-hook 'php-mode-hook #'my/php-setup 90)
(add-hook 'php-ts-mode-hook #'my/php-setup 90)

;; Neutralize long-line slowdowns (font-lock / syntax scanning over very
;; long lines), a common cause of multi-second lag in big source files.
(global-so-long-mode 1)


; (load (expand-file-name "~/quicklisp/slime-helper.el"))
  (setq inferior-lisp-program "/bin/sbcl")

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(global-set-key (kbd "C-c r") 'recentf-open-files)

(defun start-php-lsp ()
  (interactive)
  (eglot-ensure)
  (flymake-mode))
(global-set-key (kbd "C-c l") 'start-php-lsp)

(global-set-key (kbd "C-c w") 'w3m-browse-url)


(use-package fzf
  :bind
    ;; Don't forget to set keybinds!
  :config
  (setq ;; fzf/args "-x --color bw --print-query --margin=1,0 --no-hscroll"
        fzf/executable "fzf"
        fzf/git-grep-args "-i --line-number %s"
        ;; command used for `fzf-grep-*` functions
        ;; example usage for ripgrep:
        ;; fzf/grep-command "rg --no-heading -nH"
        fzf/grep-command "rg --no-heading -N --no-require-git -g '!node_modules'"
        ;; If nil, the fzf buffer will appear at the top of the window
        fzf/position-bottom t
        fzf/window-height 15))

(unless (package-installed-p 'tree-sitter)
  (package-install 'tree-sitter))
(require 'tree-sitter)
(defun get-src-at-point ()
  (interactive)
  (let ((cursor-pos (point)))
    (if-let* ((tree (tree-sitter-get-tree)) (node (tree-sitter-node-at-position tree cursor-pos)))
        (buffer-substring (tree-sitter-node-start-position node)
                          (tree-sitter-node-end-position node)))))
(defun copy-src-at-point ()
  (interactive)
  (kill-new (get-src-at-point)))
(global-set-key (kbd "C-c t") 'copy-src-at-point)

(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (php "https://github.com/tree-sitter/tree-sitter-php" "master" "php/src")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

;(load-file "~/.emacs.d/php-ts-mode/php-face.el")
;(load-file "~/.emacs.d/php-ts-mode/php-ts-mode.el")

(setq major-mode-remap-alist
 '(
   (php-mode . php-ts-mode)
   (yaml-mode . yaml-ts-mode)
   (bash-mode . bash-ts-mode)
   (js2-mode . js-ts-mode)
   (typescript-mode . typescript-ts-mode)
   (json-mode . json-ts-mode)
   (css-mode . css-ts-mode)
   (python-mode . python-ts-mode)
   (dockerfile-mode . dockerfile-ts-mode)))


;; Permit undo one keystroke at a time, rm undo timer
(when (timerp undo-auto-current-boundary-timer)
  (cancel-timer undo-auto-current-boundary-timer))

(fset 'undo-auto--undoable-change
      (lambda () (add-to-list 'undo-auto--undoably-changed-buffers (current-buffer))))

(fset 'undo-auto-amalgamate 'ignore)
(add-to-list 'exec-path "/home/sasha/.config/nvm/versions/node/v24.1.0/bin/")
(add-to-list 'exec-path "/home/sasha/.dotnet/tools/")

(global-set-key (kbd "C-c f") 'rg-project)

(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

(setq org-reveal-root "file:///home/sasha/Documents/slides/reveal.js")

(setq-default evil-kill-on-visual-paste nil)
(set-frame-font "Fira Code:pixelsize=15:foundry=CTDB:weight=regular:slant=normal:width=normal:spacing=100:scalable=true")
;; Enable the www ligature in every possible major mode
(ligature-set-ligatures 't '("www"))

;; Enable ligatures in programming modes
(ligature-set-ligatures 'prog-mode '("www" "**" "***" "**/" "*>" "*/" "\\\\" "\\\\\\" "{-" "::"
                                   ":::" ":=" "!!" "!=" "!==" "-}" "----" "-->" "->" "->>"
                                   "-<" "-<<" "-~" "#{" "#[" "##" "###" "####" "#(" "#?" "#_"
                                     "#_(" ".-" ".=" ".." "..<" "..." "?=" "??" ";;" "/*" "/**"
                                   "/=" "/==" "/>" "//" "///" "&&" "||" "||=" "|=" "|>" "^=" "$>"
                                   "++" "+++" "+>" "=:=" "==" "===" "==>" "=>" "=>>" "<="
                                   "=<<" "=/=" ">-" ">=" ">=>" ">>" ">>-" ">>=" ">>>" "<*"
                                   "<*>" "<|" "<|>" "<$" "<$>" "<!--" "<-" "<--" "<->" "<+"
                                   "<+>" "<=" "<==" "<=>" "<=<" "<>" "<<" "<<-" "<<=" "<<<"
                                   "<~" "<~~" "</" "</>" "~@" "~-" "~>" "~~" "~~>" "%%"))

(global-ligature-mode 't)
(setq select-enable-primary nil)
(setq select-enable-clipboard t)
(xclip-mode 1)
(menu-bar-mode -1)

(defun snippet-vterm (snippet)
  (interactive "MSnippet: ")
  (vterm-insert (yas-expand-snippet (yas-lookup-snippet snippet 'shell-mode))))

(set-buffer-modified-p nil)
(defun revert-buffer-no-confirm ()
    "Revert buffer without confirmation."
    (interactive)
    (revert-buffer :ignore-auto :noconfirm))
(global-set-key (kbd "C-x C-v") #'revert-buffer-no-confirm)

(add-hook 'clojure-mode
  (lambda () (local-set-key (kbd "C-c C-k") #'cider-eval-buffer)))

(use-package web-mode
  :custom
  (web-mode-code-indent-offset 2)
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2))

 (defun setup-tide-mode ()
   (interactive)
   (tide-setup)
   (flycheck-mode +1)
   (setq flycheck-check-syntax-automatically '(save mode-enabled))
   (eldoc-mode +1)
   (tide-hl-identifier-mode +1))
 (add-hook 'typescript-ts-mode-hook #'setup-tide-mode)

(add-hook 'typescript-ts-mode-hook #'eglot-ensure)
(add-hook 'tsx-ts-mode-hook        #'eglot-ensure)

(defvar my/vue-node-modules
  "/home/sasha/.config/nvm/versions/node/v24.1.0/lib/node_modules"
  "Global npm prefix that holds typescript and the Vue tooling.")

(defvar my/vue-tsdk
  (expand-file-name "typescript/lib" my/vue-node-modules)
  "Absolute path to the TypeScript lib directory the Vue LSP should load.")

(defvar my/vue-ts-plugin-location
  (expand-file-name "@vue/language-server" my/vue-node-modules)
  "Directory from which typescript-language-server can resolve
@vue/typescript-plugin via Node's module lookup.")

(with-eval-after-load 'eglot
  (defclass eglot-vue-language-server (eglot-lsp-server) ()
    :documentation "@vue/language-server (Volar) for eglot.")

  (cl-defmethod eglot-initialization-options
    ((_server eglot-vue-language-server))
    `(:typescript (:tsdk ,my/vue-tsdk)))

  (defclass eglot-vue-aware-tsls (eglot-lsp-server) ()
    :documentation "typescript-language-server taught about .vue files.")

  (cl-defmethod eglot-initialization-options
    ((_server eglot-vue-aware-tsls))
    `(:plugins [(:name "@vue/typescript-plugin"
                 :location ,my/vue-ts-plugin-location
                 :languages ["vue"])]))

  (setq eglot-server-programs
        (cl-remove-if
         (lambda (entry)
           (let ((modes (car entry)))
             (cond
              ((eq modes 'vue-mode) t)
              ((and (consp modes) (eq (car modes) 'web-mode)) t)
              ((memq 'typescript-ts-mode (if (consp modes) modes (list modes))) t)
              ((memq 'tsx-ts-mode (if (consp modes) modes (list modes))) t)
              ((memq 'typescript-mode (if (consp modes) modes (list modes))) t)
              (t nil))))
         eglot-server-programs))

  (add-to-list 'eglot-server-programs
               '((web-mode :language-id "vue")
                 . (eglot-vue-language-server "vue-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '(vue-mode
                 . (eglot-vue-language-server "vue-language-server" "--stdio")))
  (add-to-list 'eglot-server-programs
               '((typescript-ts-mode tsx-ts-mode typescript-mode)
                 . (eglot-vue-aware-tsls
                    "typescript-language-server" "--stdio"))))

;; The Vue server pulls in the TS service on startup; give it room.
(setq eglot-connect-timeout 60)

(defun maybe-eglot-ensure-vue ()
  "Start eglot in web-mode buffers that visit .vue files."
  (when (and buffer-file-name
             (string-match-p "\\.vue\\'" buffer-file-name))
    (eglot-ensure)))
;(add-hook 'web-mode-hook #'maybe-eglot-ensure-vue)
(define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
(global-set-key (kbd "s-z") #'save-buffer)
(load "server")
(unless (server-running-p) (server-start))
(find-file "~/Dropbox/dotfiles/wiki/startup.md")
