; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --include-generated-funcs
; RUN: %opt < %s %loadEnzyme -enzyme -enzyme-preopt=false -enzyme-vectorize-at-leaf-nodes -mem2reg -instsimplify -simplifycfg -S | FileCheck %s

; Function Attrs: noinline nounwind readnone uwtable
define double @tester(double %x) {
entry:
  %cstx = bitcast double %x to i64
  %negx = xor i64 %cstx, -9223372036854775808
  %csty = bitcast i64 %negx to double
  ret double %csty
}

define <3 x double> @test_derivative(double %x, <3 x double> %dx) {
entry:
  %0 = tail call <3 x double> (double (double)*, ...) @__enzyme_fwddiff(double (double)* nonnull @tester, metadata !"enzyme_width", i64 3, double %x, <3 x double> %dx)
  ret <3 x double> %0
}

; Function Attrs: nounwind
declare <3 x double> @__enzyme_fwddiff(double (double)*, ...)


; CHECK: define internal <3 x double> @fwddiffe3tester(double %x, <3 x double> %"x'") #0 {
; CHECK-NEXT:  entry:
; CHECK-NEXT:   %0 = fneg fast <3 x double> %"x'"
; CHECK-NEXT:   ret <3 x double> %0
; CHECK-NEXT: }