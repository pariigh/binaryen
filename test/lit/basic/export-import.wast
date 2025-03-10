;; NOTE: Assertions have been generated by update_lit_checks.py --all-items and should not be edited.

;; RUN: wasm-opt %s -all -o %t.text.wast -g -S
;; RUN: wasm-as %s -all -g -o %t.wasm
;; RUN: wasm-dis %t.wasm -all -o %t.bin.wast
;; RUN: wasm-as %s -all -o %t.nodebug.wasm
;; RUN: wasm-dis %t.nodebug.wasm -all -o %t.bin.nodebug.wast
;; RUN: cat %t.text.wast | filecheck %s --check-prefix=CHECK-TEXT
;; RUN: cat %t.bin.wast | filecheck %s --check-prefix=CHECK-BIN
;; RUN: cat %t.bin.nodebug.wast | filecheck %s --check-prefix=CHECK-BIN-NODEBUG

(module
 ;; CHECK-TEXT:      (type $v (func))
 ;; CHECK-BIN:      (type $v (func))
 (type $v (func))
 ;; CHECK-TEXT:      (import "env" "test2" (global $test2 i32))
 ;; CHECK-BIN:      (import "env" "test2" (global $test2 i32))
 ;; CHECK-BIN-NODEBUG:      (type $0 (func))

 ;; CHECK-BIN-NODEBUG:      (import "env" "test2" (global $gimport$0 i32))
 (import "env" "test1" (func $test1))
 ;; CHECK-TEXT:      (import "env" "test1" (func $test1 (type $v)))
 ;; CHECK-BIN:      (import "env" "test1" (func $test1 (type $v)))
 ;; CHECK-BIN-NODEBUG:      (import "env" "test1" (func $fimport$0 (type $0)))
 (import "env" "test2" (global $test2 i32))
 ;; CHECK-TEXT:      (export "test1" (func $test1))
 ;; CHECK-BIN:      (export "test1" (func $test1))
 ;; CHECK-BIN-NODEBUG:      (export "test1" (func $fimport$0))
 (export "test1" (func $test1))
 ;; CHECK-TEXT:      (export "test2" (global $test2))
 ;; CHECK-BIN:      (export "test2" (global $test2))
 ;; CHECK-BIN-NODEBUG:      (export "test2" (global $gimport$0))
 (export "test2" (global $test2))
)
