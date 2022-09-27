//===- AutoDiffOpInterface.h - Op interface for auto diff- -------* C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the interfaces necessary to implement scalable automatic
// differentiation across an unbounded number of MLIR IR constructs.
//
//===----------------------------------------------------------------------===//

#ifndef ENZYME_MLIR_INTERFACES_AUTODIFFOPINTERFACE_H
#define ENZYME_MLIR_INTERFACES_AUTODIFFOPINTERFACE_H

namespace mlir {

class OpBuilder;
class Operation;
class LogicalResult;

namespace enzyme {

class MGradientUtils;

} // namespace enzyme
} // namespace mlir

#include "MLIR/Interfaces/AutoDiffOpInterface.h.inc"
#include "mlir/IR/OpDefinition.h"

#endif // ENZYME_MLIR_INTERFACES_AUTODIFFOPINTERFACE_H