;;; srht-builds.el --- Sourcehut builds              -*- lexical-binding: t; -*-

;; Copyright © 2022  Free Software Foundation, Inc.

;; This file is part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;; https://man.sr.ht/builds.sr.ht/api.md
;;

;;; Code:

(require 'srht)

(defun srht-builds--make-crud (domain path &optional query body)
  "Make a crud for the builds service for the DOMAIN of the Sourcehut instance.
PATH is the path for the URI.  BODY is the body sent to the URI.
QUERY is the query for the URI.  To retrieve the next page of results,
add start=:id to your QUERY, using the :id given by \"next\"."
  (declare (indent 1))
  (srht-generic-crud domain 'builds path query body))

(defun srht-builds-jobs (domain &optional query details)
  "Return a paginated list of job resources from the DOMAIN instance.
Or inserts a new job into the job queue with POST request.
To retrieve the next page of results, add start=:id to your QUERY,
using the :id given by \"next\". When insert a new job, you must specify
DETAILS (see `srht-builds-make') and omit query."
  (srht-builds--make-crud domain "/api/jobs" query details))

(cl-defun srht-builds-make (&key manifest note tags
                                 (execute "true")
                                 (secrtets "true"))
  "Build MANIFEST are YAML, which is machine editable.
NOTE - human-friendly description of this build.
TAGS - arbitrary list of strings that identify this build and can
be used to navigate the dashboard.  Each string must use only lowercase
alphanumeric characters, or any of \"-_.\". EXECUTE true to start the
build immediately.  SECRTETS - true to provide secrets during the build."
  (cl-assert manifest)
  `((manifest . ,manifest)
    (note . ,note)
    (tags . [,@tags])
    (execute . ,execute)
    (secrtets . ,secrtets)))

(defun srht-builds-job (domain id)
  "Retrieve information about a job by its ID from the DOMAIN instance."
  (srht-builds--make-crud domain (format "/api/jobs/%d" id)))

(defun srht-builds-job-artifacts (domain id &optional query)
  "Retrieve a paginated list of artifact resources created by job with ID.
To retrieve the next page of results, add start=:id to your QUERY, using
the :id given by \"next\".  DOMAIN is the domain name of the Sourcehut
instance."
  (srht-builds--make-crud domain
    (format "/api/jobs/%d/artifacts" id) query))

(defun srht-builds-job-manifest (domain id)
  "Retrieve a build manifest as plain text for a job with ID.
DOMAIN is the domain name of the Sourcehut instance."
  (srht-builds--make-crud domain
    (format "/api/jobs/%d/manifest" id)))

(defun srht-builds-job-start (domain id)
  "Start a job with ID that was created with execute=false.
Returns an empty JSON object when successful.
DOMAIN is the domain name of the Sourcehut instance."
  (srht-builds--make-crud domain
    (format "/api/jobs/%d/start" id) nil "{}"))

(defun srht-builds-job-cancel (domain id)
  "Cancels a running job with ID.  Return an empty JSON object when successful.
DOMAIN is the domain name of the Sourcehut instance."
  (srht-builds--make-crud domain
    (format "/api/jobs/%d/cancel" id) nil "{}"))

(provide 'srht-builds)
;;; srht-builds.el ends here
