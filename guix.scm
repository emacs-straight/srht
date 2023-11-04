;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2022 Aleksandr Vityazev <avityazev@posteo.org>
;;;
;;; This file is NOT part of GNU Guix.
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Comment: guix build -f guix.scm

(use-modules (guix gexp)
             (guix packages)
             (guix git-download)
             (guix build-system emacs)
             ((guix licenses) #:prefix license:)
             (gnu packages emacs)
             (gnu packages emacs-xyz)
             (ice-9 receive)
             (ice-9 popen)
             (ice-9 rdelim))

(define (last-commit-hash)
  (receive (in out pids)
      (pipeline `(("git" "rev-parse" "HEAD")))
    (let ((val (read-line in)))
      (close in)
      (close out)
      val)))

(define %source-dir (dirname (current-filename)))

(define-public emacs-srht
  (let ((commit (last-commit-hash))
        (revision "0")
        (version "0.3"))
    (package
      (name "emacs-srht")
      (version (git-version version revision commit))
      (source (local-file %source-dir
                          #:recursive? #t
                          #:select? (git-predicate %source-dir)))
      (build-system emacs-build-system)
      (arguments
       (list
        #:emacs emacs-next
        #:tests? #t
        #:test-command #~(list "emacs" "--batch"
                               "-l" "tests/srht-test.el"
                               "-f" "ert-run-tests-batch-and-exit")
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'move-source-files
              (lambda _
                (let ((el-files (find-files "./lisp" ".*\\.el$")))
                  (for-each (lambda (f)
                              (rename-file f (basename f)))
                            el-files)))))))
      (propagated-inputs (list emacs-plz))
      (home-page "https://git.sr.ht/~akagi/srht.el")
      (synopsis "Interact with sourcehut")
      (description #f)
      (license license:gpl3+))))
emacs-srht
