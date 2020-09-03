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
(defvar *db-password* nil)
(defvar *db-host* nil)

(defun getenv (var)
  (let ((val (uiop:getenv var)))
    (when (null val)
      (error "Environment variable ~A is not set." var))
    val))

(defmethod connect-cached (host)
  (unless *db-password*
    (setf *db-password* (getenv "TIMESCALEDB_PASSWORD"))
  (unless *db-host*
    (setf *db-host* (getenv "TIMESCALEDB_HOST")))

  (let ((dbc (dbi:connect-cached :postgres :database-name "gdash"
					   :host *db-host*
					   :port 5432
					   :username "gdash" :password *db-password*)))
    (log:info "Connected to timescaledb at ~A:5432 (~A)" *db-host* dbc))))

(defun tower-notification-callback (frame)
  (let ((db-connection (connect-cached))
	(message (stomp:frame-body frame)))
;;    (dbi:do-sql db-connection "insert into tower_notifications(id, url, unixtimestamp) values (-1, '~A');")
    (log:info ">> [~a]~%" (stomp:frame-body frame))))

(defun start-gdash-amq-2-timescaledb ()

  (let ((db-connection (connect-cached)))
    (mapc (lambda (command)
	    (dbi:do-sql db-connection command))
	  '("create table if not exists tower_notifications (id char(12), url char(40), unixtimestamp integer);")))

  (setf *stomp* (stomp:make-connection *amq-host* 61613))
  (stomp:register *stomp* #'tower-notification-callback *tower-notification*)
  (log:info "Starting stomp server....")
  (stomp:start *stomp*))
