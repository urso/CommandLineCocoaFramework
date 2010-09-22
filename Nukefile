;; Nukefile
;; CommandLineCocoaFramework 
;; 
;; Created by Clay Bridges, change machine
;;
;; This requires the nuke tool, installed with nu.
;; Cf. http://github.com/timburks/nu
;; 
;; This is a proof-of-concept, creating a minimal framework
;; with a single class.
;;
;; Essentially this sets global variables which are then
;; used by the macros {compilation,framework}-tasks to generate
;; what you need.

(set @framework "Min")
(set @framework_identifier "net.changemachine.min")
(set @framework_initializer "MinInit")

(set @m_files (filelist "^.*\.m$"))
(set @public_headers (filelist "^.*\.h$"))
(set @mflags " -fobjc-gc") ;; gc supported, not required, needed for macirb
(set @ldflags " -framework Cocoa")
(set @arch (append '("i386") '("x86_64")))

(compilation-tasks)
(framework-tasks)

(task "default" => "framework")
