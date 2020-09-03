;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: GDASH-AMQ-2-TIMESCALEDB; Base: 10 -*-
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

;; Top level for gdash-amq-2-timescaledb

(in-package :gdash-amq-2-timescaledb)

(defparameter *amq-host* "amq-broker")
(defparameter *tower-notification* "/topic/tower-notification")

(defvar *stomp* nil)
(defvar *db-connection* nil)

(defun getenv (var)
  (let ((val (uiop:getenv var)))
    (when (null val)
      (error "Environment variable ~A is not set." var))
    val))

(defun db-connect ()
  (let* ((db-host (getenv "TIMESCALEDB_HOST"))
	 (dbc (dbi:connect-cached :postgres :database-name "gdash"
					    :host db-host
					    :port 5432
					    :username "gdash" :password (getenv "TIMESCALEDB_PASSWORD"))))
    (log:info "Connected to timescaledb at ~A:5432 (~A)" db-host dbc)
    dbc))

(defun tower-notification-callback (frame)
  (let ((message (json:decode-json-from-string (stomp:frame-body frame))))
    (let ((url (cdr (assoc :URL message)))
	  (name (cdr (assoc :NAME message)))
	  (status (cdr (assoc :STATUS message))))
      (log:info "** ~A" (assoc :URL message))
      (dbi:do-sql *db-connection*
	"insert into tower_notifications(name, status, url, unixtimestamp) values ('~A', '~A', '~A', round(extract(epoch from now())));"
	name url status))
    (log:info ">> [~a]~%" (stomp:frame-body frame))))

(defun start-gdash-amq-2-timescaledb ()
  (setf *db-connection* (db-connect))
  (mapc (lambda (command)
	  (dbi:do-sql *db-connection* command))
	'("create table if not exists tower_notifications (name char(40), status char(10), url char(128), unixtimestamp integer);"))
  (setf *stomp* (stomp:make-connection *amq-host* 61613))
  (stomp:register *stomp* #'tower-notification-callback *tower-notification*)
  (log:info "Starting stomp server....")
  (stomp:start *stomp*))
