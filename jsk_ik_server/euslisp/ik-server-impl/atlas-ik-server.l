#!/usr/bin/env roseus

(ros::load-ros-manifest "jsk_ik_server")
;;(ros::load-ros-manifest "hrpsys_gazebo_atlas")
;;(ros::load-ros-manifest "sandia_hand_msgs")
;;(ros::load-ros-manifest "atlas_msgs")

(require "package://hrpsys_gazebo_atlas/euslisp/atlas-model.l")
(require "package://jsk_ik_server/euslisp/ik-server.l")

(ros::roseus "atlas_ik_server")

(defclass atlas-ik-server
  :super ik-server
  )

(defmethod atlas-ik-server
  (:init
   (&rest args)

   (setq *atlas* (atlas-with-hand))

   (send *atlas* :reset-manip-pose)
   (send *atlas* :fix-leg-to-coords (make-coords) :both)
   (send-all (send *atlas* :joint-list) :max-joint-velocity 0.3)

   (send *atlas* :torso :waist-r :max-angle 10)
   (send *atlas* :torso :waist-r :min-angle -10)
   ;;
   (send *atlas* :torso :waist-p :max-angle 10)
   (send *atlas* :torso :waist-p :min-angle -10)
   (setq robot *atlas*)
   (setq ik-server-name "atlas_ik_server")
   (setq ik-server-service-name "/solve_ik")
   ;;
   (send self :update-support-links '(:rleg :lleg))
   (send self :make-foot-convex :force? t)
   (send self :make-centroid-object)
   ;;
   (send (send robot :utorso_lk) :make-pqpmodel :fat 30)
   (setq *success-state-collection* nil)
   ;; (send self :make-foot-convex)
   (send self :make-centroid-object)
   (setq root-link-frame-id "/pelvis")

   (send-super* :init args)
   )
  )

(instance atlas-ik-server :init)