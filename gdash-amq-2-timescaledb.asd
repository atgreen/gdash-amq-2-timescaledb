;;; -*- Mode: LISP; Syntax: COMMON-LISP; Base: 10 -*-
;;;
;;; Copyright (C) 2020  Anthony Green <green@moxielogic.com>
;;;                         
;;; gdash-amq-2-timescaledb is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License as
;;; published by the Free Software Foundation; either version 3, or
;;; (at your option) any later version.
;;;
;;; gdash-amq-2-timescaledb is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;;; General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with gdash-amq-2-timescaledb; see the file COPYING3.  If not see
;;; <http://www.gnu.org/licenses/>.

(asdf:defsystem #:gdash-amq-2-timescaledb
  :description "Feed a timescaledb instance with AMQ message data."
  :author "Anthony Green <green@moxielogic.com>"
           :version "0"
  :serial t
  :components ((:file "package")
	       (:file "gdash-amq-2-timescaledb"))
  :depends-on (:cl-stomp :cl-dbi :log4cl :cl-json :cl-ppcre))

