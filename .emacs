;;; .emacs

;; uncomment this line to disable loading of "default.el" at startup
;; (setq inhibit-default-init t)

;; require CL package
(require 'cl)

(require 'info)
(add-to-list 'Info-directory-list "/usr/share/info")
(add-to-list 'Info-directory-list "/usr/local/share/info")
(auto-compression-mode t)

;; startup-message
(setq-default inhibit-startup-message nil)

;; user config
(setq user-full-name "Toshihisa Abe")
(setq user-mail-address "toshihisa.abe@gmail.com")

;; my site-lisp
(setq load-path (cons "~/site-lisp/" load-path))
(setq load-path (cons "~/site-lisp/auto-install" load-path))

(require 'anything-startup)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Side-bar
(require 'sr-speedbar)
(setq-default sr-speedbar-right-side nil)
(global-set-key (kbd "C-c w") #'sr-speedbar-toggle)

;; insert header template
(require 'autoinsert)
(setq autoinsert)
(setq auto-insert-directory "~/.emacs.d/template/")
(setq auto-insert-alist
      (append '(("\\.py$" . ["template.py" my-template])
                ("\\.html?$" . ["template.html" my-template])
                ("\\.pl$" . ["template.pl" my-template])
                ) auto-insert-alist))

(defvar template-replacements-alists
  '(("%filename%" . (lambda () (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))))
    ("%authorname%" . (lambda () (format "%s" user-full-name)))
    ("%authoraddr%" . (lambda () (format "%s" user-mail-address)))
    ("%desc%" . (lambda () (format "- %s" (read-string "description: "))))
    ("%classname%" . (lambda () (capitalize
				 (file-name-sans-extension (file-name-nondirectory (buffer-file-name))))))
    ))

(defun my-template ()
  (time-stamp)
  (mapc #'(lambda (c)
			(progn
			  (goto-char (point-min))
			  (replace-string (car c) (funcall (cdr c)) nil)))
		template-replacements-alists)
  (goto-char (point-max))
  (message "done."))

(add-hook 'find-file-not-found-hooks 'auto-insert)


;;; installation at shell
;; $ git clone https://github.com/capitaomorte/yasnippet.git
(setq load-path (cons "~/site-lisp/yasnippet" load-path))
(require 'yasnippet)

;; (auto-install-from-emacswiki "yasnippet-config.el")
(require 'yasnippet-config)

;; git
(require 'git-dwim)

;; unit-test
(require 'el-expectations)
(require 'el-mock)

;; indent with space
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(auto-compression-mode t)

;; newline of final line
(setq-default require-final-newline nil)

;; turn on font-lock mode
(when (fboundp 'global-font-lock-mode)
  (global-font-lock-mode t))

;; time
(display-time)

;; truncate lines
(setq truncate-lines t)
(setq-default truncate-partial-width-windows nil)

;; line number
(line-number-mode t)
;; (when (require 'linum nil t)
;;   (global-linum-mode)
;;   (unless window-system
;;     (setq linum-format (lambda (line)
;;                          (propertize
;;                           (format (let ((w (length (number-to-string
;;                                                     (count-lines (point-min) (point-max))))))
;;                                     "%%%dd " w) line)
;;                           'face 'linum)))))
;; column number
(column-number-mode t)

;; face
(require 'hl-line)
(custom-set-faces
 '(hl-line
   ((((class color) (background dark)) (:background "color-59" :underline "green")))))

(defface hlline-face
  '((((class color)
	  (background dark))
	 (:background "dark slate gray"))
	(((class color)
	  (background light))
	 (:background "ForestGreen"))
	(t () ))
  "*Face used by hl-line")

(hl-line-mode 1)
(global-hl-line-mode t)

;; face to spaces
;; (defface mark-tabs
;;   '((t (:foreground "red" :underline t))) nil)
;; (defface mark-white-space
;;   '((t (:forground "orange" :underline t))) nil)
;; (defface mark-lineend-spaces
;;   '((t (:foreground "SteelBlue" :underline t))) nil)

(defvar underline-lastline 'undelline-lastline)
;; (defvar mark-tabs 'mark-tabs)
;; (defvar mark-white-space 'mark-white-space)
;; (defvar mark-lineend-spaces 'mark-lineend-spaces)

;;; show EOF
;;  (defun my-mark-eob ()
;;    (let ((existing-overlays (overlays-in (point-max) (point-max)))
;;          (eob-mark (make-overlay (point-max) (point-max)))
;;          (eob-text "[EOF]"))
;;      ;; Delete any previous EOB markers.  Necessary so that they don't
;;      ;; accumulate on calls to revert-buffer.
;;      (dolist (next-overlay existing-overlays)
;;        (if (overlay-get next-overlay 'eob-overlay)
;;            (delete-overlay next-overlay)))
;;      ;; Add a new EOB marker.
;;      (put-text-property 0 (length eob-text) 'face '(foreground-color . "yellow") eob-text)
;;      (put-text-property 0 1 'intangible nil eob-text)
;;      (put-text-property 1 5 'intangible t eob-text)
;;      (overlay-put eob-mark 'eob-overlay t)
;;      (overlay-put eob-mark 'intangible nil)
;;      (overlay-put eob-mark 'after-string eob-text)))
;; (add-hook 'find-file-hooks 'my-mark-eob)

(defun change-cursor-type-in-end-of-buffer (old new)
  (when (eobp)
    (message "End of Buffer")
    (setq cursor-type nil)
    (let ((overlays (overlays-in (point) (if (= 0 (point-max)) 0 (1+ (point))))))
      (dolist (overlay overlays)
        (when (overlay-get overlay 'eof-marker)
          (overlay-put overlay 'before-string
                      #("[EOF]" 0 5 (face (:background "yellow" :foreground "black")))))))))

(defun change-cursor-type-turn-to-default (old new)
  (unless (eobp)
    (setq cursor-type 'box)
    (let ((overlays (overlays-in (point-max) (if (eql 0 (point-max)) 0 (1+ (point-max))))))
      (dolist (overlay overlays)
        (when (overlay-get overlay 'eof-marker)
          (overlay-put overlay 'before-string
                       #("[EOF]" 0 5 (face (:foreground "yellow")))))))))

(defun reset-eof-property (begin end length)
  (remove-text-properties (point-min) (point-max) '(point-entered nil))
  (put-text-property (if (= (point-max) 1) 1 (1- (point-max))) (point-max) 'point-entered 'change-cursor-type-in-end-of-buffer)
  (put-text-property (point-min) (point-max) 'point-left 'change-cursor-type-turn-to-default)
)

(defun set-to-buffer-end-of-file-mark ()
  (let ((overlay (make-overlay (point-max) (point-max) nil t t)))
    (overlay-put overlay 'eof-marker t)
    (overlay-put overlay 'before-string #("[EOF]" 0 5 (face (:foreground "yellow"))))
    (put-text-property (if (= (point-max) 1) (point-max) (1- (point-max))) (point-max) 'point-entered
                       'change-cursor-type-in-end-of-buffer)
    (put-text-property (point-min) (point-max) 'point-left
                       'change-cursor-type-turn-to-default))
  (funcall (lambda () (add-hook 'after-change-functions 'reset-eof-property nil t))))

(add-hook 'find-file-hooks 'set-to-buffer-end-of-file-mark)

;;;; reference point-entered
;;
;; (defun prop-test (old new) (message "XXX: %d %d" old new))
;;
;; (let ((buffer (generate-new-buffer "*prop tst*")))
;;   (with-current-buffer buffer (insert "1234567890\n1234567890\n")
;;   (put-text-property (point-min) (point-max) 'point-entered
;;   'prop-test) (put-text-property (point-min) (point-max)
;;   'point-left 'prop-test) (pop-to-buffer buffer)))
;;;;

;; (ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
;; (ad-activate 'font-lock-mode)

;;; turn on abbrev-mode
(setq-default abbrev-mode t)
(read-abbrev-file "~/.abbrev_defs")
(setq save-abbrevs t)

;;; default mode
; (setq default-major-mode 'text-mode)

;;; enable visual feedback on marking
(setq transient-mark-mode t)

;;; default to better frame titles
(setq frame-title-format
      (concat  "%b - emacs@" (system-name)))

;; default to unified diffs
(setq diff-switches "-u")

;; always end a file with a newline
;(setq require-final-newline 'query)

;; highlight region
(transient-mark-mode t)

;; move previous window
(defun other-window-previous (&optional n)
  "move to other window"
  (interactive "p")
  (other-window (- (or n 1))))

(global-unset-key "\C-xo")
(global-set-key "\C-x\C-n" 'other-window)
(global-set-key "\C-x\C-p" 'other-window-previous)

;; auto-install
(require 'auto-install)
(setq auto-install-directory "~/site-lisp/auto-install/")
(auto-install-update-emacswiki-package-name t)

;; (auto-install-from-emacswiki "install-elisp.el")
(require 'install-elisp)

;; hide block and show block
;; (install-elisp "http://www.dur.ac.uk/p.j.heslin/Software/Emacs/Download/fold-dwim.el")
(require 'hideshow)

;; sql-mode
(add-hook 'sql-mode-hook
          #'(lambda ()
              (setq sql-indent-level 2)
              ))


;; shell-script-mode
(add-to-list 'auto-mode-alist '("\\.zsh$" . shell-script-mode))

;; markdown mode
(require 'markdown-mode)
(add-to-list 'auto-mode-alist '("\\.markdown$" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md$" . markdown-mode))

;; use navi2ch
(setq load-path (cons "/usr/share/emacs/site-lisp/" load-path))
(autoload 'navi2ch "navi2ch" "Navigator for 2ch for Emacs" t)

;; hatena-mode
(setq load-path (cons "~/site-lisp/hatena-mode/" load-path))
(require 'hatena-mode)
(setq hatena-usrid "Abeco")
(setq hatena-passwd "V6(lisP?Q8")
(setq hatena-plugin-directory "~/site-lisp/")

;; hatena-option
(setq hatena-directory (expand-file-name "~/Documents/blog/"))
;; (setq hatena-proxy "http://foo.bar.net:8080/")  ;; use proxy

;; macros
(fset 'input-pre-nontation
      (lambda (&optional arg)
	"Keyboard macro."
	(interactive "p:")
	(kmacro-exec-ring-item (quote (">||||<" 0 "%d")) arg)))

;; hatenahelper-mode
(setq load-path (cons "~/site-lisp/hatenahelper-mode-0.1" load-path))
(require 'hatenahelper-mode)
(global-set-key "\C-xH" 'hatenahelper-mode)
(add-hook 'hatena-mode-hook
 '(lambda ()
    (hatenahelper-mode 1)
    (yascrall-mode 1)))

;; bar config
;(tool-bar-mode nil)
(menu-bar-mode nil)
;(set-scroll-bar-mode 'right)
(require 'yascroll)

;; backup file
(setq make-backup-files nil)

;; make-next-line
(setq next-line-add-new-lines nil)

;; scroll lines
(setq scroll-step 1)

;; use wheel-mouse

;; use gnu global
(autoload 'gtags-mode "gtags" "" t)
(setq gtags-mode-hook
      '(lambda ()
         (local-unset-key "\M-.")
         (local-set-key "\M-.." 'gtags-find-tag)
         (local-set-key "\M-.r" 'gtags-find-rtag)
         (local-set-key "\M-.s" 'gtags-find-symbol)
         (local-set-key "\M-.t" 'gtags-pop-stack)
))

;; use Haskell
(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.lhs$" . haskell-mode))

(add-to-list 'load-path "~/site-lisp/haskell-mode-2.8.0")

(require 'haskell-mode)
(require 'inf-haskell)
(require 'haskell-ghci)
(require 'haskell-cabal)
(require 'haskell-indent)
(setq haskell-program-name "/usr/local/bin/ghci")
(add-hook 'haskell-mode-hook
          (lambda ()
            (setq haskell-check-command "~/.cabal/bin/hlint")))

;; emacs lisp
(require 'eldoc)
(require 'eldoc-extension)

(mapc (lambda (mode)
        (add-hook mode #'turn-on-eldoc-mode))
      '(emacs-lisp-mode-hook
        lisp-interaction-mode-hook
        ielm-mode-hook))

;; use Common Lisp
(global-set-key "\C-c\C-z" 'run-lisp)
(add-to-list 'auto-mode-alist '("\\.asd$" . common-lisp-mode))
(add-to-list 'load-path "~/site-lisp/slime/")  ; your SLIME directory
(setq inferior-lisp-program "/usr/local/bin/sbcl") ; your Lisp system

(require 'slime-autoloads)
(require 'slime)

;; slime japanese
(setq slime-lisp-implementations
      '((sbcl ("/usr/local/bin/sbcl") :coding-system utf-8-unix)
		(clisp ("/usr/local/bin/clisp") :coding-system utf-8-unix)
        (cmu ("/usr/local/bin/lisp"))
        (ccl ("/usr/local/bin/ccl" "-K utf-8") :coding-system utf-8-unix)
        (ecl ("/usr/local/bin/ecl") :coding-system utf-8-unix)))

(slime-setup '(slime-fancy
               slime-fuzzy
               slime-references
               slime-scratch
               slime-asdf
               slime-autodoc))

(slime-autodoc-mode)


(require 'parenthesis)

;; hook to lisp mode
(add-hook 'lisp-mode
		  '(lambda ()
			 (slime-mode t)
			 (show-paren-mode 1)))

;;; key-binding
(define-key global-map "\C-h" 'delete-backward-char)
(define-key global-map "\M-?" 'help-command)
;; (define-key global-map "\C-z" 'undo)	; instead of "\C-xu" or "C-/"
(define-key global-map "\M-/" 'dabbrev-expand)
;; (define-key global-map "\C-ct" 'transpose-chars)
(global-set-key "\M-h" 'backward-kill-word)

;;; initial-frame
(setq initial-frame-alist
      (append
       '((top . 22)
	 (left . 600)
	 (width . 100)
	 (height . 50))
      initial-frame-alist))

;; Locale
(set-language-environment "Japanese")
(set-buffer-file-coding-system 'utf-8)
(setq default-coding-system 'utf-8-unix)
(set-terminal-coding-system 'utf-8)
(prefer-coding-system 'utf-8-unix)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(set-locale-environment "ja_JP.UTF-8")

;; color
(set-foreground-color "white")
(set-background-color "black")
;;(set-cursor-color "khaki")

;; Paul Graham's Arc
(require 'inferior-arc)
(setq arc-program-name "/Users/toshi/local/bin/arc")
(require 'arc)
(add-hook 'arc-mode-hook
          '(lambda ()
             (setq indent-tabs-mode nil)))

;; scheme-mode
(defun scheme-other-window ()
  "Run scheme on other window"
  (interactive)
  (switch-to-buffer-other-window
   (get-buffer-create "*scheme*"))
  (run-scheme scheme-program-name))

(define-key global-map
  "\C-c\C-s" 'scheme-other-window)

(show-paren-mode t)

(put 'upcase-region 'disabled nil)

(autoload 'scheme-smart-complete "scheme-complete" nil t)
(eval-after-load 'scheme
  '(define-key scheme-mode-map "\e\t" 'scheme-smart-complete))

;; (setq lisp-indent-function 'scheme-smart-indent-function)


;; use gauche
(setq scheme-program-name "/usr/local/bin/gosh")

(add-hook 'scheme-mode-hook
          '(lambda ()
             (setq indent-tabs-mode nil)))

(defvar anything-c-source-info-gauche-refj
  ;; '((info-index . "~/../gauche/share/info/gauche-refj.info")))
  '((info-index . "gauche-refj.info")))

(defun anything-info-ja-at-point ()
  "Preconfigured `anything' for searching info at point."
    (interactive)
      (anything '(anything-c-source-info-gauche-refj)
                  (thing-at-point 'symbol) nil nil nil "*anything info*"))

(define-key global-map (kbd "C-M-;") #'anything-info-ja-at-point)

;; javascript-mode
(autoload 'js2-mode "Javascript-mode" "Yet Another JavaScript Mode" t)
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; php-mode
(autoload 'php-mode "php-mode" "PHP editing Mode" t)
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
(add-hook 'php-mode-hook
          '(lambda ()
             (c-set-style "stroustrup")
             (setq tab-width 4)
             (gtags-mode 1)
             (gtags-make-complete-list)))

;; Perl-mode
(defalias 'perl-mode 'cperl-mode)
(setq cperl-indent-level 4)
(setq cperl-continued-statement-offset 4)
(setq cperl-comment-column 40)

;; Smalltalk-mode (use gst)
(autoload 'smalltalk-mode "Smalltalk-mode" "Smalltalk editing Mode" t)
(add-to-list 'auto-mode-alist '("\\.st$" . smalltalk-mode))

;; c-indent

; (auto-install-from-emacswiki "c-eldoc.el")
(require 'c-eldoc)

(add-hook 'c-mode-hook
          '(lambda ()
             (c-set-style "cc-mode")
             (modify-syntax-entry ?_ "w")
             (setq tab-width 4)
             (turn-on-eldoc-mode)
             ))

;; changelog memo
(defun memo ()
  (interactive)
    (add-change-log-entry
     nil
     (expand-file-name "~/diary.txt")))

(define-key global-map "\C-xm" 'memo)

;; window-resize
(defun window-resizer ()
  "Control window size and position."
  (interactive)
  (let ((window-obj (selected-window))
        (current-width (window-width))
        (current-height (window-height))
        (dx (if (= (nth 0 (window-edges)) 0) 1
              -1))
        (dy (if (= (nth 1 (window-edges)) 0) 1
              -1))
        c)
    (catch 'end-flag
      (while t
        (message "size[%dx%d]"
                 (window-width) (window-height))
        (setq c (read-char))
        (cond ((= c ?l)
               (enlarge-window-horizontally dx))
              ((= c ?h)
               (shrink-window-horizontally dx))
              ((= c ?j)
               (enlarge-window dy))
              ((= c ?k)
               (shrink-window dy))
              ;; otherwise
              (t
               (message "Quit")
               (throw 'end-flag t)))))))

(global-set-key "\C-xw" 'window-resizer)

;; user-defined function
(defun find-library-file (file)
  "検索するライブラリファイルを引数 FILE に指定。
まずは FILE を直接load-pathから検索する。
拡張子なしで、つぎに .el をつけて検索。
さらに .elc をつけて検索する。
なければエラーを通知する。"
  (interactive "sFind library file: ")
  (let ((path (cons "" load-path)) exact match elc test found)
    (while (and (not match) path)
      (setq test (concat (car path) "/" file)
	    match (if (condition-case nil
			  (file-readable-p test)
			(error nil))
		      test)
	    path (cdr path)))
    (setq path (cons "" load-path))
    (or match
	(while (and (not elc) path)
	  (setq test (concat (car path) "/" file ".elc")
		elc (if (condition-case nil
			    (file-readable-p test)
			  (error nil))
			test)
		path (cdr path))))
    (setq path (cons "" load-path))
    (while (and (not match) path)
      (setq test (concat (car path) "/" file ".el")
	    match (if (condition-case nil
			  (file-readable-p test)
			(error nil)))
	    path (cdr path)))
    (setq found (or match elc))
    (if found
	 (progn
	   (find-file found)
	   (and match elc
		(message "(library file %s exists)" elc)
		(sit-for 1))
	   (message "Found library file %s found"))
	 (error "Library file \"%s\" not found" file))))

;; display number of lines in current buffer
(defun count-lines-buffer ()
  "display number of lines of current buffer."
  (interactive)
  (save-excursion
    (let ((count 1))
      (goto-char (point-min))
      (move-end-of-line (point))
      (while (not (eobp))
	(forward-line 1)
	(setq count (+ count 1)))
      (message "this buffer countains %d lines." count))))

;; display number of words in region
(defun count-words-region (start end)
  "display number of words in region."
  (interactive "r")
  (save-excursion
    (let ((count 0))
      (goto-char start)
      (while (< (point) end)
        (forward-word 1)
        (setq count (+ count 1)))
      (message "region countains %d words." count))))

;; display current line
(defun what-line ()
  "display current line."
  (interactive)
  (save-excursion
    (let ((count 0)
          (current-point (point)))
      (goto-char (point-min))
      (while (< (point) current-point)
        (forward-line 1)
        (setq count (+ count 1)))
      (message "current line is %d." count))))

(defun delete-space-from-tail-buffer ()
  "delete space charactrer from string tail."
  (interactive)
  (replace-regexp "[ \t]+$" ""))

(defun reload-emacs ()
  (interactive)
  (load-file "~/.emacs.d/init.el"))

(define-key global-map "\C-c\C-r" 'reload-emacs)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(gud-gdb-command-name "gdb --annotate=1")
 '(large-file-warning-threshold nil))
