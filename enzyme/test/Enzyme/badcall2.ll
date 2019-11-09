; RUN: opt < %s %loadEnzyme -enzyme -enzyme_preopt=false -mem2reg -instsimplify -adce -correlated-propagation -simplifycfg -S | FileCheck %s

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local zeroext i1 @metasubf(double* nocapture %x) local_unnamed_addr #0 {
entry:
  %arrayidx = getelementptr inbounds double, double* %x, i64 1
  store double 3.000000e+00, double* %arrayidx, align 8
  %0 = load double, double* %x, align 8
  %cmp = fcmp fast oeq double %0, 2.000000e+00
  ret i1 %cmp
}

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local zeroext i1 @othermetasubf(double* nocapture %x) local_unnamed_addr #0 {
entry:
  %arrayidx = getelementptr inbounds double, double* %x, i64 1
  store double 4.000000e+00, double* %arrayidx, align 8
  %0 = load double, double* %x, align 8
  %cmp = fcmp fast oeq double %0, 3.000000e+00
  ret i1 %cmp
}

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local zeroext i1 @subf(double* nocapture %x) local_unnamed_addr #0 {
entry:
  %0 = load double, double* %x, align 8
  %mul = fmul fast double %0, 2.000000e+00
  store double %mul, double* %x, align 8
  %call = tail call zeroext i1 @metasubf(double* %x)
  %call1 = tail call zeroext i1 @othermetasubf(double* %x)
  ret i1 %call1
}

; Function Attrs: noinline norecurse nounwind uwtable
define dso_local void @f(double* nocapture %x) #0 {
entry:
  %call = tail call zeroext i1 @subf(double* %x)
  store double 2.000000e+00, double* %x, align 8
  ret void
}

; Function Attrs: noinline nounwind uwtable
define dso_local double @dsumsquare(double* %x, double* %xp) local_unnamed_addr #1 {
entry:
  %call = tail call fast double @__enzyme_autodiff(i8* bitcast (void (double*)* @f to i8*), double* %x, double* %xp)
  ret double %call
}

declare dso_local double @__enzyme_autodiff(i8*, double*, double*) local_unnamed_addr

; CHECK: define internal {{(dso_local )?}}{} @diffef(double* nocapture %x, double* %"x'")
; CHECK-NEXT: entry:
; CHECK-NEXT:   %0 = call { { {}, {}, double } } @augmented_subf(double* %x, double* %"x'")
; CHECK-NEXT:   %1 = extractvalue { { {}, {}, double } } %0, 0
; CHECK-NEXT:   store double 2.000000e+00, double* %x, align 8
; CHECK-NEXT:   store double 0.000000e+00, double* %"x'", align 8
; CHECK-NEXT:   %2 = call {} @diffesubf(double* nonnull %x, double* %"x'", { {}, {}, double } %1)
; CHECK-NEXT:   ret {} undef
; CHECK-NEXT: }

; CHECK: define internal {{(dso_local )?}}{ {} } @augmented_othermetasubf(double* nocapture %x, double* %"x'") 
; CHECK-NEXT: entry:
; CHECK-NEXT:   %arrayidx = getelementptr inbounds double, double* %x, i64 1
; CHECK-NEXT:   store double 4.000000e+00, double* %arrayidx, align 8
; CHECK-NEXT:   ret { {} } undef
; CHECK-NEXT: }

; CHECK: define internal {{(dso_local )?}}{ {} } @augmented_metasubf(double* nocapture %x, double* %"x'") 
; CHECK-NEXT: entry:
; CHECK-NEXT:   %arrayidx = getelementptr inbounds double, double* %x, i64 1
; CHECK-NEXT:   store double 3.000000e+00, double* %arrayidx, align 8
; CHECK-NEXT:   ret { {} } undef
; CHECK-NEXT: }

; CHECK: define internal {{(dso_local )?}}{ { {}, {}, double } } @augmented_subf(double* nocapture %x, double* %"x'") 
; CHECK-NEXT: entry:
; CHECK-NEXT:   %0 = alloca { { {}, {}, double } }
; CHECK-NEXT:   %1 = getelementptr { { {}, {}, double } }, { { {}, {}, double } }* %0, i32 0, i32 0
; CHECK-NEXT:   %2 = load double, double* %x, align 8
; CHECK-NEXT:   %3 = getelementptr { {}, {}, double }, { {}, {}, double }* %1, i32 0, i32 2
; CHECK-NEXT:   store double %2, double* %3
; CHECK-NEXT:   %mul = fmul fast double %2, 2.000000e+00
; CHECK-NEXT:   store double %mul, double* %x, align 8
; CHECK-NEXT:   %4 = call { {} } @augmented_metasubf(double* %x, double* %"x'")
; CHECK-NEXT:   %5 = call { {} } @augmented_othermetasubf(double* %x, double* %"x'")
; CHECK-NEXT:   %6 = load { { {}, {}, double } }, { { {}, {}, double } }* %0
; CHECK-NEXT:   ret { { {}, {}, double } } %6
; CHECK-NEXT: }


; CHECK: define internal {{(dso_local )?}}{} @diffesubf(double* nocapture %x, double* %"x'", { {}, {}, double } %tapeArg)
; CHECK-NEXT: entry:
; CHECK-NEXT:   %0 = call {} @diffeothermetasubf(double* %x, double* %"x'", {} undef)
; CHECK-NEXT:   %1 = call {} @diffemetasubf(double* %x, double* %"x'", {} undef)
; CHECK-NEXT:   %2 = load double, double* %"x'"
; CHECK-NEXT:   store double 0.000000e+00, double* %"x'"
; CHECK-NEXT:   %m0diffe = fmul fast double %2, 2.000000e+00
; CHECK-NEXT:   %3 = load double, double* %"x'"
; CHECK-NEXT:   %4 = fadd fast double %3, %m0diffe
; CHECK-NEXT:   store double %4, double* %"x'"
; CHECK-NEXT:   ret {} undef
; CHECK-NEXT: }

; CHECK: define internal {{(dso_local )?}}{} @diffeothermetasubf(double* nocapture %x, double* %"x'", {} %tapeArg) 
; CHECK-NEXT: entry:
; CHECK-NEXT:   %[[tostore:.+]] = getelementptr inbounds double, double* %"x'", i64 1
; CHECK-NEXT:   store double 0.000000e+00, double* %[[tostore]], align 8
; CHECK-NEXT:   ret {} undef
; CHECK-NEXT: }

; CHECK: define internal {{(dso_local )?}}{} @diffemetasubf(double* nocapture %x, double* %"x'", {} %tapeArg) 
; CHECK-NEXT: entry:
; CHECK-NEXT:   %[[tostore2:.+]] = getelementptr inbounds double, double* %"x'", i64 1
; CHECK-NEXT:   store double 0.000000e+00, double* %[[tostore2]], align 8
; CHECK-NEXT:   ret {} undef
; CHECK-NEXT: }