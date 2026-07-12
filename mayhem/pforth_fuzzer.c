/*
 * mayhem/pforth_fuzzer.c — in-process libFuzzer harness for pForth.
 *
 * The old integration fuzzed the raw CLI (`pforth_standalone @@`), which Mayhem's commit-image
 * build could not instrument (0 edges, "Run Failed"). pForth's #226 added a public embedding API
 * — pfInitialize()/pfInterpretText()/pfTerminate() — so we drive the interpreter directly, over
 * the SAME code path the CLI exercises (ffInterpret over the terminal input buffer), but in-process
 * so libFuzzer/Mayhem coverage instrumentation applies.
 *
 * The interpreter (dictionary + task) is initialized ONCE for the process and reused across inputs
 * (the conventional persistent-libFuzzer shape). Per-input pfInitialize()/pfTerminate() was tried
 * first but rebuilt/loaded the static dictionary and re-created the task on every execution, making
 * the harness far too slow (~70 exec/s under ASan) for a run to finish its coverage/triage phase.
 * A word defined by one input therefore persists into later inputs; if the dictionary fills,
 * pfInterpretText() returns a Forth THROW (handled, non-fatal) rather than crashing.
 *
 * The standalone reproducer built from this same file links the run-once driver, so a POV is
 * replayed as a single input in a fresh process (init-once == that one input) — naturally reproducible.
 *
 * pfInterpretText copies the text into the fixed terminal input buffer and rejects text longer than
 * TIB_SIZE (256), so the input is capped accordingly.
 */
#include <stddef.h>
#include <stdint.h>
#include <string.h>

#include "pforth.h"

/* TIB_SIZE is 256 (csrc/pf_guts.h); pfInterpretText aborts on longer text. */
#define PFORTH_MAX_INPUT 256

static int g_ready = -1;

int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size) {
    char buf[PFORTH_MAX_INPUT + 1];
    ExecToken entryPoint = 0;

    if (g_ready < 0) {
        pfSetQuiet(1);
        g_ready = (pfInitialize(NULL, 0, &entryPoint) == 0) ? 1 : 0;
    }
    if (g_ready != 1) {
        /* Static dictionary failed to load — nothing to fuzz. */
        return 0;
    }

    if (size > PFORTH_MAX_INPUT) {
        size = PFORTH_MAX_INPUT;
    }
    memcpy(buf, data, size);
    buf[size] = '\0';

    pfInterpretText(buf);
    return 0;
}
