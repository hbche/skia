/*
 * Copyright 2016 Google Inc.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

#ifndef SKSL_ERRORREPORTER
#define SKSL_ERRORREPORTER

#include "src/sksl/SkSLPosition.h"

namespace SkSL {

/**
 * Interface for the compiler to report errors.
 */
class ErrorReporter {
public:
    virtual ~ErrorReporter() {}

    void error(int offset, const char* msg) {
        this->error(offset, String(msg));
    }

    virtual void error(int offset, String msg) = 0;

    virtual int errorCount() = 0;
};

}  // namespace SkSL

#endif
